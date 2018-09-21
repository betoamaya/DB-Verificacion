SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-30
-- Descripción:			Obtener Listas
-- =============================================
CREATE PROCEDURE [CAT].[ListasObenerXML]
    @Lista AS VARCHAR(30) = NULL,
    @IsActivo AS BIT = NULL,
    @Retorno AS VARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Lista = ''
    BEGIN
        SET @Lista = NULL;
    END;
    IF @IsActivo = 0
    BEGIN
        SET @IsActivo = NULL;
    END;
    SELECT @Retorno
        = CAST(
    (
        SELECT l.IdLista,
               l.Lista,
               ISNULL(
                         CONVERT(VARCHAR, l.UltimaMod, 103) + ' ' + CONVERT(VARCHAR, l.UltimaMod, 108),
                         CONVERT(VARCHAR, l.Registro, 103) + ' ' + CONVERT(VARCHAR, l.Registro, 108)
                     ) AS UltimaMod,
               l.IsActivo
        FROM CAT.Listas AS l
        WHERE l.Lista = ISNULL(@Lista, l.Lista)
              AND l.IsActivo = ISNULL(@IsActivo, l.IsActivo)
        ORDER BY l.Lista ASC
        FOR XML RAW, ELEMENTS, TYPE
    )   AS VARCHAR(MAX));
    SELECT @Retorno = CAST(
    (
        SELECT @Retorno AS 'Listas' FOR XML PATH('Retorno'), ELEMENTS, TYPE
    )   AS VARCHAR(MAX));
    SELECT @Retorno = REPLACE(REPLACE(@Retorno, '&gt;', '>'), '&lt;', '<');
    SELECT @Retorno = REPLACE(REPLACE(@Retorno, '<Retorno>', ''), '</Retorno>', '');
    IF @Retorno = '<Retorno/>'
    BEGIN
        SET @Retorno = NULL;
    END;
    RETURN;
END;
GO
