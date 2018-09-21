CREATE TABLE [CNF].[Usuarios]
(
[IdUsuario] [int] NOT NULL IDENTITY(1, 1),
[Usuario] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Contraseña] [varbinary] (max) NOT NULL,
[ApePaterno] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApeMaterno] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Nombre] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Puesto] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Correo] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CvePerfil] [uniqueidentifier] NOT NULL,
[IsActivo] [bit] NOT NULL,
[IsNuevaContraseña] [bit] NOT NULL,
[Registro] [datetime] NULL,
[UltimoAcceso] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [CNF].[Usuarios] ADD CONSTRAINT [PK_Usuarios] PRIMARY KEY CLUSTERED  ([IdUsuario]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Usuarios de Sistema de Verificación', 'SCHEMA', N'CNF', 'TABLE', N'Usuarios', NULL, NULL
GO
