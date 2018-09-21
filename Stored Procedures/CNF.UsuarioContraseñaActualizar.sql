SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-09
-- Descripción:			Actualizar Contraseña de Usuario
-- =============================================
CREATE PROCEDURE [CNF].[UsuarioContraseñaActualizar]
    @Usuario VARCHAR(15),
    @ContraseñaActual AS VARBINARY(MAX),
    @ContraseñaNueva AS VARBINARY(MAX),
    @UsuarioEdita VARCHAR(15),
    @iError AS INT = -1 OUTPUT,
    @sError AS VARCHAR(MAX) = NULL OUTPUT
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
            @Correo AS VARCHAR(100), @Nombre AS VARCHAR(35);
    SELECT @Parametros =
    (
        SELECT @Usuario AS 'Usuario',
               @ContraseñaActual AS 'ContraseñaActual',
               @ContraseñaNueva AS 'ContraseñaNueva',
               @UsuarioEdita AS 'UsuarioEdita'
        FOR XML PATH('Parametros'), TYPE
    ),
           @iError = 0,
           @SP = 'CNF.UsuarioContraseñaActualizar';
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
    IF (RTRIM(@Usuario) = RTRIM(@UsuarioEdita))
       AND (CNF.fnSeguridadUsuarioTieneNivelPermisoModulo(@UsuarioEdita, 'EditarContraseña', 'Editar') = 0)
    BEGIN
        SELECT @iError = -1,
               @sError = 'Usuario que edita no tiene privilegios para esta acción, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (RTRIM(@Usuario) <> RTRIM(@UsuarioEdita))
       AND (CNF.fnSeguridadUsuarioTieneNivelPermisoModulo(@UsuarioEdita, 'EditarContraseña', 'Configurar') = 0)
    BEGIN
        SELECT @iError = -1,
               @sError = 'Usuario que edita no tiene privilegios para esta acción, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (ISNULL(DATALENGTH(@ContraseñaNueva), -1) = -1)
    BEGIN
        SELECT @iError = -1,
               @sError = 'Contraseña Nueva no indicada, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (RTRIM(@Usuario) = RTRIM(@UsuarioEdita))
       AND NOT EXISTS
    (
        SELECT u.Usuario
        FROM CNF.Usuarios AS u
        WHERE u.Usuario = RTRIM(@Usuario)
              AND u.Contraseña = (CASE /*Para el caso de que le exija nueva contraseña*/
                                      WHEN u.IsNuevaContraseña = 1 THEN
                                          u.Contraseña
                                      ELSE
                                          @ContraseñaActual
                                  END
                                 )
    )
    BEGIN
        SELECT @iError = -1,
               @sError = 'La contraseña actual no es valida, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (RTRIM(@Usuario) = RTRIM(@UsuarioEdita))
       AND (ISNULL(DATALENGTH(@ContraseñaActual), -1) = -1)
    BEGIN
        SELECT @iError = -1,
               @sError = 'Contraseña actual no indicada, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF ISNULL(@Usuario, '') = ''
       OR NOT EXISTS
    (
        SELECT u.Usuario
        FROM CNF.Usuarios AS u
        WHERE u.Usuario = RTRIM(@Usuario)
              AND u.IsActivo = 1
    )
    BEGIN
        SELECT @iError = -1,
               @sError = 'Usuario nulo o no es válido, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;

    -- =============================================
    --		PROCESO
    -- =============================================

    IF @iError = 0
    BEGIN
        SELECT @sError = 'Se realizó con éxito el cambio de contraseña para el Usuario ' + RTRIM(@Usuario),
               @TipoEvento = 'Editar Contraseña';
        BEGIN TRY
            UPDATE CNF.Usuarios
            SET Contraseña = @ContraseñaNueva, IsNuevaContraseña = 0
            WHERE Usuario = @Usuario;
        END TRY
        BEGIN CATCH
            SELECT @iError = ISNULL(ERROR_NUMBER(), 1),
                   @sError = ISNULL(ERROR_MESSAGE(), 'Error no Identificado, contacte a Service Desk.');
            SELECT @TipoEvento = 'Error',
                   @Mensaje = 'Error de Ejecución: ' + RTRIM(@iError) + ' | ' + RTRIM(@sError);
        END CATCH;

        SELECT @Correo = u.Correo, @Nombre = u.Nombre
        FROM CNF.Usuarios AS u
        WHERE u.Usuario = RTRIM(@Usuario);

        IF ISNULL(@Correo, '') <> ''
           AND @iError = 0
        BEGIN
            BEGIN TRY
                SELECT @Mensaje = CNF.fnGenerarMensajeHTML(@TipoEvento, @Nombre, @Usuario, NULL, NULL),
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
