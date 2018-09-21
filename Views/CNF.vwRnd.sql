SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-07
-- Descripción:			Vista para generar valores Aleatorios.
-- =============================================
CREATE VIEW [CNF].[vwRnd]
AS
SELECT RAND() AS Rnd;
GO
