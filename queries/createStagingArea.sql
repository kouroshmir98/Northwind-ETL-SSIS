create database NorthwindStg
go

use NorthwindStg
go


if OBJECT_ID('ProductStg' , 'u') is not null
begin
	drop table ProductStg;
end


create table ProductStg(
	productId int ,
	supplierId int ,
	categoryId int ,
	productName nvarchar(40) ,
	discontinued bit ,
	supplierName nvarchar(40),
	supplierCity nvarchar(15), 
	supplierRegion nvarchar(15), 
	supplierCountry nvarchar(15),
	supplierPostalCode nvarchar(10),
	categoryName nvarchar(15),
	verRec bigint,
	supplierLocationHash varbinary(64),
	dataHash varbinary(64)
)


if OBJECT_ID('customerStg' , 'u') is not null
begin
	drop table customerStg;
end


create table customerStg(
	customerId nvarchar(5) ,
	customerName nvarchar(40) ,
	city nvarchar(15) ,
	region nvarchar(15) ,
	country nvarchar(15) ,
	postalCode nvarchar(10) ,
	verRec bigint ,
	locationHash varbinary(64) ,
	dataHash varbinary(64)
)

if OBJECT_ID('locationStg' , 'u') is not null
begin
	drop table locationStg;
end



create table locationStg(
	city nvarchar(15),
	region nvarchar(15),
	country nvarchar(15),
	dataHash varbinary(64)
)



if OBJECT_ID('shipperStg' , 'u') is not null
begin
	drop table shipperStg;
end
create table shipperStg(
	shipperId int , 
	shipperName nvarchar(40) , 
	verRec bigint
)

if OBJECT_ID('employeeStg' , 'u') is not null
begin
	drop table employeeStg;
end

create table employeeStg(
	employeeId int,
	managerId int ,
	lastName nvarchar(20),
	firstName nvarchar(10),
	title nvarchar(30),
	titleOfCourtesy nvarchar(25),
	birthDate date,
	hireDate date,
	country nvarchar(15),
	region nvarchar(15),
	city nvarchar(15) ,
	postalCode nvarchar(10),
	verRec bigint,
	dataHash varbinary(64)
)

if OBJECT_ID('orderStg' , 'u') is not null
begin
	drop table orderStg;
end
create table orderStg(
	orderId int ,
	customerId nvarchar(5) ,
	employeeId int ,
	productId int ,
	shipperId int ,
	orderDate date ,
	requiredDate date ,
	shippedDate date ,
	unitPrice decimal(19 , 2) ,
	quantity int , 
	discount decimal(5,2) ,
	freight DECIMAL(19 , 2) ,
	shipCity nvarchar(15) ,
	shipRegion nvarchar(15) ,
	shipCountry nvarchar(15) ,
	shipPostalCode nvarchar(10) ,
	verRec bigint ,
	shipLocationHash varbinary(64) ,
	dataHash varbinary(64)
)
