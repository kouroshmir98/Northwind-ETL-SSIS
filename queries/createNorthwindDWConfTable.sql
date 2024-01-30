-- create NorthwindDWConf table
CREATE DATABASE NorthwindDWConf
GO

USE NorthwindDWConf
GO

-- Create DWConf table
IF OBJECT_ID('DWConf' , 'U') IS NOT NULL
BEGIN
    DROP TABLE DWConf
END

CREATE TABLE DWConf(
    tableName nvarchar(50) PRIMARY KEY , 
    lastFetchedRowVer bigint
)

-- feed DWConf table

INSERT INTO DWConf
    (tableName , lastFetchedRowVer)
VALUES
    ('Products' , 0),
    ('Customers' , 0),
    ('Orders' , 0),
    ('Employees' , 0),
    ('Shippers' , 0)


--
SELECT * FROM DWConf
go