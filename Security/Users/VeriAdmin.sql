IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'VeriAdmin')
CREATE LOGIN [VeriAdmin] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [VeriAdmin] FOR LOGIN [VeriAdmin]
GO
