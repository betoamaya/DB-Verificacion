CREATE TABLE [CNF].[Modulos]
(
[IdModulo] [int] NOT NULL IDENTITY(1, 1),
[Modulo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DescrModulo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CveModulo] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IdModuloPadre] [int] NULL,
[Orden] [int] NOT NULL,
[IsActivo] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CNF].[Modulos] ADD CONSTRAINT [PK_Modulos] PRIMARY KEY CLUSTERED  ([IdModulo]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tabla de Modulos del Sistema de Verificación', 'SCHEMA', N'CNF', 'TABLE', N'Modulos', NULL, NULL
GO
