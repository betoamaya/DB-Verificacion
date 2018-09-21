CREATE TABLE [CAT].[Listas]
(
[IdLista] [int] NOT NULL IDENTITY(1, 1),
[Lista] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VersionFmto] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Registro] [datetime] NULL,
[UsrRegistro] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UltimaMod] [datetime] NULL,
[UsrEdita] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActivo] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CAT].[Listas] ADD CONSTRAINT [PK_Listas] PRIMARY KEY CLUSTERED  ([IdLista]) ON [PRIMARY]
GO
