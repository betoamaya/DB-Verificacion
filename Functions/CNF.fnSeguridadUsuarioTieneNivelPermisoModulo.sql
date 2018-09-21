SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-23
-- Descripción:			Validar si el Usuario tiene el nivel requerido de acceso al Modulo
-- =============================================
CREATE FUNCTION [CNF].[fnSeguridadUsuarioTieneNivelPermisoModulo]
(
    @Usuario AS VARCHAR(15),
    @CveModulo AS VARCHAR(30),
    @NivelRequerido AS VARCHAR(20)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Nivel AS INT,
            @Resultado AS BIT;
    SELECT @Nivel = CASE
                        WHEN @NivelRequerido = 'Configurar' THEN
                            3
                        WHEN @NivelRequerido = 'Editar' THEN
                            2
                        WHEN @NivelRequerido = 'Leer' THEN
                            1
                        ELSE
                            4
                    END;
    IF
    (
        SELECT TOP 1
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
              AND fsppc.CveModulo = @CveModulo
    ) >= @Nivel
    BEGIN
        SELECT @Resultado = 1;
    END;
    ELSE
    BEGIN
        SELECT @Resultado = 0;
    END;
    RETURN @Resultado;
END;
GO
