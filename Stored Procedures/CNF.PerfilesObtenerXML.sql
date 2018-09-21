SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-31
-- Descripción:			Obtener Perfiles de  Usuario activos
-- =============================================
CREATE PROCEDURE [CNF].[PerfilesObtenerXML]
    @Perfil AS VARCHAR(50),
    @IsActivo AS BIT = 1,
    @Retorno AS VARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    IF @Perfil = ''
    BEGIN
        SET @Perfil = NULL;
    END;
    IF @IsActivo = 0
    BEGIN
        SET @IsActivo = NULL;
    END;

    SELECT @Retorno = CAST(
    (
        SELECT p.IdPerfil,
               p.Perfil,
               p.IsActivo
        FROM CNF.Perfiles AS p
        WHERE p.IsActivo = ISNULL(@IsActivo, p.IsActivo)
              AND p.Perfil = ISNULL(@Perfil, p.Perfil)
        ORDER BY p.Perfil ASC
        FOR XML RAW, ELEMENTS, TYPE
    )   AS VARCHAR(MAX));
    SELECT @Retorno = CAST(
    (
        SELECT @Retorno AS 'Perfiles' FOR XML PATH('Retorno'), ELEMENTS, TYPE
    )   AS VARCHAR(MAX));
    SELECT @Retorno = REPLACE(REPLACE(@Retorno, '&gt;', '>'), '&lt;', '<');
    SELECT @Retorno = REPLACE(REPLACE(@Retorno, '<Retorno>', ''), '</Retorno>', '');
    RETURN;
END;
GO
