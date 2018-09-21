SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-31
-- Descripción:			Guardar Lista
-- =============================================
CREATE PROCEDURE [CAT].[ListaGuardar]
    @ListaPaquete AS VARCHAR(MAX),
    @UsuarioEdita AS VARCHAR(15),
    @iError AS INT = NULL OUTPUT,
    @sError AS VARCHAR(MAX) = NULL OUTPUT
AS
BEGIN

    SET NOCOUNT ON;
    -- =============================================
    --		VARIABLES
    -- =============================================

    DECLARE @Parametros AS XML,
            @XML AS XML,
            @Lista AS VARCHAR(50),
            @IdPerfil AS INT,
            @IdLista AS INT,
            @Mensaje AS VARCHAR(MAX),
            @TipoEvento AS VARCHAR(50),
            @SP AS VARCHAR(255);

    DECLARE @tLista AS TABLE
    (
        IdLista INT,
        NombreLista VARCHAR(30),
        Descr VARCHAR(100),
        VersionFmto VARCHAR(30),
        IsActivo BIT
    );

    DECLARE @tAsignacion AS TABLE
    (
        IdLista INT,
        IdAsignacion INT,
        IdPerfil INT,
        Perfil VARCHAR(50),
        IsActivo BIT
    );

    SELECT @Parametros =
    (
        SELECT @ListaPaquete AS 'ListaPaquete',
               @UsuarioEdita AS 'UsuarioEdita'
        FOR XML PATH('Parametros')
    ),
           @iError = 0,
           @SP = 'CAT.ListaGuardar';
    -- =============================================
    --		VALIDACIONES
    -- =============================================
    IF ISNULL(@UsuarioEdita, '') = ''
       OR NOT EXISTS
    (
        SELECT u.Usuario
        FROM CNF.Usuarios AS u
        WHERE u.Usuario = RTRIM(@UsuarioEdita)
              AND u.IsActivo = 1
    )
    BEGIN
        SELECT @iError = -1,
               @sError = 'Usuario que edita nulo o no es válido, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    IF (CNF.fnSeguridadUsuarioTieneNivelPermisoModulo(@UsuarioEdita, 'EditarLista', 'Editar') = 0)
    BEGIN
        SELECT @iError = -1,
               @sError = 'Usuario que edita no tiene privilegios para esta acción, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;

    IF (ISNULL(@ListaPaquete, '') = '')
    BEGIN
        SELECT @iError = -1,
               @sError = 'Parametro ListaPaquete vació, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;
    -- =============================================
    --		PROCESO
    -- =============================================

    IF @iError = 0
    BEGIN
        BEGIN TRY
            SELECT @XML = CAST(@ListaPaquete AS XML);

            INSERT INTO @tLista
            (
                IdLista,
                NombreLista,
                Descr,
                VersionFmto,
                IsActivo
            )
            SELECT Tbl.col.value('IdLista[1]', 'int'),
                   Tbl.col.value('NombreLista[1]', 'Varchar(30)'),
                   Tbl.col.value('DescrLista[1]', 'Varchar(100)'),
                   Tbl.col.value('VersionVigente[1]', 'Varchar(30)'),
                   Tbl.col.value('IsActivo[1]', 'bit')
            FROM @XML.nodes('//Lista')Tbl(col);

            INSERT INTO @tAsignacion
            (
                IdAsignacion,
                Perfil,
                IsActivo
            )
            SELECT Tbl.col.value('IdAsignacion[1]', 'int'),
                   Tbl.col.value('Perfil[1]', 'Varchar(50)'),
                   Tbl.col.value('IsAsignado[1]', 'bit')
            FROM @XML.nodes('//Lista/PerfilesAsignados/row')Tbl(col);

			IF EXISTS(SELECT TOP 1  tl.VersionFmto FROM @tLista AS tl WHERE ISNULL(tl.VersionFmto, '') = '' AND tl.IsActivo = 1)
			BEGIN
			    SET @sError = 'Se debe seleccionar una Versión Vigente antes de activar la Lista.'
				RAISERROR(@sError, 16, 1);
			END

            SELECT TOP 1
                @Lista = tl.NombreLista
            FROM @tLista AS tl;

            MERGE CAT.Listas AS Target
            USING @tLista AS Source
            ON Target.Lista = Source.NombreLista
            WHEN MATCHED AND Target.Descr <> Source.Descr
                             AND Target.VersionFmto <> Source.VersionFmto
                             AND Target.IsActivo <> Source.IsActivo THEN
                UPDATE SET Target.Descr = Source.Descr,
                           Target.VersionFmto = Source.VersionFmto,
                           Target.UltimaMod = GETDATE(),
                           Target.UsrEdita = @UsuarioEdita,
                           Target.IsActivo = Source.IsActivo
            WHEN NOT MATCHED BY TARGET THEN
                INSERT
                (
                    Lista,
                    Descr,
                    VersionFmto,
                    Registro,
                    UsrRegistro,
                    IsActivo
                )
                VALUES
                (Source.NombreLista, Source.Descr, Source.VersionFmto, GETDATE(), @UsuarioEdita, Source.IsActivo);

            SELECT TOP 1
                @IdLista = l.IdLista
            FROM CAT.Listas AS l
            WHERE l.Lista = @Lista;

            UPDATE ta
            SET ta.IdPerfil = p.IdPerfil,
                ta.IdLista = @IdLista
            FROM CNF.Perfiles AS p
                INNER JOIN @tAsignacion AS ta
                    ON ta.Perfil = p.Perfil;

            MERGE dbo.AsignacionPerfilLista AS Target
            USING @tAsignacion AS Source
            ON Target.IdLista = Source.IdLista
               AND Target.IdPerfil = Source.IdPerfil
            WHEN MATCHED AND Target.IsActivo <> Source.IsActivo THEN
                UPDATE SET Target.IsActivo = Source.IsActivo
            WHEN NOT MATCHED BY TARGET THEN
                INSERT
                (
                    IdLista,
                    IdPerfil,
                    IsActivo
                )
                VALUES
                (Source.IdLista, Source.IdPerfil, Source.IsActivo);

            SELECT @sError = 'Se realizo con exito, la actualización de la Lista ' + RTRIM(ISNULL(@Lista, '')),
                   @TipoEvento = 'Editar Lista';

        END TRY
        BEGIN CATCH
            SELECT @iError = ISNULL(ERROR_NUMBER(), 1),
                   @sError = ISNULL(ERROR_MESSAGE(), 'Error no Identificado, contacte a Service Desk.');
            SELECT @TipoEvento = 'Error',
                   @Mensaje = 'Error de Ejecución: ' + RTRIM(@iError) + ' | ' + RTRIM(@sError);
        END CATCH;
    END;
    -- =============================================
    --		RETORNO
    -- =============================================
    EXEC dbo.LogEventosInsertar @SP = @SP,                 -- varchar(300)
                                @Parametros = @Parametros, -- xml
                                @Tipo = @TipoEvento,       -- varchar(50)
                                @DescrEvento = @sError,    -- varchar(max)
                                @sUsuario = @UsuarioEdita; -- varchar(50)
    RETURN;
END;
GO
