SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-02
-- Descripción:			Obtener Seguridad por Usuario
-- =============================================
CREATE PROCEDURE [CNF].[SeguridadObtenerXML]
    @Perfil AS VARCHAR(50),
    @IsActivo AS BIT = 1,
    @Retorno AS VARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF ISNULL(@Perfil, '') <> ''
    BEGIN
        IF @IsActivo = 0
        BEGIN
            SELECT @IsActivo = NULL;
        END;

        SELECT @Retorno = CAST(
        (
            SELECT
        (
            SELECT Modulos.idSeguridad,
                   Modulos.Modulo,
                   Modulos.DescrModulo,
                   Modulos.CveModulo,
                   --Modulos.IsLectura,
                   --Modulos.IsEdicion,
                   --Modulos.IsConfiguracion,
                   (CASE
                        WHEN Modulos.IsConfiguracion = 1 THEN
                            3 --Configurar
                        WHEN Modulos.IsEdicion = 1 THEN
                            2 --Editar
                        WHEN Modulos.IsLectura = 1 THEN
                            1 --Leer
                        ELSE
                            0 --SinAcceso
                    END
                   ) AS NivelPermisos,
                   Modulos.OrdenPadre,
                   Modulos.Orden
            FROM CNF.fnSeguridadPorPerfilConsultar(@Perfil) AS Modulos
            WHERE Modulos.IsActivo = ISNULL(@IsActivo, Modulos.IsActivo)
            ORDER BY Modulos.OrdenPadre,
                     Modulos.Orden ASC
            FOR XML AUTO, ELEMENTS, TYPE
        )       AS 'Seguridad'
            FOR XML PATH('Retorno'), TYPE
        )   AS VARCHAR(MAX));
        PRINT @Retorno;
        SELECT @Retorno = REPLACE(REPLACE(@Retorno, '&gt;', '>'), '&lt;', '<');
        SELECT @Retorno = REPLACE(REPLACE(@Retorno, '<Retorno>', ''), '</Retorno>', '');
        RETURN;
    END;
END;
GO
