
--1. Si manifesta con un LOB data type
--2. Verificare se con il merge si ha lo stasso effetto

use SqlSat
go

--Connection 1
-- Create a new table
drop table if exists OrderByTable
go

create table OrderByTable
(
    ID INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    I1 INT,
    C1 VARCHAR(max)
)
GO
 
-- Insert some records into the table
INSERT INTO OrderByTable VALUES (1, 'abc'), (2, 'def'), (3, 'ghi')
GO

select * from OrderByTable
go
 
-- Begin a new transaction, so that we are blocking one record
BEGIN TRANSACTION
 
UPDATE OrderByTable SET I1 = 1 WHERE ID = 3

---------------------------------------------------------------------------------
--Connection2
-- This statement only acquires a key lock on the current record
-- SELECT C1 FROM OrderByTable
GO

---------------------------------------------------------------------------------
--Connection 3
select resource_type, resource_description, resource_associated_entity_id, request_mode,
       request_type, request_status, request_reference_count, request_session_id 
from sys.dm_tran_locks 
go

----------------------------------------------------------------------------------
--Connection 2
--Stop della precedente esecuzione e sostituire con la seguente:
SELECT C1 FROM OrderByTable
ORDER BY I1
/*
La order by impone l’utilizzo dell’operatore Sort (vedi Execution Plan). 
Ora rieseguendo la DMV della Connection 3 si vede come come i lock vengano mantenuti anche sui primi due record: 
questo è necessario per impedire concurrent changes. In questo caso la query sta lavorando in Repeatable Read.
*/
GO

rollback

go
--Look at locks kept with repeatable read isolation level
set transaction isolation level repeatable read
go


begin tran
select * from OrderByTable
 
