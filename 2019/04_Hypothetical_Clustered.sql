------------------------------------------------------------------------
-- Event:        SQL Saturday #895 Parma, November 23 2019             -
--               https://www.sqlsaturday.com/895/eventhome.aspx        -
-- Session:      Query tuning with hypothetical indexes                -
-- Demo:         Hypothetical 2 - Clustered index                      -
-- Author:       Alessandro Mortola                                    -
-- Notes:        --                                                    -
------------------------------------------------------------------------

/* Doorstop */
raiserror(N'Did you mean to run the whole thing?',20,1) with log;
go


use AdventureWorks;
go

drop table if exists _smallOH;
go

select top 100 * 
into _smallOH
from Sales.SalesOrderHeader;
go

select * from _smallOH;
go

--It is a heap. Now I'm going to create the clustered index 
create clustered index cl_soh on _smallOH(OrderDate) 
with statistics_only = -1;
go

select * from sys.indexes where is_hypothetical = 1;

--Clean all previous commands
dbcc autopilot(5, 5);
go

dbcc autopilot(6, 5, 1319675749, 2);
go

set autopilot on;
go

--The query again
select SalesOrderID, OrderDate 
from _smallOH
where OrderDate = '20110607';
go

set autopilot off;
go

dbcc show_statistics('_smallOH', 'cl_soh') with histogram;
go


dbcc autopilot(5, 5);
go

select * from sys.indexes where is_hypothetical = 1;
go
--Parameters
--typeid, dbid, tabid, indid, pages, flag, rowcounts
dbcc autopilot(6, 5, 1319675749, 2, 13000, 0, 1000000);
go

set autopilot on;
go

--The query again
--1000000 without filter
--  30000 with filter
select SalesOrderID, OrderDate 
from _smallOH
where OrderDate = '20110607';
go

set autopilot off;
go

dbcc show_statistics('_smallOH', 'cl_soh') with histogram;

--Clean
drop table _smallOH;
go
