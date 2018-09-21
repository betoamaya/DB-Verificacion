SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-19
-- Descripción:			obtener Seguridad por Perfiles de Usuario
-- =============================================
CREATE FUNCTION [CNF].[fnModulosConsultar] ()
RETURNS TABLE
AS
RETURN
(
    WITH CnsModulos
    AS (SELECT Padre.IdModulo,
               Padre.Modulo,
               Padre.DescrModulo,
               Padre.CveModulo,
               Padre.IsActivo,
               Padre.IdModuloPadre,
               0 AS Orden,
               Padre.Orden AS OrdenPadre
        FROM CNF.Modulos AS Padre
        WHERE Padre.IdModuloPadre IS NULL
        UNION ALL
        SELECT Hijo.IdModulo,
               Hijo.Modulo,
               Hijo.DescrModulo,
               Hijo.CveModulo,
               Hijo.IsActivo,
               Hijo.IdModuloPadre,
               Hijo.Orden,
               cm.OrdenPadre
        FROM CNF.Modulos AS Hijo
            INNER JOIN CnsModulos AS cm
                ON cm.IdModulo = Hijo.IdModuloPadre
       )
    SELECT cm.IdModulo,
           cm.Modulo,
           cm.DescrModulo,
           cm.CveModulo,
           cm.IsActivo,
           cm.IdModuloPadre,
           cm.OrdenPadre,
           cm.Orden
    FROM CnsModulos AS cm
);
GO
