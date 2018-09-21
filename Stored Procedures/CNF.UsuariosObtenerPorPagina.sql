SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-24
-- Descripción:			Obtener Usuarios ordenados por Apellido, Nombre, Filtrado por Paginado
-- =============================================
CREATE PROCEDURE [CNF].[UsuariosObtenerPorPagina]
    @Pagina AS INT,
    @FilasPorPagina AS INT,
    @Buscar AS VARCHAR(30),
    @iError AS INT = -1 OUTPUT,
    @sError AS VARCHAR(MAX) = NULL OUTPUT,
    @Retorno AS VARCHAR(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    --		VARIABLES
    -- =============================================

    DECLARE @Parametros AS XML,
            @TipoEvento AS VARCHAR(50),
            @SP AS VARCHAR(255),
            @FilaInicial AS INT,
            @TotalRegistros AS INT,
            @TotalPaginas AS INT,
            @xmlUsuarios AS XML;
    DECLARE @Usuarios AS TABLE
    (
        Usuario VARCHAR(15),
        Nombre VARCHAR(100),
        Puesto VARCHAR(50),
        Perfil VARCHAR(50),
        IsActivo BIT
    );
    SELECT @Parametros =
    (
        SELECT @FilasPorPagina AS 'FilasPorPagina',
               @Pagina AS 'Pagina'
        FOR XML PATH('Parametros'), TYPE
    ),
           @iError = 0,
           @SP = 'CNF.UsuariosObtenerPorPagina';

    -- =============================================
    --		VALIDACIONES
    -- =============================================

    IF ISNULL(@FilasPorPagina, 0) = 0
       AND (@FilasPorPagina < 0)
    BEGIN
        SELECT @iError = 1,
               @sError
                   = 'Filas por pagina no indicado. Se debe indicar las filas por pagina a devolver, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;

    IF ISNULL(@Pagina, 0) = 0
       AND (@Pagina < 0)
    BEGIN
        SELECT @iError = 1,
               @sError
                   = 'No. de Pagina no indicada. Se debe indicar la pagina a devolver, por favor inténtelo de nuevo.',
               @TipoEvento = 'Error de Validación';
    END;

    -- =============================================
    --		PROCESO
    -- =============================================

    IF @iError = 0
    BEGIN
        SELECT @sError = 'Operación realizada con éxito';
        BEGIN TRY
            SELECT @TotalRegistros = COUNT(u.Usuario)
            FROM CNF.Usuarios AS u
            WHERE RTRIM(u.ApePaterno) + ' ' + RTRIM(u.ApeMaterno) + ', ' + RTRIM(u.Nombre) + ' ' + RTRIM(u.Usuario) LIKE '%'
                                                                                                                         + @Buscar
                                                                                                                         + '%';

            SELECT @TotalPaginas = CEILING(CAST(@TotalRegistros AS DECIMAL) / CAST(@FilasPorPagina AS DECIMAL));
            SELECT @Pagina = ((@Pagina + @TotalPaginas) - ABS(@Pagina - @TotalPaginas)) / 2;
            SELECT @FilaInicial = (@Pagina * @FilasPorPagina) - @FilasPorPagina;
            INSERT INTO @Usuarios
            (
                Usuario,
                Nombre,
                Puesto,
                Perfil,
                IsActivo
            )
            SELECT u.Usuario,
                   RTRIM(u.ApePaterno) + ' ' + RTRIM(u.ApeMaterno) + ', ' + RTRIM(u.Nombre) AS Nombre,
                   u.Puesto,
                   p.Perfil,
                   u.IsActivo
            FROM CNF.Usuarios AS u
                INNER JOIN CNF.Perfiles AS p
                    ON p.CvePerfil = u.CvePerfil
            WHERE RTRIM(u.ApePaterno) + ' ' + RTRIM(u.ApeMaterno) + ', ' + RTRIM(u.Nombre) + ' ' + RTRIM(u.Usuario) LIKE '%'
                                                                                                                         + @Buscar
                                                                                                                         + '%'
            ORDER BY u.ApePaterno,
                     u.ApeMaterno,
                     u.Nombre ASC OFFSET @FilaInicial ROWS FETCH NEXT @FilasPorPagina ROWS ONLY;
            SELECT @xmlUsuarios =
            (
                SELECT Fila.Usuario,
                       Fila.Nombre,
                       Fila.Puesto,
                       Fila.Perfil,
                       Fila.IsActivo
                FROM @Usuarios AS Fila
                FOR XML AUTO, ELEMENTS, TYPE
            );
            SELECT @Retorno = CAST(
            (
                SELECT @Pagina AS Pagina,
                       @TotalPaginas AS TotalPaginas,
                       @TotalRegistros AS TotalRegistros,
                       CAST(@xmlUsuarios AS VARCHAR(MAX)) AS Usuarios
                FOR XML PATH('Retorno'), ELEMENTS, TYPE
            )   AS VARCHAR(MAX));

            SELECT @Retorno = REPLACE(REPLACE(@Retorno, '&gt;', '>'), '&lt;', '<');
        END TRY
        BEGIN CATCH
            SELECT @Retorno = NULL,
                   @TipoEvento = 'Error',
                   @sError
                       = 'Error de Ejecución: ' + RTRIM(ISNULL(ERROR_NUMBER(), -1)) + ' | '
                         + RTRIM(ISNULL(ERROR_MESSAGE(), ''));
        END CATCH;
    END;
    IF @iError <> 0
    BEGIN
        EXEC dbo.LogEventosInsertar @SP = @SP,                 -- varchar(300)
                                    @Parametros = @Parametros, -- xml
                                    @Tipo = @TipoEvento,       -- varchar(50)
                                    @DescrEvento = @sError,    -- varchar(max)
                                    @sUsuario = NULL;
    END;
    RETURN;
END;
GO
