------------------------------------------------------------------------
-- Event:        SQL Saturday #895 Parma, November 23 2019             -
--               https://www.sqlsaturday.com/895/eventhome.aspx        -
-- Session:      Query tuning with hypothetical indexes                -
-- Demo:         Hypothetical 3 - Hypothetical indexes at work         -
-- Author:       Alessandro Mortola                                    -
-- Notes:        --                                                    -
------------------------------------------------------------------------

/* Doorstop */
raiserror(N'Did you mean to run the whole thing?',20,1) with log;
go


use TestDb;
go

--Praparazione dati

drop table if exists OrderHeader;
drop table if exists OrderDetail;

select * 
into OrderHeader
from AdventureWorks.Sales.SalesOrderHeader;

select * 
into OrderDetail
from AdventureWorks.Sales.SalesOrderDetail;
go

--Create the PK
alter table OrderHeader add constraint PK_OrderHeader primary key (SalesOrderID);
alter table OrderDetail add constraint PK_OrderDetail primary key (SalesOrderDetailID);


--Activate Actual execution plan

select h.SalesOrderID, h.OrderDate, h.CustomerID, d.ProductID, d.OrderQty
from OrderHeader h
inner join OrderDetail d on h.SalesOrderID = d.SalesOrderID
where OrderDate = '20130927'; 
go

--Deactivate Actual execution plan

CREATE NONCLUSTERED INDEX Idx_OrderHeader_OrderDate
ON [dbo].[OrderHeader] ([OrderDate])
with statistics_only = -1;
go

select * from sys.indexes where is_hypothetical = 1;

--print db_id()

--Parameters
--typeid, dbid, tabid, indid
--0 --> NonClustered index
dbcc autopilot(0, 8, 709577566, 3);
go

set autopilot on;
go

select h.SalesOrderID, h.OrderDate, h.CustomerID, d.ProductID, d.OrderQty
from OrderHeader h
inner join OrderDetail d on h.SalesOrderID = d.SalesOrderID
where OrderDate = '20130927';
go

set autopilot off;
go

CREATE NONCLUSTERED INDEX Idx_OrderDetail_SalesOrderID
ON [dbo].[OrderDetail] ([SalesOrderID])
INCLUDE ([OrderQty],[ProductID])
with statistics_only = -1;
go

select * from sys.indexes where is_hypothetical = 1;
go

--Parameters
--typeid, dbid, tabid, indid
--0 --> NonClustered index
dbcc autopilot(0, 8, 725577623, 3);
go

set autopilot on;
go

select h.SalesOrderID, h.OrderDate, h.CustomerID, d.ProductID, d.OrderQty
from OrderHeader h
inner join OrderDetail d on h.SalesOrderID = d.SalesOrderID
where OrderDate = '20130927';
go

set autopilot off;
go

select * from sys.indexes where is_hypothetical = 1;
go

--Deactivate the index on OrderHeader
--Parameters
--typeid, dbid, tabid, indid
--1 --> Deactivates the index
dbcc autopilot(1, 8, 709577566, 3);
go

--Test the query again
set autopilot on;
go

select h.SalesOrderID, h.OrderDate, h.CustomerID, d.ProductID, d.OrderQty
from OrderHeader h
inner join OrderDetail d on h.SalesOrderID = d.SalesOrderID
where OrderDate = '20130927';
go

set autopilot off;
go


---------------------------------------------------------
--Considero l'indice nonclustered su OrderHeader come clustered!

--select * from sys.indexes where is_hypothetical = 1;
--go

dbcc autopilot(5, 8);
go

--Parameters
--typeid, dbid, tabid, indid
--6 --> Clustered index
dbcc autopilot(6, 8, 709577566, 3);
go

set autopilot on;
go

select h.SalesOrderID, h.OrderDate, h.CustomerID, d.ProductID, d.OrderQty
from OrderHeader h
inner join OrderDetail d on h.SalesOrderID = d.SalesOrderID
where OrderDate = '20130927';
go

set autopilot off;
go




--Drop the Hypothetical index on OrderHeader
drop index Idx_OrderHeader_OrderDate on OrderHeader;

--Recreate it as clustered (?)
CREATE CLUSTERED INDEX Idx_OrderHeader_OrderDate
ON [dbo].[OrderHeader] ([OrderDate])
with statistics_only = -1;
go


--Look at OrderHeader's indexes
select * from sys.indexes where object_id = OBJECT_ID('OrderHeader');


--With hypothetical indexes it is possible to have more than one clustered index in the same table!




--Drop indexes
drop index Idx_OrderHeader_OrderDate on OrderHeader;
drop index Idx_OrderDetail_SalesOrderID on OrderDetail;
go


