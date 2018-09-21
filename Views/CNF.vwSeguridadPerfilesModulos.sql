SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-19
-- Descripción:			Vista de la  tabla de Seguridad con descripción de Perfiles y de Modulos.
-- =============================================
CREATE VIEW [CNF].[vwSeguridadPerfilesModulos]
AS
SELECT s.IdSeguridad,
       s.IdPerfil,
       p.Perfil,
       s.IdModulo,
       m.CveModulo,
       s.IsLectura,
       s.IsEdicion,
       s.IsConfiguracion
FROM CNF.Seguridad AS s
    INNER JOIN CNF.Perfiles AS p
        ON p.IdPerfil = s.IdPerfil
    INNER JOIN CNF.Modulos AS m
        ON m.IdModulo = s.IdModulo;
GO
