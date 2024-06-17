------------------------------------------------------------------------
-- Event:        SQL Saturday #895 Parma, November 23 2019             -
--               https://www.sqlsaturday.com/895/eventhome.aspx        -
-- Session:      Query tuning with hypothetical indexes                -
-- Demo:         Verifying locks with XE                               -
-- Author:       Alessandro Mortola                                    -
-- Notes:        --                                                    -
------------------------------------------------------------------------

/* Doorstop */
raiserror(N'Did you mean to run the whole thing?',20,1) with log;
go


if exists(select * from sys.server_event_sessions where name = 'XE_Locks')
    drop event session XE_Locks on server;
go

--XE creation
create event session [XE_Locks] on server 
add event sqlserver.lock_acquired(
    where ([package0].[equal_uint64]([database_id],(8)))),
add event sqlserver.lock_released(
    where ([package0].[equal_uint64]([database_id],(8))))
add target package0.event_file(SET filename=N'D:\SqlData\XE\XELocks.xel')
with (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
      MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
go

use TestDb;
go

drop table if exists Orders;
go

create table Orders (Id int identity(1,1) not null,
	OrderDate datetime not null,
	CustomerId int not null,
	Filler char(10));
go

with
n1 as (select 1 a union all select 1),
n2 as (select 1 a from n1 b, n1 c),
n3 as (select 1 a from n2 b, n2 c),
n4 as (select 1 a from n3 b, n3 c),
n5 as (select 1 a from n4 b, n4 c),
n6 as (select 1 a from n5 b, n5 c)
insert into dbo.Orders with (tablock)
select top(100000)
	DATEADD(day, -1 * (ABS(BINARY_CHECKSUM(NEWID())) % 1000), GETDATE()),
	ABS(BINARY_CHECKSUM(NEWID())) % 1500,
	REPLICATE('x', 10)
from n6;
go

--Activate XE Session

--Clustered Index - online = OFF
create clustered index Idx_cl on Orders(id) with (online = OFF);

--Stop XE Session


--XEL file reading
with Cte as (
	select
		n.value('(@name)[1]', 'varchar(50)') as event_name,
		n.value('(@timestamp)[1]', 'datetime2') AS [utc_timestamp],
		n.value('(data[@name="resource_type"]/text)[1]', 'VARCHAR(20)') as ResourceType,
		n.value('(data[@name="mode"]/text)[1]', 'VARCHAR(10)') as LockMode,
		n.value('(data[@name="resource_0"]/value)[1]', 'bigint') as Resource_0,
		n.value('(data[@name="object_id"]/value)[1]', 'bigint') as Object_id,
		ed.event_data
	from (select cast(event_data as XML) as event_data
			from sys.fn_xe_file_target_read_file(N'D:\SqlData\XE\XELocks*.xel', null, null, null)) ed
			cross apply ed.event_data.nodes('event') as q(n)
			)

select utc_timestamp, event_name, LockMode, OBJECT_NAME(Resource_0) ResourceName, 
		OBJECT_NAME(Object_id) ObjectName, event_data
from Cte
where OBJECT_NAME(TRY_CAST(Resource_0 as int)) = 'Orders' 
order by utc_timestamp;
go




--Delete XE file and activate XE Session

--Nonclustered index - online = OFF
create nonclustered index Idx_ncl on Orders(OrderDate) with (online = OFF);

--Stop XE Session

--XEL file reading
with Cte as (
	select
		n.value('(@name)[1]', 'varchar(50)') as event_name,
		n.value('(@timestamp)[1]', 'datetime2') AS [utc_timestamp],
		n.value('(data[@name="resource_type"]/text)[1]', 'VARCHAR(20)') as ResourceType,
		n.value('(data[@name="mode"]/text)[1]', 'VARCHAR(10)') as LockMode,
		n.value('(data[@name="resource_0"]/value)[1]', 'bigint') as Resource_0,
		n.value('(data[@name="object_id"]/value)[1]', 'bigint') as Object_id,
		ed.event_data
	from (select cast(event_data as XML) as event_data
			from sys.fn_xe_file_target_read_file(N'D:\SqlData\XE\XELocks*.xel', null, null, null)) ed
			cross apply ed.event_data.nodes('event') as q(n)
			)

select utc_timestamp, event_name, LockMode, OBJECT_NAME(Resource_0) ResourceName, 
		OBJECT_NAME(Object_id) ObjectName, event_data
from Cte
where OBJECT_NAME(try_cast(Resource_0 as int)) = 'Orders' 
order by utc_timestamp;
go


--Drop nonclustered
--drop index Idx_ncl on Orders with (online = ON);
--go

drop index Idx_ncl on Orders with (online = OFF);
go

