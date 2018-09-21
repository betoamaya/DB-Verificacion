CREATE TABLE [CAT].[Preguntas]
(
[IdPgta] [int] NOT NULL IDENTITY(1, 1),
[IdSgto] [int] NOT NULL,
[Pregunta] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdRpta] [int] NOT NULL,
[Orden] [int] NOT NULL,
[IsActivo] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CAT].[Preguntas] ADD CONSTRAINT [PK_Preguntas] PRIMARY KEY CLUSTERED  ([IdPgta]) ON [PRIMARY]
GO
ALTER TABLE [CAT].[Preguntas] ADD CONSTRAINT [FK_Preguntas_Rptas] FOREIGN KEY ([IdRpta]) REFERENCES [CAT].[Rptas] ([IdRpta])
GO
ALTER TABLE [CAT].[Preguntas] ADD CONSTRAINT [FK_Preguntas_Segmentos] FOREIGN KEY ([IdSgto]) REFERENCES [CAT].[Segmentos] ([IdSgto])
GO
