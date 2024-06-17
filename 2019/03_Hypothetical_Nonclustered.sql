------------------------------------------------------------------------
-- Event:        SQL Saturday #895 Parma, November 23 2019             -
--               https://www.sqlsaturday.com/895/eventhome.aspx        -
-- Session:      Query tuning with hypothetical indexes                -
-- Demo:         Hypothetical 1 - Nonclustered index                   -
-- Author:       Alessandro Mortola                                    -
-- Notes:        --                                                    -
------------------------------------------------------------------------

/* Doorstop */
raiserror(N'Did you mean to run the whole thing?',20,1) with log;
go


use AdventureWorks;
go

--No hypothetical indexes here
select * from sys.indexes where is_hypothetical = 1;
go

--The creation of a NonClustered with statistics
create nonclustered index Idx_h_OHE_OrderDateStat on Sales.SalesOrderHeader(OrderDate) 
with statistics_only = -1;
go


--Check with sys.indexes
select * from sys.indexes where is_hypothetical = 1;
go


--********************************************
--Check in SSMS index (missing) and statistic
--********************************************

--The statistic exists...
dbcc show_statistics('Sales.SalesOrderHeader', 'Idx_h_OHE_OrderDateStat');


--AUTOPILOT's help
dbcc traceon(2588);
go

dbcc help('AUTOPILOT');
go

dbcc traceoff(2588);
go


--*******************************************************************************
--The engine is not able to use the statistic generated by the hypothetical index
--*******************************************************************************

--Activate the Actual Execution Plan
select SalesOrderID, OrderDate 
from Sales.SalesOrderHeader
where OrderDate = '20120801';
--Deactivate the Actual Execution Plan


--*******************************************************************************
--How to use the hypothetical index
--*******************************************************************************

--Clean all previous commands
--print db_id();
dbcc autopilot(5, 5);

--select * from sys.indexes where is_hypothetical = 1;
--Parameters: typeid, dbid, tabid, indid, pages, flag, rowcounts
--            typeid 0 --> Nonclustered index

dbcc autopilot(0, 5, 1922105888, 6);

--Autopilot activation
set autopilot on;

--The query again
select SalesOrderID, OrderDate 
from Sales.SalesOrderHeader
where OrderDate = '20120801';

--Look at the Estimated nr of rows and compare with the statistics

--Autopilot deactivation
set autopilot off;
go

dbcc show_statistics('Sales.SalesOrderHeader', 'Idx_h_OHE_OrderDateStat') with histogram;
go

--Drop auto stat
drop statistics Sales.SalesOrderHeader._WA_Sys_00000003_72910220;
go

drop index Idx_h_OHE_OrderDateStat on sales.SalesOrderHeader;
go


--Check with sys.indexes. No more hypothetical indexes
select * from sys.indexes where is_hypothetical = 1
go


--*******************************
--NonClustered without statistics
--*******************************

create nonclustered index Idx_h_OHE_OrderDateNoStat on Sales.SalesOrderHeader(OrderDate) 
with statistics_only = 0;
go


--Check with sys.indexes
select * from sys.indexes where is_hypothetical = 1;
go


--********************************************
--Check in SSMS index (missing) and statistic
--********************************************

--The statistic exists... but is empty!
dbcc show_statistics('Sales.SalesOrderHeader', 'Idx_h_OHE_OrderDateNoStat');
go

dbcc autopilot(5, 5);
go


--select * from sys.indexes where is_hypothetical = 1;
--Parameters: typeid, dbid, tabid, indid, pages, flag, rowcounts
--            typeid 0 --> Nonclustered index

dbcc autopilot(0, 5, 1922105888, 6);

--Autopilot activation
set autopilot on;

--The query again
select SalesOrderID, OrderDate 
from Sales.SalesOrderHeader
where OrderDate = '20120801';

--Look at the Estimated nr of rows and compare with the statistics

--Autopilot deactivation
set autopilot off;
go

select OBJECTPROPERTYEX(object_id('sales.SalesOrderHeader'), 'cardinality');

select SQRT(31465);
go

drop index Idx_h_OHE_OrderDateNoStat on sales.SalesOrderHeader;
go
