-- create database
create database NorthwindDW
go
use NorthwindDW
go

 -- add sprate file groups for facts and dimentions
ALTER DATABASE NorthwindDW
ADD FILEGROUP FactFG;

ALTER DATABASE NorthwindDW
ADD FILEGROUP DimFG;

-- add data file to fact and dimention file groups

ALTER DATABASE NorthwindDW 
ADD FILE 
(
    NAME = FactData1,
    FILENAME = 'D:\temp\SqlData\FactData1.ndf',
    SIZE = 1024 MB,
    MAXSIZE = 10240 MB,
    FILEGROWTH = 1024 MB
),
(
    NAME = FactData2,
    FILENAME = 'D:\temp\SqlData\FactData2.ndf',
    SIZE = 1024 MB,
    MAXSIZE = 10240 MB,
    FILEGROWTH = 1024 MB
)
TO FILEGROUP FactFG;
GO

ALTER DATABASE NorthwindDW 
ADD FILE 
(
    NAME = DimData1,
    FILENAME = 'D:\temp\SqlData\DimData1.ndf',
    SIZE = 1024 MB,
    MAXSIZE = 10240 MB,
    FILEGROWTH = 1024 MB
),
(
    NAME = DimData2,
    FILENAME = 'D:\temp\SqlData\DimData2.ndf',
    SIZE = 1024 MB,
    MAXSIZE = 10240 MB,
    FILEGROWTH = 1024 MB
)
TO FILEGROUP DimFG;
GO

-- enable t117 for Fact and Dim file groups
ALTER DATABASE NorthwindDW 
MODIFY FILEGROUP FactFG  AUTOGROW_ALL_FILES
go

ALTER DATABASE NorthwindDW 
MODIFY FILEGROUP DimFG  AUTOGROW_ALL_FILES
go






-- create dimProduct
if OBJECT_ID('dimProduct' , 'u') is not null
begin
	drop table dimProduct;
end

create table dimProduct(
	productKey int primary key nonclustered,
	productBK int ,
	supplierId int,
	categoryId int , 
	productName nvarchar(40) ,
	discontinued bit ,
	supplierName nvarchar(40) ,
	supplierCity nvarchar(15) ,
	supplierRegion nvarchar(15) ,
	supplierCountry nvarchar(15) ,
	supplierPostalCode nvarchar(10) ,
	categoryName nvarchar(15) ,
	productSupplierLocationKey int ,
	dataHash varbinary(64) ,
	verRec bigint ,
	fetchedAt datetime2 default getdate()
) on DimFG

create clustered index 
dimProductCI 
on dimProduct(productBK) WITH (DATA_COMPRESSION = PAGE)
go


-- create DimCustomer
if OBJECT_ID('dimCustomer' , 'u') is not null
begin
	drop table dimCustomer;
end

create table dimCustomer(
	customerKey int primary key nonclustered identity,
	customerBK nvarchar(5),
	customerName nvarchar(40) ,
	customerRegion nvarchar(15),
	customerCountry nvarchar(15),
	customerCity nvarchar(15),
	postalCode nvarchar(10) ,
	customerLocationKey int , 
	dataHash varbinary(64),
	verRec bigint ,
	fetchedAt datetime2 default getdate()
) on DimFG

create clustered index 
dimCustomerCI 
on dimCustomer(customerBK) WITH (DATA_COMPRESSION = PAGE)
go


-- create dimLocation

if OBJECT_ID('dimLocation' , 'u') is not null
begin
	drop table dimLocation;
end

create table dimLocation(
	locationKey int primary key identity , 
	city nvarchar(15),
	region nvarchar(15),
	country nvarchar(15),
	dataHash varbinary(64) , 
	fetchedAt datetime2 default getdate()
) on DimFG


-- create dimShipper

if OBJECT_ID('dimShipper' , 'u') is not null
begin
	drop table dimShipper;
end
create table dimShipper(
	shipperKey int primary key nonclustered,
	shipperBK int ,
	shipperName nvarchar(40) , 
	verRec bigint ,
	fetchedAt datetime2 default getDate()
) on DimFG

create clustered index 
dimShipperCI 
on dimShipper(shipperBK) WITH (DATA_COMPRESSION = PAGE)
go


-- create dimEmployee


if OBJECT_ID('dimEmployee' , 'u') is not null
begin
	drop table dimEmployee;
end

create table dimEmployee(
	employeeKey int primary Key nonclustered,
	employeeBK int ,
	managerId int ,
	lastName nvarchar(20) ,
	firstName nvarchar(10) ,
	title nvarchar(30) ,
	gender nvarchar(6) ,
	birthDate date ,
	hireDate date ,
	country nvarchar(15) ,
	region nvarchar(15) ,
	city nvarchar(15) ,
	postalCode nvarchar(10) ,
	dataHash varbinary(64),
	verRec bigint ,
	fetchedAt datetime2 default getdate()
) on DimFG 
create clustered index 
dimEmployeeCI 
on dimEmployee(employeeBK) WITH (DATA_COMPRESSION = PAGE)
go

