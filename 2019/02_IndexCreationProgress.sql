------------------------------------------------------------------------
-- Event:        SQL Saturday #895 Parma, November 23 2019             -
--               https://www.sqlsaturday.com/895/eventhome.aspx        -
-- Session:      Query tuning with hypothetical indexes                -
-- Demo:         Track progress of CREATE INDEX command                -
-- Author:       Alessandro Mortola                                    -
-- Notes:        --                                                    -
------------------------------------------------------------------------

/* Doorstop */
raiserror(N'Did you mean to run the whole thing?',20,1) with log;
go


Use TestDb;
go

drop table if exists T1;
go

create table T1 (
	Guid1 char(36),
	Guid2 char(36),
	Guid3 char(36),
	Guid4 char(36),
	Guid5 char(36),
	Guid6 char(36));
go

--Insert into the table 6 mln rows. 30 seconds needed
with 
Cte as (select top 6000000 cast(newid() as char(36)) guid1,
               cast(newid() as char(36)) guid2,
			   cast(newid() as char(36)) guid3,
			   cast(newid() as char(36)) guid4,
			   cast(newid() as char(36)) guid5,
			   cast(newid() as char(36)) guid6

		from master.dbo.spt_values v1
		cross join master.dbo.spt_values v2
		cross join master.dbo.spt_values v3)
insert into T1
select *
from Cte;
go

SET STATISTICS PROFILE ON;
--You can also use the following instead of the previous
--SET STATISTICS XML ON;
go
--20 seconds needed
create nonclustered index t1_idx1 on t1(guid1, guid2,  guid3, guid4);
go

--On a second session carry out the following
--Taken from https://dba.stackexchange.com/questions/139191/sql-server-how-to-track-progress-of-create-index-command
/*

DECLARE @SPID INT = 53;

;WITH agg AS
(
     SELECT SUM(qp.[row_count]) AS [RowsProcessed],
            SUM(qp.[estimate_row_count]) AS [TotalRows],
            MAX(qp.last_active_time) - MIN(qp.first_active_time) AS [ElapsedMS],
            MAX(IIF(qp.[close_time] = 0 AND qp.[first_row_time] > 0,
                    [physical_operator_name],
                    N'<Transition>')) AS [CurrentStep]
     FROM sys.dm_exec_query_profiles qp
     WHERE qp.[physical_operator_name] IN (N'Table Scan', N'Clustered Index Scan', N'Sort')
     AND   qp.[session_id] = @SPID
), comp AS
(
     SELECT *,
            ([TotalRows] - [RowsProcessed]) AS [RowsLeft],
            ([ElapsedMS] / 1000.0) AS [ElapsedSeconds]
     FROM   agg
)
SELECT [CurrentStep],
       [TotalRows],
       [RowsProcessed],
       [RowsLeft],
       CONVERT(DECIMAL(5, 2),
               (([RowsProcessed] * 1.0) / [TotalRows]) * 100) AS [PercentComplete],
       [ElapsedSeconds],
       (([ElapsedSeconds] / [RowsProcessed]) * [RowsLeft]) AS [EstimatedSecondsLeft],
       DATEADD(SECOND,
               (([ElapsedSeconds] / [RowsProcessed]) * [RowsLeft]),
               GETDATE()) AS [EstimatedCompletionTime]
FROM   comp;

*/

drop index t1_idx1 on t1;










