SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-09
-- Descripción:			funcion, para generar datos para correo
-- =============================================
CREATE FUNCTION [CNF].[fnGenerarMensajeHTML]
(
    @Tipo AS VARCHAR(50),
    @Opc1 AS VARCHAR(100) = NULL,
    @Opc2 AS VARCHAR(100) = NULL,
    @Opc3 AS VARCHAR(100) = NULL,
    @Opc4 AS VARCHAR(100) = NULL
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @Resultado AS VARCHAR(MAX);

    SELECT @Resultado = cc.CuerpoHTML
    FROM CNF.CatCorreos AS cc
    WHERE cc.Tipo = @Tipo;

    SELECT @Resultado
        = CASE
              WHEN @Tipo = 'Alta Usuario' THEN
                  REPLACE(
                             REPLACE(
                                        REPLACE(@Resultado, '«Nombre»', RTRIM(ISNULL(@Opc1, 'Sin Nombre'))),
                                        '«Usuario»',
                                        RTRIM(ISNULL(@Opc2, 'Sin Usuario'))
                                    ),
                             '«Contraseña»',
                             RTRIM(ISNULL(@Opc3, 'Sin Contraseña'))
                         )
              WHEN @Tipo = 'Editar Contraseña' THEN
                  REPLACE(
                             REPLACE(@Resultado, '«Nombre»', RTRIM(ISNULL(@Opc1, 'Sin Nombre'))),
                             '«Usuario»',
                             RTRIM(ISNULL(@Opc2, 'Sin Usuario'))
                         )
              ELSE
                  'Ocurrio un error al generar el codigo de este correo, favor de contactar al servicedesk@transpais.com.mx'
          END;

    RETURN @Resultado;
END;
GO