-- create dimDate

if OBJECT_ID('DimDate' , 'u') is not null
begin
	drop table DimDate;
end

create table DimDate(
	dateKey int primary key,
	fullDate nvarchar(10),
	yearKey int,
	monthKey int,
	monthNameShort nvarchar(3),
	monthNameFull nvarchar(10),
	monthDayKey int,
	weekDayNameShort nvarchar(3),
	weekDayNameFull nvarchar(10),
	quarterKey int,
	seasonName nvarchar(6),
	yearHalfKey int,
	yearMonthName nvarchar(8),
	yearQuarter nvarchar(6),
	yearSeason nvarchar(11),
	yearHalf nvarchar(6),
	persianFullDate nvarchar(10),
	persianYearKey int,
	persianMonthKey int,
	PersianMonthName nvarchar(10) ,
	persianMonthDayKey int ,
	persianWeekDayName nvarchar(10) ,
	persianQuarterKey int ,
	persianSeasonName nvarchar(10), 
	persianYearHalfKey int,
	persianYearMonthName nvarchar(15),
	persianYearQuarter nvarchar(6),
	persianYearSeason nvarchar(15),
	persianYearHalf nvarchar(6),
	fetchedAt DATETIME2 DEFAULT GETDATE()
);


-- create factOrder
if OBJECT_ID('factOrder' , 'u') is not null
begin
	drop table factOrder;
end

create table factOrder(
	orderKey int ,
	orderBk int , 
	customerKey int ,
	employeeKey int ,
	productKey int ,
	shipperKey int ,
	orderDateKey int ,
	shippedDateKey int ,
	requiredDateKey int ,
	shipLocationKey int,
	customerLocationKey int,
	productSupplierLocationKey int,
	orderDate date ,
	requiredDate date ,
	shippedDate date ,
	unitPrice decimal(19 , 2) ,
	quantity int , 
	discount decimal(5,2) ,
	freight DECIMAL(19 , 2) ,
	shipPostalCode nvarchar(10) ,
	dataHash varbinary(64) , 
	verRec bigint ,
	fetchedAt datetime2 default getdate()
) on FactFG
go

CREATE CLUSTERED COLUMNSTORE INDEX factOrderCCI 
ON factOrder with (DATA_COMPRESSION = COLUMNSTORE)
go

create NONCLUSTERED index factOrderNCI
on factOrder(productKey , orderBk)
go


-- create foreign keys for fact order
ALTER TABLE NorthwindDW..factOrder
ADD CONSTRAINT FK_OrderDate
FOREIGN KEY (orderDateKey) REFERENCES NorthwindDW..dimDate(dateKey);
GO

ALTER TABLE NorthwindDW..factOrder
ADD CONSTRAINT FK_ShippedDate
FOREIGN KEY (shippedDateKey) REFERENCES NorthwindDW..dimDate(dateKey);
GO

ALTER TABLE NorthwindDW..factOrder
ADD CONSTRAINT FK_RequiredDate
FOREIGN KEY (requiredDateKey) REFERENCES NorthwindDW..dimDate(dateKey);
GO

ALTER TABLE NorthwindDW..factOrder
ADD CONSTRAINT FK_OrderCustomer
FOREIGN KEY (customerKey) REFERENCES NorthwindDW..dimCustomer(customerKey);
GO


ALTER TABLE NorthwindDW..factOrder
ADD CONSTRAINT FK_OrderProduct
FOREIGN KEY (productKey) REFERENCES NorthwindDW..dimProduct(productKey);
GO

ALTER TABLE NorthwindDW..factOrder
ADD CONSTRAINT FK_OrderEmployee
FOREIGN KEY (employeeKey) REFERENCES NorthwindDW..dimEmployee(employeeKey);
GO

ALTER TABLE NorthwindDW..factOrder
ADD CONSTRAINT FK_OrderShipper
FOREIGN KEY (shipperKey) REFERENCES NorthwindDW..dimShipper(shipperKey);
GO

ALTER TABLE NorthwindDW..factOrder
ADD CONSTRAINT FK_CustomerLocation
FOREIGN KEY (customerLocationKey) REFERENCES NorthwindDW..dimLocation(locationKey);
GO

ALTER TABLE NorthwindDW..factOrder
ADD CONSTRAINT FK_productSupplierLocation
FOREIGN KEY (productSupplierLocationKey) REFERENCES NorthwindDW..dimLocation(locationKey);
GO

ALTER TABLE NorthwindDW..factOrder
ADD CONSTRAINT FK_shipLocation
FOREIGN KEY (shipLocationKey) REFERENCES NorthwindDW..dimLocation(locationKey);
GO








