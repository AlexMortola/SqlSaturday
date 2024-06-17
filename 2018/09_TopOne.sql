--http://www.sqlservercentral.com/blogs/sqlstudies/2016/03/21/top-1-killed-my-performance-rob-farley-helped-me-resurrect-it/
--***********************************************--
--                 SETUP                         --
--***********************************************--

USE SqlSat
GO

IF OBJECT_ID('Big_Table') IS NOT NULL
	DROP TABLE Big_Table
GO

IF OBJECT_ID('Small_Table') IS NOT NULL
	DROP TABLE Small_Table
GO

CREATE TABLE Big_Table 
(Sort_Id int NOT NULL, 
 Join_Id int, 
 Other_Id int NOT NULL)
GO

ALTER TABLE Big_Table ADD CONSTRAINT id PRIMARY KEY CLUSTERED (Sort_Id, Other_Id)
GO

;WITH a AS (SELECT 1 AS i UNION ALL SELECT 1),
b AS (SELECT a.i FROM a, a AS x),
c AS (SELECT b.i FROM b, b AS x),
d AS (SELECT c.i FROM c, c AS x),
e AS (SELECT d.i FROM d, d AS x),
f AS (SELECT e.i FROM e, e AS x)
INSERT Big_Table
SELECT TOP(1500000)
	ROW_NUMBER() OVER (ORDER BY (SELECT null)),
	ROW_NUMBER() OVER (ORDER BY (SELECT null)) + 
		(CHECKSUM(NEWID()) % 100),
	1
FROM f
GO

SELECT TOP 100 * FROM Big_Table
GO
SELECT MAX(Join_Id) MaxJoinId, MIN(Join_Id) MinJoinId FROM Big_Table
GO

-- Index left over from me flailing around
CREATE INDEX ix_Big_Table ON Big_Table (Sort_Id, Join_Id)
GO

CREATE TABLE Small_Table 
(PK_Id int NOT NULL IDENTITY(1,1) CONSTRAINT pk_Small_Table PRIMARY KEY, 
 Join_Id int, 
 Other_Col int, 
 Other_Col2 char(1), 
 Where_Col datetime)
GO

INSERT Small_Table
SELECT TOP(5000)
	Join_Id,
	1, 'a',
	DATEADD(MINUTE, -Join_Id, GetDate())
FROM Big_Table
ORDER BY Join_Id DESC
GO

EXEC sp_configure 'cost threshold for parallelism', 30;
RECONFIGURE;
go

--***********************************************--
--The Query !
--***********************************************--
SELECT ST.Join_Id,
        ST.Other_Col,
        ST.Other_Col2,
        ST.PK_Id,
        BT.Sort_Id
FROM Small_Table ST
JOIN Big_Table BT
    ON ST.Join_Id = BT.Join_Id
WHERE ST.Where_Col < = GETDATE()
ORDER BY BT.Sort_Id;
GO



