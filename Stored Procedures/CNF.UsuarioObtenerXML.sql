SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-22
-- Descripción:			Obtener Datos por Usuario
-- =============================================
CREATE PROCEDURE [CNF].[UsuarioObtenerXML]
    @Usuario AS VARCHAR(15),
    @Retorno AS VARCHAR(MAX) OUT
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
            @sSeguridad AS VARCHAR(MAX);
    DECLARE @tSeguridad AS TABLE
    (
        CveModulo VARCHAR(30),
        NivelPermiso INT
    );
    SELECT @Parametros =
    (
        SELECT @Usuario AS 'Usuario' FOR XML PATH('Parametros'), TYPE
    ),
           @Mensaje = '',
           @SP = 'CNF.UsuarioObtenerXML';

    -- =============================================
    --		VALIDACIONES
    -- =============================================

    IF ISNULL(@Usuario, '') = ''
       OR NOT EXISTS
    (
        SELECT u.Usuario
        FROM CNF.Usuarios AS u
        WHERE u.Usuario = RTRIM(@Usuario)
    )
    BEGIN
        SELECT @Mensaje
            = 'Usuario nulo o no es válido. Se debe indicar un usuario válido, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
        EXEC dbo.LogEventosInsertar @SP = @SP,                 -- varchar(300)
                                    @Parametros = @Parametros, -- xml
                                    @Tipo = @TipoEvento,       -- varchar(50)
                                    @DescrEvento = @Mensaje,   -- varchar(max)
                                    @sUsuario = NULL;          -- varchar(50)
        RAISERROR(@Mensaje, 16, 1);
        RETURN;
    END;
    -- =============================================
    --		PROCESO
    -- =============================================
    BEGIN TRY

        INSERT INTO @tSeguridad
        (
            CveModulo,
            NivelPermiso
        )
        EXEC CNF.SeguridadPorUsuarioObtener @Usuario = @Usuario;
        SELECT @sSeguridad = CAST(
        (
            SELECT Item.CveModulo,
                   Item.NivelPermiso
            FROM @tSeguridad AS Item
            FOR XML AUTO, ELEMENTS, TYPE
        )   AS VARCHAR(MAX));
        SELECT @Retorno
            = CAST(
        (
            SELECT TOP 1
                Usuario.IdUsuario,
                Usuario.Usuario AS CveUsuario,
                ISNULL(Usuario.ApePaterno, '') AS ApePaterno,
                ISNULL(Usuario.ApeMaterno, '') AS ApeMaterno,
                Usuario.Nombre,
                ISNULL(Usuario.Puesto, '') AS Puesto,
                ISNULL(Usuario.Correo, '') AS Correo,
                ISNULL(CNF.fnPerfilUsuarioObtener(Usuario.Usuario), '') AS Perfil,
                ISNULL(CONVERT(VARCHAR, Usuario.Registro, 103) + ' ' + CONVERT(VARCHAR, Usuario.Registro, 108), '') AS Registro,
                ISNULL(
                          CONVERT(VARCHAR, Usuario.UltimoAcceso, 103) + ' '
                          + CONVERT(VARCHAR, Usuario.UltimoAcceso, 108),
                          ''
                      ) AS UltimoAcceso,
                REPLACE(REPLACE(CAST(@sSeguridad AS VARCHAR(MAX)), '<Item>', ''), '</Item>', '') AS 'Seguridad',
                Usuario.IsActivo,
				Usuario.IsNuevaContraseña
            FROM CNF.Usuarios AS Usuario
            WHERE Usuario.Usuario = RTRIM(@Usuario)
            ORDER BY Usuario.IdUsuario ASC
            FOR XML AUTO, ELEMENTS, TYPE
        )   AS VARCHAR(MAX));
        SELECT @Retorno = REPLACE(REPLACE(@Retorno, '&gt;', '>'), '&lt;', '<');
    END TRY
    BEGIN CATCH
        SELECT @Retorno = NULL,
               @TipoEvento = 'Error',
               @Mensaje
                   = 'Error de Ejecución: ' + RTRIM(ISNULL(ERROR_NUMBER(), -1)) + ' | '
                     + RTRIM(ISNULL(ERROR_MESSAGE(), ''));
		 EXEC dbo.LogEventosInsertar @SP = @SP,                 -- varchar(300)
                                    @Parametros = @Parametros, -- xml
                                    @Tipo = @TipoEvento,       -- varchar(50)
                                    @DescrEvento = @Mensaje,   -- varchar(max)
                                    @sUsuario = NULL;          -- varchar(50)
		RAISERROR(@Mensaje, 16, 1);
    END CATCH;
    RETURN;
END;

GO
