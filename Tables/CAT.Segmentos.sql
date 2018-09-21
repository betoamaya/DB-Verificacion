CREATE TABLE [CAT].[Segmentos]
(
[IdSgto] [int] NOT NULL IDENTITY(1, 1),
[IdFrmto] [int] NOT NULL,
[Titulo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SgtoPadre] [int] NULL,
[Orden] [int] NOT NULL,
[IsActivo] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CAT].[Segmentos] ADD CONSTRAINT [PK_Segmentos] PRIMARY KEY CLUSTERED  ([IdSgto]) ON [PRIMARY]
GO
ALTER TABLE [CAT].[Segmentos] ADD CONSTRAINT [FK_Segmentos_Formatos] FOREIGN KEY ([IdFrmto]) REFERENCES [CAT].[Formatos] ([IdFormato])
GO
