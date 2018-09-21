SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Roberto Amaya
-- Update:		2018-07-23
-- Description:	Validar y registra ingreso a Sistema, devuelve valores obtenidos de Usuario logeado
-- =============================================
CREATE PROCEDURE [CNF].[UsuarioIngreso]
    @Usuario AS VARCHAR(15),
    @Contraseña AS VARBINARY(MAX),
    @iError AS INT = -1 OUTPUT,
    @sError AS VARCHAR(MAX) = NULL OUTPUT,
    @Retorno AS VARCHAR(MAX) = NULL OUTPUT
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
        SELECT @Usuario AS 'Usuario',
               @Contraseña AS 'Contraseña'
        FOR XML PATH('Parametros')
    ),
           @iError = 0,
           @SP = 'CNF.UsuarioIngreso';

    -- =============================================
    --		VALIDACIONES
    -- =============================================
    IF @Contraseña IS NULL
    BEGIN
        SELECT @iError = 1,
               @sError
                   = 'Contraseña no indicada. Se debe indicar contraseña con un formato válido, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF @Usuario IS NULL
    BEGIN
        SELECT @iError = 1,
               @sError
                   = 'Usuario no indicado. Se debe proporcionar usuario con un formato válido, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;

    -- =============================================
    --		PROCESO
    -- =============================================

    IF NOT EXISTS
    (
        SELECT u.IdUsuario
        FROM CNF.Usuarios AS u
        WHERE u.Usuario = RTRIM(@Usuario)
              AND u.Contraseña = @Contraseña
    )
    BEGIN
        SELECT @iError = 1,
               @sError = 'Acceso Denegado: Usuario y/o Contraseña incorrectos.',
               @TipoEvento = 'Acceso Denegado';
    END;

    IF @iError = 0
    BEGIN
        BEGIN TRY
            SELECT @iError = 0,
                   @sError = 'Acceso Autorizado.',
                   @TipoEvento = 'Acceso Autorizado';
            UPDATE CNF.Usuarios
            SET UltimoAcceso = GETDATE()
            WHERE Usuario = @Usuario;
            EXEC CNF.UsuarioObtenerXML @Usuario = @Usuario,        -- varchar(15)
                                       @Retorno = @Retorno OUTPUT; -- varchar(max)

        END TRY
        BEGIN CATCH
            SELECT @iError = ERROR_NUMBER(),
                   @sError = ERROR_MESSAGE();
            SELECT @TipoEvento = 'Error',
                   @Retorno = NULL,
                   @Mensaje = 'Error de Ejecución: ' + RTRIM(ISNULL(@iError, 0)) + ' | ' + RTRIM(ISNULL(@sError, ''));
        END CATCH;
    END;
    -- =============================================
    --		RETORNO
    -- =============================================
    IF @iError <> 0
    BEGIN
        EXEC dbo.LogEventosInsertar @SP = @SP,                 -- varchar(300)
                                    @Parametros = @Parametros, -- xml
                                    @Tipo = @TipoEvento,       -- varchar(50)
                                    @DescrEvento = @sError,    -- varchar(max)
                                    @sUsuario = @Usuario;      -- varchar(50)
        RETURN;
    END;
END;
GO
