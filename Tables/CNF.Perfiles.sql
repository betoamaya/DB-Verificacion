CREATE TABLE [CNF].[Perfiles]
(
[IdPerfil] [int] NOT NULL IDENTITY(1, 1),
[Perfil] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CvePerfil] [uniqueidentifier] NOT NULL,
[IsActivo] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CNF].[Perfiles] ADD CONSTRAINT [PK_Perfiles] PRIMARY KEY CLUSTERED  ([IdPerfil]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tabla de Perfiles del Sistema de Verificación', 'SCHEMA', N'CNF', 'TABLE', N'Perfiles', NULL, NULL
GO
