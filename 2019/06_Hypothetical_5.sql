-----------------------------------------------------------------------------------------------
-- Event:        SQL Saturday #895 Parma, November 23 2019									  -
--               https://www.sqlsaturday.com/895/eventhome.aspx								  -
-- Session:      Query tuning with hypothetical indexes										  -
-- Demo:         Hypothetical 5 - 7 param -
-- Author:       Alessandro Mortola                                                           -
-- Notes:        --                                                                           -
-----------------------------------------------------------------------------------------------

use TestDb
go

select * from sys.indexes where is_hypothetical = 1
go

drop index Idx_OrderDetail_SalesOrderID on OrderDetail
go

drop index Idx_OrderHeader_OrderDate on OrderHeader
go

dbcc autopilot (5, 8);
go

dbcc autopilot (7, 8, 0, 0, 0, 1);
go

set autopilot on;
go

select * 
from OrderHeader
where OrderDate = '20130927' 
go

set autopilot off;
go