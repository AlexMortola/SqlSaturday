use SqlSat
go

drop table if exists Sales
go

create table Sales (SalesId int constraint PK_Sales primary key,
	CustomerId int,
	ProductId int,
	Quantity int,
	Notes char(1000))
go

truncate table Sales
go

With
Generator (N) as (select row_number() over (order by (select null))
			  from master.dbo.spt_values v1
			  cross join  master.dbo.spt_values v2 
			  )

insert into Sales
select N, 
	   case when N <= 10 then 101 when N between 11 and 20 then 100 else N % 25 end, 
	   ABS(BINARY_CHECKSUM(NEWID())) % 1000, 
	   ABS(BINARY_CHECKSUM(NEWID())) % 20000, 
	   REPLICATE('X', 1000) 
from Generator
where n <= 200020
go

create index Idx_Sales_Customer on Sales (CustomerId)
go

select CustomerId, count(*) Counter 
from Sales
group by CustomerId
go

set statistics io on
go

EXEC sp_configure 'show advanced options', 1 ;  
GO
RECONFIGURE  
GO 
EXEC sys.sp_configure N'Cost Threshold For Parallelism', N'80'
GO
RECONFIGURE WITH OVERRIDE
GO

set transaction isolation level read committed
go

--------------------------------------------------
--Different indexes
--------------------------------------------------
select SalesId, CustomerId, ProductId, Quantity 
from Sales 
where CustomerId < 10

select SalesId, CustomerId, ProductId, Quantity 
from Sales 
where CustomerId >= 100

--------------------------------------------------
--Allocation map
--------------------------------------------------
--How many pages?
select OBJECT_NAME(p.object_id), au.type_desc, i.index_id, i.name, au.total_pages, au.used_pages, au.data_pages
from sys.allocation_units au
inner join sys.partitions p on au.container_id = p.hobt_id
inner join sys.indexes i on p.object_id = i.object_id and p.index_id = i.index_id  
where p.object_id = OBJECT_ID('dbo.Sales') and au.type_desc = 'IN_ROW_DATA'
go

select SalesId, CustomerId, ProductId, Quantity 
from Sales with(nolock) 

select SalesId, CustomerId, ProductId, Quantity 
from Sales with(tablock) 
go

set transaction isolation level read uncommitted
go

select SalesId, CustomerId, ProductId, Quantity 
from Sales --with(nolock) 

--Verify the allocation map
--First pages

--98568
dbcc ind ('SqlSat', 'dbo.Sales', -1)

DBCC TRACEON(3604);
dbcc page ('SqlSat', 1, 288, 3);
DBCC TRACEOFF(3604);


--------------------------------------------------
--Parallelism
--------------------------------------------------
set transaction isolation level read committed
go

EXEC sys.sp_configure N'cost threshold for parallelism', N'5'
GO
RECONFIGURE WITH OVERRIDE
GO

select SalesId, CustomerId, ProductId, Quantity 
from Sales 
where CustomerId in (6, 15, 20)
go
