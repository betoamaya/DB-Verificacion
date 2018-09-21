SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Roberto Amaya
-- Update:		2018-09-21
-- Description:	Registrar registros en Log de Eventos
-- =============================================
CREATE PROCEDURE [dbo].[LogEventosInsertar]
    @SP AS VARCHAR(300),
    @Parametros AS XML,
    @Tipo AS VARCHAR(50),
    @DescrEvento AS VARCHAR(MAX),
    @sUsuario AS VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.LogEventos
    (
        Registro,
        SP,
        Parametros,
        TipoEvento,
        DescrEvento,
        Usuario,
        SqlUser,
        SqlHost
    )
    VALUES
    (GETDATE(), @SP, @Parametros, @Tipo, @DescrEvento, @sUsuario, USER_NAME(), HOST_NAME());
END;

GO
