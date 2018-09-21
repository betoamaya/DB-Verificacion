SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-18
-- Descripción:			Obtener Seguridad por Usuario y Modulo
-- =============================================
CREATE FUNCTION [CNF].[fnSeguridadUsuarioModuloObtener]
(
    @Usuario AS VARCHAR(15),
    @CveModulo AS VARCHAR(15)
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Resultado AS VARCHAR(20);
    SELECT @Resultado = (CASE
                             WHEN s.IsConfiguracion = 1 THEN
                                 'Configurar'
                             WHEN s.IsEdicion = 1 THEN
                                 'Editar'
                             WHEN s.IsLectura = 1 THEN
                                 'Lectura'
                             ELSE
                                 'SinAcceso'
                         END
                        )
    FROM CNF.Seguridad AS s
        INNER JOIN CNF.Modulos AS m
            ON m.IdModulo = s.IdModulo
        INNER JOIN CNF.Perfiles AS p
            ON p.IdPerfil = s.IdPerfil
               AND p.IsActivo = 1
    WHERE p.Perfil = CNF.fnPerfilUsuarioObtener(@Usuario)
          AND m.CveModulo = @CveModulo;
    IF @Resultado IS NULL
    BEGIN
        SELECT @Resultado = 'SinAcceso';
    END;
    RETURN @Resultado;
END;
GO
