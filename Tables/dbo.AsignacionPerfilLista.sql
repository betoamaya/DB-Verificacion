CREATE TABLE [dbo].[AsignacionPerfilLista]
(
[IdAsignacion] [int] NOT NULL IDENTITY(1, 1),
[IdLista] [int] NOT NULL,
[IdPerfil] [int] NOT NULL,
[IsActivo] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AsignacionPerfilLista] ADD CONSTRAINT [PK_AsignacionPerfilLista] PRIMARY KEY CLUSTERED  ([IdAsignacion]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AsignacionPerfilLista] ADD CONSTRAINT [FK_AsignacionPerfilLista_Listas] FOREIGN KEY ([IdLista]) REFERENCES [CAT].[Listas] ([IdLista])
GO
ALTER TABLE [dbo].[AsignacionPerfilLista] ADD CONSTRAINT [FK_AsignacionPerfilLista_Perfiles] FOREIGN KEY ([IdPerfil]) REFERENCES [CNF].[Perfiles] ([IdPerfil])
GO
