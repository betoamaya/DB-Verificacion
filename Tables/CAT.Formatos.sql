CREATE TABLE [CAT].[Formatos]
(
[IdFormato] [int] NOT NULL IDENTITY(1, 1),
[IdLista] [int] NOT NULL,
[Version] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Notas] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Registro] [datetime] NULL,
[UsrRegistro] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UltimaMod] [datetime] NULL,
[UsrEdita] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsEditable] [bit] NOT NULL,
[IsActivo] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CAT].[Formatos] ADD CONSTRAINT [PK_Formatos] PRIMARY KEY CLUSTERED  ([IdFormato]) ON [PRIMARY]
GO
ALTER TABLE [CAT].[Formatos] ADD CONSTRAINT [FK_Formatos_Listas] FOREIGN KEY ([IdLista]) REFERENCES [CAT].[Listas] ([IdLista])
GO
