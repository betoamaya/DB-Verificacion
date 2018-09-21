SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-08-07
-- Descripción:			Edición de Seguridad Por Perfil
-- =============================================
CREATE PROCEDURE [CNF].[SeguridadGuardar]
    @SeguridadPaquete AS VARCHAR(MAX),
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
            @Perfil AS VARCHAR(50),
            @IdPerfil AS INT,
            @Mensaje AS VARCHAR(MAX),
            @TipoEvento AS VARCHAR(50),
            @SP AS VARCHAR(255);
    DECLARE @tSeguridad AS TABLE
    (
        IdSeguridad INT,
        IdPerfil INT,
        IdModulo INT,
        CveModulo VARCHAR(30),
        IsLectura BIT,
        IsEdicion BIT,
        IsConfiguracion BIT
    );
    SELECT @Parametros =
    (
        SELECT @SeguridadPaquete AS 'Partidas',
               @UsuarioEdita AS 'UsuarioEdita'
        FOR XML PATH('Parametros')
    ),
           @iError = 0,
           @SP = 'CNF.SeguridadGuardar';
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
    IF (CNF.fnSeguridadUsuarioTieneNivelPermisoModulo(@UsuarioEdita, 'EditarSeguridad', 'Configurar') = 0)
    BEGIN
        SELECT @iError = -1,
               @sError = 'Usuario que edita no tiene privilegios para esta acción, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;

    IF (ISNULL(@SeguridadPaquete, '') = '')
    BEGIN
        SELECT @iError = -1,
               @sError = 'Parametro SeguridadPaquete vació, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;

    -- =============================================
    --		PROCESO
    -- =============================================

    IF @iError = 0
    BEGIN
        BEGIN TRY
            SELECT @XML = CAST(@SeguridadPaquete AS XML);
            SELECT @Perfil = Tbl.Col.value('Perfil[1]', 'varchar(50)')
            FROM @XML.nodes('//SeguridadPaquete')Tbl(Col);

            SELECT @sError = 'Se realizo con exito, la actualización del Perfil ' + RTRIM(ISNULL(@Perfil, '')),
                   @TipoEvento = 'Editar Seguridad';

            INSERT INTO @tSeguridad
            (
                IdModulo,
                CveModulo,
                IsLectura,
                IsEdicion,
                IsConfiguracion
            )
            SELECT m.IdModulo,
                   Tbl.Col.value('CveModulo[1]', 'varchar(30)'),
                   CASE
                       WHEN Tbl.Col.value('NivelPermiso[1]', 'int') >= 1 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN Tbl.Col.value('NivelPermiso[1]', 'int') >= 2 THEN
                           1
                       ELSE
                           0
                   END,
                   CASE
                       WHEN Tbl.Col.value('NivelPermiso[1]', 'int') >= 3 THEN
                           1
                       ELSE
                           0
                   END
            FROM @XML.nodes('//SeguridadPaquete/LstSeguridad/SeguridadListada')Tbl(Col)
                INNER JOIN CNF.Modulos AS m
                    ON m.CveModulo = Tbl.Col.value('CveModulo[1]', 'varchar(30)');

            SELECT @IdPerfil = p.IdPerfil
            FROM CNF.Perfiles AS p
            WHERE p.Perfil = @Perfil;
            /*Perfil*/
            UPDATE @tSeguridad
            SET IdPerfil = @IdPerfil
            WHERE CveModulo IS NOT NULL;
            /*IDSeguridad*/
            UPDATE ts
            SET ts.IdSeguridad = s.IdSeguridad
            FROM @tSeguridad AS ts
                INNER JOIN CNF.Seguridad AS s
                    ON s.IdModulo = ts.IdModulo
                       AND s.IdPerfil = ts.IdPerfil;

            MERGE CNF.Seguridad AS TARGET
            USING @tSeguridad AS SOURCE
            ON (TARGET.IdSeguridad = SOURCE.IdSeguridad)
            WHEN MATCHED AND TARGET.IsLectura <> SOURCE.IsLectura
                             OR TARGET.IsEdicion <> SOURCE.IsEdicion
                             OR TARGET.IsConfiguracion <> SOURCE.IsConfiguracion THEN
                UPDATE SET TARGET.IsLectura = SOURCE.IsLectura,
                           TARGET.IsEdicion = SOURCE.IsEdicion,
                           TARGET.IsConfiguracion = SOURCE.IsConfiguracion
            WHEN NOT MATCHED BY TARGET THEN
                INSERT
                (
                    IdPerfil,
                    IdModulo,
                    IsLectura,
                    IsEdicion,
                    IsConfiguracion
                )
                VALUES
                (SOURCE.IdPerfil, SOURCE.IdModulo, SOURCE.IsLectura, SOURCE.IsEdicion, SOURCE.IsConfiguracion);

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
