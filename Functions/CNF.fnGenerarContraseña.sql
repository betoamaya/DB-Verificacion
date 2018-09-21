SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-07
-- Descripción:			función para generar Contraseñas Aleatorias.
-- =============================================
CREATE FUNCTION [CNF].[fnGenerarContraseña]
(
    @Tamaño AS INT,
    @Op AS VARCHAR(2)
)
RETURNS VARCHAR(62)
AS
BEGIN

    DECLARE @chars AS VARCHAR(104),
            @numbers AS VARCHAR(10),
            @strChars AS VARCHAR(62),
            @strPass AS VARCHAR(62),
            @index AS INT,
            @cont AS INT;

    SET @strPass = '';
    SET @strChars = '';
    SET @chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    SET @numbers = '0123456789';

    SET @strChars = CASE @Op
                        WHEN 'C' THEN
                            @chars            --Letras
                        WHEN 'N' THEN
                            @numbers          --Números
                        WHEN 'CN' THEN
                            @chars + @numbers --Ambos (Letras y Números)
                        ELSE
                            '------'
                    END;

    SET @cont = 0;
    WHILE @cont < @Tamaño
    BEGIN
        SET @index = CEILING(
                                (
                                    SELECT vr.Rnd FROM CNF.vwRnd AS vr
                                ) * (LEN(@strChars))
                            ); --Uso de la vista para el Rand() y no generar error.
        SET @strPass = @strPass + SUBSTRING(@strChars, @index, 1);
        SET @cont = @cont + 1;
    END;

    RETURN @strPass;

END;
GO
