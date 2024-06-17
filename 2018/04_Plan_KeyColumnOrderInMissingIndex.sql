--https://dba.stackexchange.com/questions/208947/how-does-sql-server-determine-key-column-order-in-missing-index-requests

use SqlSat
go

-----------------------------------------
--Tables creation
-----------------------------------------
drop table if exists dbo.NumberLetterDate
go

CREATE TABLE dbo.NumberLetterDate (
	ID INT IDENTITY(1,1) PRIMARY KEY CLUSTERED, 
	OrderID INT, 
	Description NVARCHAR(100), 
	LastEdited DATETIME, 
	Note NVARCHAR(MAX));
GO

drop table if exists dbo.LetterDateNumber
go

CREATE TABLE dbo.LetterDateNumber (
	ID INT IDENTITY(1,1) PRIMARY KEY CLUSTERED, 
	Description NVARCHAR(100), 
	LastEdited DATETIME, 
	OrderID INT, 
	Note NVARCHAR(MAX));
GO

drop table if exists dbo.DateNumberLetter
go

CREATE TABLE dbo.DateNumberLetter (
	ID INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
	LastEdited DATETIME, 
	OrderID INT, 
	Description NVARCHAR(100), 
	Note NVARCHAR(MAX));
GO

--Fill with Data
insert into dbo.NumberLetterDate (OrderID, Description, LastEdited, Note)
select SalesOrderID, CarrierTrackingNumber, ModifiedDate, cast(rowguid as nvarchar(max))
from AdventureWorks2017.Sales.SalesOrderDetail
go

insert into dbo.LetterDateNumber (Description, LastEdited, OrderID, Note)
select CarrierTrackingNumber, ModifiedDate, SalesOrderID, cast(rowguid as nvarchar(max))
from AdventureWorks2017.Sales.SalesOrderDetail
go

insert into dbo.DateNumberLetter (LastEdited, OrderID, Description, Note)
select ModifiedDate, SalesOrderID, CarrierTrackingNumber, cast(rowguid as nvarchar(max))
from AdventureWorks2017.Sales.SalesOrderDetail
go


--Query that need filter. Equal conditions. The column's order does not appear to depend on selectivity
SELECT ID
  FROM dbo.NumberLetterDate
  WHERE OrderID = 100
  AND Description = 'SqlSaturday'
  AND LastEdited = GetDate()
  AND 1 = (SELECT 1);

SELECT ID
  FROM dbo.LetterDateNumber
  WHERE OrderID = 100
  AND Description = 'SqlSaturday'
  AND LastEdited = GetDate()
  AND 1 = (SELECT 1);

SELECT ID
  FROM dbo.DateNumberLetter
  WHERE OrderID = 100
  AND Description = 'SqlSaturday'
  AND LastEdited = GetDate()
  AND 1 = (SELECT 1);
GO

--Inequality filter. Equelity filters go first in order of definition; Inequality filters go at the end
SELECT ID
  FROM dbo.NumberLetterDate
  WHERE OrderID <> 100
  AND Description = 'SqlSaturday'
  AND LastEdited = GetDate()
  AND 1 = (SELECT 1);

SELECT ID
  FROM dbo.LetterDateNumber
  WHERE OrderID <> 100
  AND Description = 'SqlSaturday'
  AND LastEdited = GetDate()
  AND 1 = (SELECT 1);

SELECT ID
  FROM dbo.DateNumberLetter
  WHERE OrderID <> 100
  AND Description = 'SqlSaturday'
  AND LastEdited = GetDate()
  AND 1 = (SELECT 1);
GO

--Only inequelity filters. We are back as in the first example
SELECT ID
  FROM dbo.NumberLetterDate
  WHERE OrderID <> 100
  AND Description <> 'SqlSaturday'
  AND LastEdited <> GetDate()
  AND 1 = (SELECT 1);

SELECT ID
  FROM dbo.LetterDateNumber
  WHERE OrderID <> 100
  AND Description <> 'SqlSaturday'
  AND LastEdited <> GetDate()
  AND 1 = (SELECT 1);

SELECT ID
  FROM dbo.DateNumberLetter
  WHERE OrderID <> 100
  AND Description <> 'SqlSaturday'
  AND LastEdited <> GetDate()
  AND 1 = (SELECT 1);
GO


