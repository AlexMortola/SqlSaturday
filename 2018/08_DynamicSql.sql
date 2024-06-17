use SqlSat
GO

IF OBJECT_ID('Table1') IS NOT NULL
	DROP TABLE Table1
GO

CREATE TABLE Table1 (Id INT IDENTITY(1,1), ImportoDovuto DECIMAL(18,2), ImportoTotale DECIMAL(18,2))
GO

insert into Table1 VALUES 
(10, 150),
(15, 200),
(20, 250)
GO

--Verify...
select * from Table1
go


DECLARE @Sql NVARCHAR(4000)
DECLARE @FattoreCorrettivo DECIMAL(18,2)
SET @FattoreCorrettivo = 100

SET @Sql = 'UPDATE Table1 set ImportoDovuto = ImportoTotale + ' + CONVERT(VARCHAR(10), @FattoreCorrettivo) + ' WHERE Id = 1 '

BEGIN TRAN

EXEC sp_executeSql @Sql

--select * from Table1

ROLLBACK

PRINT @Sql




---------------------------------------------------------------------------------------------------------------------------

DECLARE @SqlUpd NVARCHAR(4000)
DECLARE @ParamDefinition NVARCHAR(100) = '@FattoreCorrettivo DECIMAL(18,2)'

SET @SqlUpd = 'UPDATE Table1 set ImportoDovuto = ImportoTotale + @FattoreCorrettivo WHERE Id = 1 '

BEGIN TRAN

EXEC sp_executeSql @SqlUpd, @ParamDefinition, @FattoreCorrettivo = 100

select * from Table1

ROLLBACK