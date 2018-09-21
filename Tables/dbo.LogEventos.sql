CREATE TABLE [dbo].[LogEventos]
(
[IdEvento] [int] NOT NULL IDENTITY(1, 1),
[Registro] [datetime] NOT NULL,
[SP] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Parametros] [xml] NOT NULL,
[TipoEvento] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DescrEvento] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Usuario] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlUser] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlHost] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[LogEventos] ADD CONSTRAINT [PK_LogEventos] PRIMARY KEY CLUSTERED  ([IdEvento]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tabla de Eventos del sistema de Verificación', 'SCHEMA', N'dbo', 'TABLE', N'LogEventos', NULL, NULL
GO
