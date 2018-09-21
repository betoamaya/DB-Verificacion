IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'VeriWeb')
CREATE LOGIN [VeriWeb] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [VeriWeb] FOR LOGIN [VeriWeb]
GO
