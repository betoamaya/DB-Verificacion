SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-07
-- Descripción:			Alta y Edición de Perfiles de Usuario
-- =============================================
CREATE PROCEDURE [CNF].[PerfilesGuardar]
    @Perfil AS VARCHAR(50),
    @IsActivo AS BIT,
    @IsAlta AS BIT,
    @UsuarioEdita AS VARCHAR(15),
    @iError AS INT = NULL OUT,
    @sError AS VARCHAR(MAX) = NULL OUT
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    --		VARIABLES
    -- =============================================

    DECLARE @Parametros AS XML,
            @Mensaje AS VARCHAR(MAX),
            @TipoEvento AS VARCHAR(50),
            @SP AS VARCHAR(255);
    SELECT @Parametros =
    (
        SELECT @Perfil AS 'Perfil',
               @IsActivo AS 'IsActivo',
               @IsAlta AS 'IsAlta',
               @UsuarioEdita AS 'UsuarioEdita'
        FOR XML PATH('Parametros')
    ),
           @iError = 0,
           @SP = 'CNF.PerfilesGuardar';

    -- =============================================
    --		VALIDACIONES
    -- =============================================
    IF ISNULL(@UsuarioEdita, '') = ''
       OR NOT EXISTS
    (
        SELECT u.Usuario
        FROM CNF.Usuarios AS u
        WHERE u.Usuario = RTRIM(@UsuarioEdita)
              AND u.IsActivo = 1
    )
    BEGIN
        SELECT @iError = -1,
               @sError
                   = 'Usuario que edita nulo o no es válido, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (@IsAlta IS NULL)
    BEGIN
        SELECT @iError = -1,
               @sError
                   = 'No se indico si el perfil es alta, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (@IsActivo IS NULL)
    BEGIN
        SELECT @iError = -1,
               @sError
                   = 'No se indico si el estatus del perfil, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (ISNULL(@Perfil, '') = '')
       OR (LEN(@Perfil) < 3)
    BEGIN
        SELECT @iError = -1,
               @sError = 'Perfil no indicado, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
	IF (@IsAlta = 1)
       AND EXISTS
    (
        SELECT p.Perfil
        FROM CNF.Perfiles AS p
        WHERE p.Perfil = RTRIM(@Perfil)
    )
    BEGIN
        SELECT @iError = -1,
               @sError
                   = 'Perfil indicado ya existe, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
	IF (@IsAlta = 0)
       AND NOT EXISTS
    (
        SELECT p.Perfil
        FROM CNF.Perfiles AS p
        WHERE p.Perfil = RTRIM(@Perfil)
    )
    BEGIN
        SELECT @iError = -1,
               @sError
                   = 'Perfil indicado no existe, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    -- =============================================
    --		PROCESO
    -- =============================================
    IF @iError = 0
    BEGIN
        IF @IsAlta = 1
        BEGIN
            SELECT @sError = 'Se realizó con éxito el alta del Perfil ' + RTRIM(@Perfil),
                   @TipoEvento = 'Alta Perfil';
            DECLARE @CvePerfil AS UNIQUEIDENTIFIER;
            SELECT @CvePerfil = NEWID();
            BEGIN TRY
                INSERT INTO CNF.Perfiles
                (
                    Perfil,
                    CvePerfil,
                    IsActivo
                )
                VALUES
                (   @Perfil,    -- Perfil - varchar(50)
                    @CvePerfil, -- CvePerfil - uniqueidentifier
                    @IsActivo   -- IsActivo - bit
                );
            END TRY
            BEGIN CATCH
                SELECT @iError = ISNULL(ERROR_NUMBER(),1),
                       @sError = ISNULL(ERROR_MESSAGE(),'Error no Identificado, contacte a Service Desk.');
                SELECT @TipoEvento = 'Error',
                       @Mensaje
                           = 'Error de Ejecución: ' + RTRIM(@iError) + ' | ' + RTRIM(@sError);
            END CATCH;
        END;
        ELSE
        BEGIN
            SELECT @sError = 'Se realizó con éxito la actualización del Perfil ' + RTRIM(@Perfil),
                   @TipoEvento = 'Editar Perfil';
            BEGIN TRY
                UPDATE CNF.Perfiles
                SET IsActivo = @IsActivo
                WHERE Perfil = RTRIM(@Perfil);
            END TRY
            BEGIN CATCH
               SELECT @iError = ISNULL(ERROR_NUMBER(),1),
                       @sError = ISNULL(ERROR_MESSAGE(),'Error no Identificado, contacte a Service Desk.');
                SELECT @TipoEvento = 'Error',
                       @Mensaje
                           = 'Error de Ejecución: ' + RTRIM(@iError) + ' | ' + RTRIM(@sError);
            END CATCH;
        END;
    END;
    -- =============================================
    --		RETORNO
    -- =============================================
    EXEC dbo.LogEventosInsertar @SP = @SP,                 -- varchar(300)
                                @Parametros = @Parametros, -- xml
                                @Tipo = @TipoEvento,       -- varchar(50)
                                @DescrEvento = @sError,    -- varchar(max)
                                @sUsuario = @UsuarioEdita; -- varchar(50)
    RETURN;
END;
GO
