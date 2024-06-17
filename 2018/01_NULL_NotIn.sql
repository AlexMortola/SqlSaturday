
use SqlSat
go

drop table if exists t1; 
drop table if exists t2; 
go

create table T1 (
	Id int identity(1,1))
go

create table T2 (
	Id int)
go

insert into T1 default values
go 10

insert into T2 values (1),(3),(5),(7),(9)
go

select id from T1
go
select id from T2
go

--Include Actual Executuon Plan !

--Restituisce i numeri pari - 5 rows
select id 
from T1
where id not in (select id from T2)
go

select id 
from T1
where id not in (1, 3, 5, 7, 9, null)
go



insert into T2 values (NULL)
go

select * from T2
go

--Eseguo nuovamente la query precedente - 0 rows (!)
select id 
from T1
where id not in (select id from T2)
go

