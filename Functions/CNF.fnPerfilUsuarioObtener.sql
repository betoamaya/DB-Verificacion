SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-20
-- Descripción:			Obtener Perfil por Usuario
-- =============================================
CREATE FUNCTION [CNF].[fnPerfilUsuarioObtener] (@Usuario AS VARCHAR(15))
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Resultado AS VARCHAR(50) = NULL;
    SELECT @Resultado = p.Perfil
    FROM CNF.Usuarios AS u
        INNER JOIN CNF.Perfiles AS p
            ON p.CvePerfil = u.CvePerfil
    WHERE u.Usuario = RTRIM(@Usuario);
    RETURN @Resultado;
END;
GO
