use SqlSat
go

--Praparazione dati

drop table if exists OrderHeader;
drop table if exists OrderDetail;

select * 
into OrderHeader
from AdventureWorks.Sales.SalesOrderHeader

select * 
into OrderDetail
from AdventureWorks.Sales.SalesOrderDetail;

set statistics io, time on


select h.SalesOrderID, h.OrderDate, h.CustomerID, d.ProductID, d.OrderQty
from OrderHeader h
inner join OrderDetail d on h.SalesOrderID = d.SalesOrderID
where OrderDate = '20130927' 