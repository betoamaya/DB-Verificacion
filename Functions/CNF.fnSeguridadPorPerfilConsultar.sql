SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-02
-- Descripción:			Función para obtener la seguridad por Perfil
-- =============================================
CREATE FUNCTION [CNF].[fnSeguridadPorPerfilConsultar] (@Perfil AS VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT fmc.IdModulo,
           fmc.Modulo,
           fmc.DescrModulo,
           fmc.CveModulo,
           vspm.Perfil,
           ISNULL(vspm.IdSeguridad, 0) AS idSeguridad,
           ISNULL(vspm.IsLectura, 0) AS IsLectura,
           ISNULL(vspm.IsEdicion, 0) AS IsEdicion,
           ISNULL(vspm.IsConfiguracion, 0) AS IsConfiguracion,
           fmc.IdModuloPadre,
           fmc.OrdenPadre,
           fmc.Orden,
           fmc.IsActivo
    FROM CNF.fnModulosConsultar() AS fmc
        LEFT JOIN CNF.vwSeguridadPerfilesModulos AS vspm
            ON vspm.IdModulo = fmc.IdModulo
               AND vspm.Perfil = RTRIM(@Perfil)
);

GO
