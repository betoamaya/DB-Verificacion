IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'VeriSys')
CREATE LOGIN [VeriSys] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [VeriSys] FOR LOGIN [VeriSys]
GO
