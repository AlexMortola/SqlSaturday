-----------------------------------------------------------------------------------------------
-- Event:        SQL Saturday #895 Parma, November 23 2019									  -
--               https://www.sqlsaturday.com/895/eventhome.aspx								  -
-- Session:      Query tuning with hypothetical indexes										  -
-- Demo:         Hypothetical 4 - The 7th parameter                                           -
-- Author:       Alessandro Mortola                                                           -
-- Notes:        --                                                                           -
-----------------------------------------------------------------------------------------------

/* Doorstop */
raiserror(N'Did you mean to run the whole thing?',20,1) with log;
go


use AdventureWorks;
go


--Let's create a NonClustered hypothetical index on OrderDate
create nonclustered index Idx_h_OHE_OrderDateStat on Sales.SalesOrderHeader(OrderDate) 
include (CustomerID)
with statistics_only = -1;
go

--Let's check it
select * from sys.indexes where is_hypothetical = 1;
go

--print db_id();

dbcc autopilot (5, 5);
go

--Parameters
--typeid, dbid, tabid, indid, pages, flag, rowcounts
dbcc autopilot(0, 5, 1922105888, 6);
go

--Parameters
--typeid, dbid, tabid, indid, pages, flag, rowcounts
dbcc autopilot(7, 5, 0, 0, 0, 1, 0);
go

set autopilot on;
go

select OrderDate, CustomerID, count(*) as Counter
from Sales.SalesOrderHeader 
where OrderDate = '20110607'
group by OrderDate, CustomerID;
go

set autopilot off;
go


drop index Idx_h_OHE_OrderDateStat on sales.SalesOrderHeader;
go
