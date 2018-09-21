CREATE TABLE [CAT].[RptasValores]
(
[IdValores] [int] NOT NULL IDENTITY(1, 1),
[IdRpta] [int] NOT NULL,
[Valor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsActivo] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CAT].[RptasValores] ADD CONSTRAINT [PK_RptasValores] PRIMARY KEY CLUSTERED  ([IdValores]) ON [PRIMARY]
GO
ALTER TABLE [CAT].[RptasValores] ADD CONSTRAINT [FK_RptasValores_Rptas] FOREIGN KEY ([IdRpta]) REFERENCES [CAT].[Rptas] ([IdRpta])
GO
