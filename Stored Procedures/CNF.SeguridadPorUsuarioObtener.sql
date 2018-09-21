SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-31
-- Descripción:			Obtener Seguridad por Usuario
-- =============================================
CREATE PROCEDURE [CNF].[SeguridadPorUsuarioObtener] @Usuario AS VARCHAR(15)
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
        SELECT @Usuario AS 'Usuario' FOR XML PATH('Parametros'), TYPE
    ),
           @SP = 'CNF.SeguridadPorUsuarioObtener';
    IF ISNULL(@Usuario, '') = ''
       OR NOT EXISTS
    (
        SELECT u.Usuario
        FROM CNF.Usuarios AS u
        WHERE u.Usuario = RTRIM(@Usuario)
    )
    BEGIN
        SELECT @Mensaje
            = 'Usuario nulo o no es válido, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
        EXEC dbo.LogEventosInsertar @SP = @SP,                 -- varchar(300)
                                    @Parametros = @Parametros, -- xml
                                    @Tipo = @TipoEvento,       -- varchar(50)
                                    @DescrEvento = @Mensaje,   -- varchar(max)
                                    @sUsuario = NULL; -- varchar(50)
        RAISERROR(@Mensaje, 16, 1);
        RETURN;
    END;
    -- =============================================
    --		PROCESO
    -- =============================================
    SELECT fsppc.CveModulo,
           (CASE
                WHEN fsppc.IsConfiguracion = 1 THEN 
                    3 --Configurar
                WHEN fsppc.IsEdicion = 1 THEN
                    2 --Editar
                WHEN fsppc.IsLectura = 1 THEN
                    1 --Leer
                ELSE
                    0 --SinAcceso
            END
           ) AS Permisos
    FROM CNF.fnSeguridadPorPerfilConsultar(CNF.fnPerfilUsuarioObtener(@Usuario)) AS fsppc
    WHERE fsppc.IsActivo = 1
    ORDER BY fsppc.OrdenPadre,
             fsppc.Orden ASC;
END;
GO
