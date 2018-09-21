SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-09
-- Descripción:			Alta y Edición de Usuarios
-- =============================================
CREATE PROCEDURE [CNF].[UsuariosGuardar]
    @Usuario AS VARCHAR(15),
    @ApePaterno AS VARCHAR(30),
    @ApeMaterno AS VARCHAR(30),
    @Nombre AS VARCHAR(35),
    @Puesto AS VARCHAR(50),
    @Correo AS VARCHAR(100),
    @IsActivo AS BIT,
    @IsAlta AS BIT,
    @Perfil AS VARCHAR(50),
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
            @SP AS VARCHAR(255),
            @sContraseña AS VARCHAR(8),
            @CvePerfil AS UNIQUEIDENTIFIER;
    SELECT @Parametros =
    (
        SELECT @Usuario AS 'Usuario',
               @ApePaterno AS 'ApePaterno',
               @ApeMaterno AS 'ApeMaterno',
               @Nombre AS 'Nombre',
               @Puesto AS 'Puesto',
               @Correo AS 'Correo',
               @IsActivo AS 'IsActivo',
               @Perfil AS 'Perfil',
               @UsuarioEdita AS 'UsuarioEdita'
        FOR XML PATH('Parametros'), TYPE
    ),
           @iError = 0,
           @SP = 'CNF.UsuariosGuardar';

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
               @sError = 'Usuario que edita nulo o no es válido, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (CNF.fnSeguridadUsuarioTieneNivelPermisoModulo(@UsuarioEdita, 'EditarUsuarios', 'Configurar') = 0)
    BEGIN
        SELECT @iError = -1,
               @sError = 'Usuario que edita no tiene privilegios para esta acción, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF ISNULL(@Perfil, '') = ''
       OR NOT EXISTS
    (
        SELECT p.Perfil
        FROM CNF.Perfiles AS p
        WHERE p.Perfil = RTRIM(@Perfil)
    )
    BEGIN
        SELECT @iError = -1,
               @sError = 'Perfil nulo o no es válido, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (@IsAlta IS NULL)
    BEGIN
        SELECT @iError = -1,
               @sError = 'No se indico si el usuario es alta, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (@IsActivo IS NULL)
    BEGIN
        SELECT @iError = -1,
               @sError = 'No se indico si el usuario esta activo, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (ISNULL(@Correo, '') <> '')
       AND (CNF.fnCompruebaEmail(@Correo) = '')
    BEGIN
        SELECT @iError = -1,
               @sError = 'El formato del correo indicado es invalido, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (ISNULL(@Puesto, '') = '')
    BEGIN
        SELECT @iError = -1,
               @sError = 'Puesto no indicado, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (ISNULL(@Nombre, '') = '')
       OR (LEN(@Nombre) < 3)
    BEGIN
        SELECT @iError = -1,
               @sError = 'Nombre(s) no indicado, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (ISNULL(@ApePaterno, '') = '')
       AND (ISNULL(@ApePaterno, '') = '')
    BEGIN
        SELECT @iError = -1,
               @sError = 'Apellido no indicado, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (ISNULL(@Usuario, '') = '')
       OR (LEN(@Usuario) < 3)
    BEGIN
        SELECT @iError = -1,
               @sError = 'Usuario no indicado, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (@IsAlta = 1)
       AND EXISTS
    (
        SELECT *
        FROM CNF.Usuarios AS u
        WHERE u.Usuario = RTRIM(@Usuario)
    )
    BEGIN
        SELECT @iError = -1,
               @sError = 'Usuario indicado ya existe, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (@IsAlta = 0)
       AND NOT EXISTS
    (
        SELECT u.Usuario
        FROM CNF.Usuarios AS u
        WHERE u.Usuario = RTRIM(@Usuario)
    )
    BEGIN
        SELECT @iError = -1,
               @sError = 'Usuario indicado no existe, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    -- =============================================
    --		PROCESO
    -- =============================================
    IF @iError = 0
    BEGIN
        SELECT TOP 1
            @CvePerfil = p.CvePerfil
        FROM CNF.Perfiles AS p
        WHERE p.Perfil = RTRIM(@Perfil);

        IF @IsAlta = 1
        BEGIN
            SELECT @sError = 'Se realizó con éxito el alta del Usuario ' + RTRIM(@Usuario),
                   @TipoEvento = 'Alta Usuario',
                   @sContraseña = CNF.fnGenerarContraseña(8, 'CN');
            BEGIN TRY
                INSERT INTO CNF.Usuarios
                (
                    Usuario,
                    Contraseña,
                    ApePaterno,
                    ApeMaterno,
                    Nombre,
                    Puesto,
                    Correo,
                    CvePerfil,
                    IsActivo,
                    IsNuevaContraseña,
                    Registro
                )
                VALUES
                (   @Usuario,                        -- Usuario - varchar(15)
                    HASHBYTES('SHA1', @sContraseña), -- Contraseña - varbinary(max)
                    RTRIM(ISNULL(@ApePaterno, '')),  -- ApePaterno - varchar(30)
                    RTRIM(ISNULL(@ApeMaterno, '')),  -- ApeMaterno - varchar(30)
                    RTRIM(@Nombre),                  -- Nombre - varchar(35)
                    RTRIM(ISNULL(@Puesto, '')),      -- Puesto - varchar(50)
                    RTRIM(ISNULL(@Correo, '')),      -- Correo - varchar(100)
                    @CvePerfil,                      -- CvePerfil - uniqueidentifier
                    @IsActivo,                       -- IsActivo - bit
                    1,                               -- IsNuevaContraseña - bit
                    GETDATE()                        -- Registro - datetime
                );
            END TRY
            BEGIN CATCH
                SELECT @iError = ISNULL(ERROR_NUMBER(), 1),
                       @sError = ISNULL(ERROR_MESSAGE(), 'Error no Identificado, contacte a Service Desk.');
                SELECT @TipoEvento = 'Error',
                       @Mensaje = 'Error de Ejecución: ' + RTRIM(@iError) + ' | ' + RTRIM(@sError);
            END CATCH;
            IF ISNULL(@Correo, '') <> ''
               AND @iError = 0
            BEGIN
                BEGIN TRY
                    SELECT @Mensaje = CNF.fnGenerarMensajeHTML(@TipoEvento, @Nombre, @Usuario, @sContraseña, NULL),
                           @Correo = @Correo + ', roberto.amaya@transpais.com.mx';
                    EXEC CNF.CorreoEnviar @From = 'roberto.amaya@transpais.com.mx',
                                          @To = @Correo,
                                          @Subject = @TipoEvento,
                                          @Body = @Mensaje;
                END TRY
                BEGIN CATCH
                    SELECT @Mensaje
                        = ISNULL(ERROR_NUMBER(), -1) + ' | '
                          + RTRIM(ISNULL(ERROR_MESSAGE(), 'Error no Identificado, contacte a Service Desk.'));
                    EXEC dbo.LogEventosInsertar @SP = @SP,                 -- varchar(300)
                                                @Parametros = @Parametros, -- xml
                                                @Tipo = 'Error Correo',    -- varchar(50)
                                                @DescrEvento = @Mensaje,   -- varchar(max)
                                                @sUsuario = @UsuarioEdita; -- varchar(50)
                END CATCH;
            END;
        END;
        ELSE
        BEGIN
            SELECT @sError = 'Se realizó con éxito la actualización del Usuario ' + RTRIM(@Usuario),
                   @TipoEvento = 'Editar Usuario';
            BEGIN TRY
                UPDATE CNF.Usuarios
                SET ApePaterno = RTRIM(ISNULL(@ApePaterno, '')),
                    ApeMaterno = RTRIM(ISNULL(@ApeMaterno, '')),
                    Nombre = RTRIM(@Nombre),
                    Puesto = RTRIM(ISNULL(@Puesto, '')),
                    Correo = RTRIM(ISNULL(@Correo, '')),
                    CvePerfil = @CvePerfil,
                    IsActivo = @IsActivo
                WHERE Usuario = RTRIM(@Usuario);
            END TRY
            BEGIN CATCH
                SELECT @iError = ISNULL(ERROR_NUMBER(), 1),
                       @sError = ISNULL(ERROR_MESSAGE(), 'Error no Identificado, contacte a Service Desk.');
                SELECT @TipoEvento = 'Error',
                       @Mensaje = 'Error de Ejecución: ' + RTRIM(@iError) + ' | ' + RTRIM(@sError);
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
