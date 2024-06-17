--------------------------------------------------------------------------------
--Cost for parallelism
--------------------------------------------------------------------------------

use SqlSat
go

--Data setup

drop table if exists OrderHeader;
drop table if exists OrderDetail;

select * 
into OrderHeader
from AdventureWorks2017.Sales.SalesOrderHeader

select * 
into OrderDetail
from AdventureWorks2017.Sales.SalesOrderDetail;
go




--Let's look at the cost threshold...

select name, value, value_in_use, is_advanced
from sys.configurations
where name = 'cost threshold for parallelism';
go

--Let's set it to 10
EXEC sys.sp_configure N'cost threshold for parallelism', N'10'
GO
RECONFIGURE WITH OVERRIDE
GO


--Check it
select name, value, value_in_use, is_advanced
from sys.configurations
where name = 'cost threshold for parallelism';
go


--Look at the execution plan
select h.SalesOrderID, h.OrderDate, h.CustomerID, d.ProductID, 
	   d.OrderQty * d.UnitPrice,
	   sum(d.OrderQty * d.UnitPrice) over (partition by h.SalesOrderID order by h.OrderDate ROWS UNBOUNDED PRECEDING) as RunningTotal
from OrderHeader h
inner join OrderDetail d on h.SalesOrderID = d.SalesOrderID
go





--The cost is below the threshold and it goes in parallel?
--Cost threshold: single threaded plans
--Look at the cost
select h.SalesOrderID, h.OrderDate, h.CustomerID, d.ProductID, 
	   d.OrderQty * d.UnitPrice,
	   sum(d.OrderQty * d.UnitPrice) over (partition by h.SalesOrderID order by h.OrderDate ROWS UNBOUNDED PRECEDING) as RunningTotal
from OrderHeader h
inner join OrderDetail d on h.SalesOrderID = d.SalesOrderID
option (maxdop 1)


--Above 12 the plan is single threaded
--Below 12 the plan goes in parallel

EXEC sys.sp_configure N'cost threshold for parallelism', N'13'
GO
RECONFIGURE WITH OVERRIDE
GO

select h.SalesOrderID, h.OrderDate, h.CustomerID, d.ProductID, 
	   d.OrderQty * d.UnitPrice,
	   sum(d.OrderQty * d.UnitPrice) over (partition by h.SalesOrderID order by h.OrderDate ROWS UNBOUNDED PRECEDING) as RunningTotal
from OrderHeader h
inner join OrderDetail d on h.SalesOrderID = d.SalesOrderID