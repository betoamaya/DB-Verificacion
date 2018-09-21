CREATE TABLE [CNF].[Seguridad]
(
[IdSeguridad] [int] NOT NULL IDENTITY(1, 1),
[IdPerfil] [int] NOT NULL,
[IdModulo] [int] NOT NULL,
[IsLectura] [bit] NOT NULL,
[IsEdicion] [bit] NOT NULL,
[IsConfiguracion] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CNF].[Seguridad] ADD CONSTRAINT [PK_Permisos] PRIMARY KEY CLUSTERED  ([IdSeguridad]) ON [PRIMARY]
GO
ALTER TABLE [CNF].[Seguridad] ADD CONSTRAINT [FK_Permisos_Modulos] FOREIGN KEY ([IdModulo]) REFERENCES [CNF].[Modulos] ([IdModulo])
GO
ALTER TABLE [CNF].[Seguridad] ADD CONSTRAINT [FK_Permisos_Perfiles] FOREIGN KEY ([IdPerfil]) REFERENCES [CNF].[Perfiles] ([IdPerfil])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Tabla de Configuración de Seguridad del Sistema de Verificación', 'SCHEMA', N'CNF', 'TABLE', N'Seguridad', NULL, NULL
GO
