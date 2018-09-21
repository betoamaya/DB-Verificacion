SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-31
-- Descripción:			Obtener Lista por Nombre
-- =============================================
CREATE PROCEDURE [CAT].[ListaObtenerPorNombreXml]
    @Lista AS VARCHAR(50),
    @IsActivo AS BIT = 1,
    @Retorno AS VARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PerfilesAsignados AS VARCHAR(MAX);

    IF ISNULL(@Lista, '') = ''
    BEGIN
        SET @Lista = NULL;
    END;
    SELECT @Retorno
        = CAST(
    (
        SELECT l.IdLista,
               l.Lista AS 'NombreLista',
               l.Descr AS 'DescrLista',
               l.VersionFmto AS 'VersionVigente',
               ISNULL(CONVERT(VARCHAR, l.Registro, 103) + ' ' + CONVERT(VARCHAR, l.Registro, 108), '') AS 'FechaRegistro',
               l.UsrRegistro AS 'UsuarioRegistro',
               ISNULL(CONVERT(VARCHAR, l.UltimaMod, 103) + ' ' + CONVERT(VARCHAR, l.UltimaMod, 108), '') AS 'UltimaModificacion',
               ISNULL(l.UsrEdita, '') AS 'UsuarioEdita',
               l.IsActivo,
               ISNULL(
               (
                   SELECT f.IdFormato,
                          l.VersionFmto,
                          f.Notas,
                          f.UltimaMod,
                          f.UsrEdita,
                          f.IsEditable,
                          f.IsActivo
                   FROM CAT.Formatos AS f
                   WHERE f.IdLista = l.IdLista
                   FOR XML RAW, ELEMENTS, TYPE
               ),
               ''
                     ) AS LstFormatos,
    (
        SELECT apl.IdAsignacion,
               p.Perfil,
               apl.IsActivo AS 'IsAsignado'
        FROM dbo.AsignacionPerfilLista AS apl
            INNER JOIN CNF.Perfiles AS p
                ON p.IdPerfil = apl.IdPerfil
        FOR XML RAW, ELEMENTS, TYPE
    )          AS 'PerfilesAsignados'
        FROM CAT.Listas AS l
        WHERE l.Lista = ISNULL(@Lista, l.Lista)
        FOR XML PATH('Lista'), ELEMENTS, TYPE
    )   AS VARCHAR(MAX));
END;
GO
