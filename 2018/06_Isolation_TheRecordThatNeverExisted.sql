use SqlSat
go

---------------------------------
--Setup data
---------------------------------
drop table if exists OrderDetail
go

set transaction isolation level read committed
go

--Create table
select *
into OrderDetail
from AdventureWorks2017.sales.SalesOrderDetail
go

alter table OrderDetail add constraint PK_OrderDetail primary key (SalesOrderDetailID)
go
create nonclustered index Idx_ProdId_TrackNumb on OrderDetail (ProductID, CarrierTrackingNumber)
go
create nonclustered index Idx_ModDate_LineTot on OrderDetail (ModifiedDate, LineTotal)
go

--Look at the table
select SalesOrderDetailID, CarrierTrackingNumber, ProductID, LineTotal, ModifiedDate 
from OrderDetail
go











/* Look at the plan for the following query. 

We have a hash match join and two nonclustered index seeks. 
	The 'Build' phase of the hash match uses Idx_OrderDetail_ModifiedDate. That runs first.
    The 'Probe' phase of the hash match uses Idx_OrderDetail_ProductId. That runs second.
*/

select SalesOrderDetailID, CarrierTrackingNumber, ProductID, LineTotal, ModifiedDate 
from OrderDetail
where ProductID = 804 and ModifiedDate = '20130430'






/* Read Data for a specific SalesOrderDetailID and take note of it... */

/* Uncomment this and run it in another session 
BEGIN TRAN

    UPDATE OrderDetail SET LineTotal = 999
    WHERE SalesOrderDetailID = 33725
*/

/* Now start this query in this session ... */

select SalesOrderDetailID, CarrierTrackingNumber, ProductID, LineTotal, ModifiedDate 
from OrderDetail
where ProductID = 804 and ModifiedDate = '2013-04-30'

/* In the second session, finish up.... 
	UPDATE OrderDetail SET CarrierTrackingNumber = 'YYZ'
    WHERE SalesOrderDetailID = 33725

commit
*/

/* Query the full history for this FirstNameId */
SELECT SalesOrderDetailID, CarrierTrackingNumber, ProductID, LineTotal, cast(ModifiedDate as date) as ModifiedDate 
FROM OrderDetail 
WHERE SalesOrderDetailID = 33725;
GO
