CREATE TABLE [CAT].[Rptas]
(
[IdRpta] [int] NOT NULL IDENTITY(1, 1),
[TipoRespuesta] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TipoEntrada] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Registro] [datetime] NULL,
[UsrRegistro] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActivo] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CAT].[Rptas] ADD CONSTRAINT [PK_Rptas] PRIMARY KEY CLUSTERED  ([IdRpta]) ON [PRIMARY]
GO
