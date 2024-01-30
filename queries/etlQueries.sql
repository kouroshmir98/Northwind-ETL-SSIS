-- 

-- truncate EmployeeStg
TRUNCATE TABLE NorthwindStg..employeeStg
GO

-- Get lastFetchedRowVer from NorthwindDWConf..DWConf for Employees
SELECT
    lastFetchedRowVer
FROM NorthwindDWConf..DWConf
WHERE tableName = 'Employees'

-- fetch employee's data for employeeStg
select 
    EmployeeID , 
    ReportsTo as managerId ,
    LastName ,
    FirstName ,
    Title ,
    TitleOfCourtesy , 
    CAST(BirthDate as date ) as birthDate ,
    CAST(HireDate as date) as hireDate,
    Country , 
    Region , 
    City ,
    PostalCode , 
    cast(verRec as bigint) as verRec
from Northwind..Employees
WHERE verRec > CAST(cast( 0 as bigint) as timestamp)

-- calculate hashes for employeeStg  
Update NorthwindStg..employeeStg
SET dataHash = 
                HASHBYTES('SHA2_512',
                            CONCAT(
                                    COALESCE(managerId ,0) ,
                                    lastName , 
                                    firstName ,
                                    title ,
                                    titleOfCourtesy ,
                                    birthDate ,
                                    hireDate ,
                                    country ,
                                    region ,
                                    city ,
                                    postalCode
                                )
                        )
-- fill dimEmployee sql statement
with sourceData as (
    select
        employeeId as employeeKey , 
        employeeId as employeeBK ,
        managerId , 
        lastName , 
        firstName , 
        title , 
        CASE 
            when titleOfCourtesy = 'Mrs.' or titleOfCourtesy = 'Ms.' then 'Female'
            when  titleOfCourtesy = 'Mr.' then 'Male'
            else 'None'
        END as gender , 
        birthDate ,
        hireDate , 
        country , 
        city ,
        region , 
        postalCode , 
        dataHash , 
        verRec
    from NorthwindStg..employeeStg)
MERGE NorthwindDW..dimEmployee as t USING sourceData as s
ON s.employeeBK = t.employeeBK
WHEN MATCHED AND (s.dataHash != t.dataHash)
    THEN UPDATE 
        SET
            t.managerId = s.managerId  ,
            t.lastName = s.lastName  ,
            t.firstName = s.firstName  ,
            t.title = s.title  ,
            t.gender = s.gender  ,
            t.birthDate = s.birthDate  ,
            t.hireDate = s.hireDate  ,
            t.country = s.country  ,
            t.city = s.city  ,
            t.region = s.region  ,
            t.postalCode = s.postalCode  ,
            t.dataHash = s.dataHash ,
            t.verRec = s.verRec  ,
            t.fetchedAt  = GETDATE()

WHEN NOT MATCHED BY TARGET 
    THEN INSERT (
                employeeKey , 
                employeeBK ,
                managerId ,
                lastName ,
                firstName ,
                title ,
                gender ,
                birthDate ,
                hireDate ,
                country ,
                city ,
                region ,
                postalCode ,
                dataHash ,
                verRec
    )
         VALUES (
                s.employeeKey , 
                s.employeeBK ,
                s.managerId ,
                s.lastName ,
                s.firstName ,
                s.title ,
                s.gender ,
                s.birthDate ,
                s.hireDate ,
                s.country ,
                s.city ,
                s.region ,
                s.postalCode ,
                s.dataHash ,
                s.verRec
         );

-- check dimEmployee
select 
    * 
from NorthwindDW..dimEmployee
GO




-- check employeeStg
select 
    *
from NorthwindStg..employeeStg

-- update employee lastRowVer
UPDATE NorthwindDWConf..DWConf
SET 
lastFetchedRowVer = (
                        select 
                            max(verRec)
                        from NorthwindDW..dimEmployee 
                    )
WHERE tableName = 'Employees'
go
--
UPDATE NorthwindDWConf..DWConf
SET 
    lastFetchedRowVer = 0
go
-- check lastFetchedRowVer
select 
    * 
from  NorthwindDWConf..DWConf


--


-- truncate ShipperStg
TRUNCATE TABLE NorthwindStg..shipperStg
go

-- Get lastFetchedRowVer from NorthwindDWConf..DWConf for shippers
SELECT
    lastFetchedRowVer
FROM NorthwindDWConf..DWConf
WHERE tableName = 'Shippers'


-- fetch shipper's data for shipperStg
SELECT
    ShipperID ,
    CompanyName as shipperName,
    cast(verRec as BIGINT) as verRec
FROM Northwind..Shippers
WHERE verRec > CAST(3079 as timestamp)

-- fill dimShipper sql statement
with sourceData as (
select 
    shipperId as shipperKey ,
    shipperId as shipperBK ,
    shipperName , 
    verRec
from NorthwindStg..shipperStg)
MERGE NorthwindDW..dimShipper as t
USING sourceData as s
ON (s.shipperBK = t.shipperBK)
WHEN MATCHED AND (s.shipperName <> t.shipperName)
    THEN UPDATE
        SET
            t.shipperName = s.shipperName ,
            t.verRec = s.verRec ,
            t.fetchedAt = GETDATE()
WHEN NOT MATCHED BY TARGET
    THEN 
        insert (shipperKey , shipperBK , shipperName , verRec )
        VALUES ( s.shipperKey , s.shipperBK , s.shipperName , s.verRec);        

-- check shipperStg
select 
    *
from NorthwindStg..shipperStg
GO

-- check shipperDW
select 
    *
from NorthwindDW..dimShipper
GO

-- update employee lastRowVer
UPDATE NorthwindDWConf..DWConf
SET 
lastFetchedRowVer = (
                        select 
                            max(verRec)
                        from NorthwindDW..dimShipper 
                    )
WHERE tableName = 'Shippers'
go
--
UPDATE NorthwindDWConf..DWConf
SET 
    lastFetchedRowVer = 0
go
-- check lastFetchedRowVer
select 
    * 
from  NorthwindDWConf..DWConf
go
-- truncate dimShipper
TRUNCATE TABLE NorthwindDW..dimShipper
GO



--

-- truncate producStg
truncate TABLE NorthwindStg..productStg
GO

-- Get lastFetchedRowVer from NorthwindDWConf..DWConf for Products
SELECT
    lastFetchedRowVer
FROM NorthwindDWConf..DWConf
WHERE tableName = 'Products'


-- fetch product's data for productStg
select 
    p.ProductID,
    p.SupplierID,
    p.CategoryID,
    p.ProductName,
    p.Discontinued,
    s.CompanyName as supplierName , 
    COALESCE(s.City , 'None')  as supplierCity ,
    COALESCE(s.Region , 'None')  as supplierRegion , 
    COALESCE(s.Country , 'None')  as supplierCountry ,
    s.PostalCode as supplierPostalCode ,
    c.CategoryName ,
    cast(p.verRec as bigint) as verRec
from Northwind..Products as p
LEFT JOIN Northwind..Suppliers as s on s.SupplierID = p.SupplierID
LEFT JOIN Northwind..Categories as c on p.CategoryID = c.CategoryID
WHERE p.verRec > CAST(cast(2170 as bigint) as timestamp)
GO

-- calculate hashes for productStg

update NorthwindStg..ProductStg
SET 
    dataHash = 
                HASHBYTES('SHA2_512' , 
                            CONCAT(categoryId , productName  , discontinued  , supplierName , supplierCity , supplierRegion , supplierCountry , supplierPostalCode , categoryName)
                        ) ,
    supplierLocationHash =  
                            HASHBYTES('SHA2_512' ,
                                        CONCAT(supplierCountry , supplierCity , supplierRegion) 
                                    )

-- fill DimProduct
with sourceData as ( 
select 
    p.productId as productKey ,
    p.productId as productBK,
    p.supplierId ,
    p.categoryId , 
    p.productName , 
    p.discontinued  ,
	p.supplierName  ,
	p.supplierCity  ,
	p.supplierRegion  ,
	p.supplierCountry  ,
	p.supplierPostalCode  ,
	p.categoryName  ,
	p.dataHash  ,
	p.verRec ,
    p.supplierLocationHash ,
    l.locationKey as productSupplierLocationKey
from NorthwindStg..ProductStg as p
LEFT JOIN NorthwindDW..dimLocation as l on p.supplierLocationHash = l.dataHash)
MERGE NorthwindDW..dimProduct as t
    USING sourceData s
ON (s.productBK = t.productBK)
WHEN MATCHED AND (s.dataHash <> t.dataHash)
    THEN UPDATE
        SET 
            t.productName = s.productName , 
            t.discontinued = s.discontinued  ,
            t.supplierName = s.supplierName  ,
            t.supplierCity = s.supplierCity  ,
            t.supplierRegion = s.supplierRegion  ,
            t.supplierCountry = s.supplierCountry  ,
            t.supplierPostalCode = s.supplierPostalCode  ,
            t.categoryName = s.categoryName  ,
            t.dataHash = s.dataHash  ,
            t.verRec = s.verRec ,
            t.productSupplierLocationKey = s.productSupplierLocationKey,
            t.fetchedAt = GETDATE()
WHEN NOT MATCHED BY TARGET 
    THEN
        INSERT (
                productKey ,
                productBK ,
                supplierId ,
                categoryId , 
                productName , 
                discontinued  ,
                supplierName  ,
                supplierCity  ,
                supplierRegion  ,
                supplierCountry  ,
                supplierPostalCode  ,
                categoryName  ,
                dataHash  ,
                verRec ,
                productSupplierLocationKey
        )
        VALUES(
                s.productKey ,
                s.productBK ,
                s.supplierId ,
                s.categoryId , 
                s.productName , 
                s.discontinued  ,
                s.supplierName  ,
                s.supplierCity  ,
                s.supplierRegion  ,
                s.supplierCountry  ,
                s.supplierPostalCode  ,
                s.categoryName  ,
                s.dataHash  ,
                s.verRec ,
                s.productSupplierLocationKey
        );
go



-- truncate dimProduct
TRUNCATE TABLE NorthwindDW..dimProduct
go
-- check dimProduct
select 
    * 
from NorthwindDW..dimProduct
GO
-- check productStg
select 
    *
from NorthwindStg..ProductStg
GO

-- check DWConf
SELECT
    lastFetchedRowVer
FROM NorthwindDWConf..DWConf
GO

-- reset DWConf
UPDATE NorthwindDWConf..DWConf
SET 
    lastFetchedRowVer = 0
GO

-- update DWConf
UPDATE NorthwindDWConf..DWConf
SET 
    lastFetchedRowVer = (
        select 
            max(verRec)
        from NorthwindDW..dimProduct
    )
WHERE tableName = 'Products'
GO


--
-- truncate orderStg
TRUNCATE TABLE NorthwindStg..orderStg
GO
-- Get lastFetchedRowVer from NorthwindDWConf..DWConf for Orders
SELECT
    lastFetchedRowVer
FROM NorthwindDWConf..DWConf
WHERE tableName = 'Orders'
-- fetch order's data for orderStg
select 
    o.OrderID ,
    o.CustomerID ,
    o.EmployeeID ,
    od.ProductID ,
    o.ShipVia as shipperId ,
    o.OrderDate ,
    o.RequiredDate , 
    o.ShippedDate ,
    o.Freight ,
    od.UnitPrice , 
    od.Quantity , 
    od.Discount , 
    coalesce (o.ShipCity , 'None') as shipCity , 
    coalesce (o.ShipRegion , 'None') as shipRegion , 
    coalesce (o.ShipCountry , 'None') as shipCountry , 
    coalesce (o.ShipPostalCode , 'None') as shipPostalCode , 
    cast(o.verRec as bigint) as verRec
FROM Northwind..Orders as o
LEFT JOIN Northwind..[Order Details] as od on od.OrderID = o.OrderID
WHERE o.verRec > cast( cast( 0 as bigint ) as timestamp )
-- calculate hashes for orderStg
update NorthwindStg..orderStg
SET 
    dataHash = 
                HASHBYTES('SHA2_512' , 
                            CONCAT( customerId , 
                                    employeeId , 
                                    productId , 
                                    shipperId , 
                                    orderDate , 
                                    requiredDate , 
                                    shippedDate , 
                                    unitPrice , 
                                    quantity , 
                                    discount , 
                                    freight ,
                                    shipCity , 
                                    shipRegion , 
                                    shipCountry , 
                                    shipPostalCode )
                        ) ,
    shipLocationHash = 
                        HASHBYTES('SHA2_512' , 
                                    CONCAT(shipCountry , 
                                           shipCity , 
                                           shipRegion)
                                )

-- fill dimOrder
with sourceData as (
select 
    o.orderId as orderKey ,
    o.orderId as orderBK ,
    c.customerKey ,
    o.employeeId as employeeKey ,
    o.productId as productKey ,
    o.shipperId as shipperKey ,
    cast(FORMAT(o.orderDate , 'yyyyMMdd') as int ) as orderDateKey ,
    cast(FORMAT(o.shippedDate , 'yyyyMMdd') as int ) as shippedDateKey ,
    cast(FORMAT(o.requiredDate , 'yyyyMMdd') as int ) as requiredDateKey ,
    l.locationKey as shipLocationKey , 
    c.customerLocationKey ,
    p.productSupplierLocationKey , 
    o.orderDate , 
    o.requiredDate , 
    o.shippedDate , 
    o.unitPrice , 
    o.quantity , 
    o.discount ,
    o.freight ,
    o.shipPostalCode , 
    o.dataHash , 
    o.verRec
from NorthwindStg..orderStg as o
LEFT JOIN NorthwindDW..dimCustomer as c on c.customerBK = o.customerId 
LEFT JOIN NorthwindDW..dimLocation as l on l.dataHash = o.shipLocationHash 
LEFT JOIN NorthwindDW..dimProduct as p on p.productBK = o.productId )
MERGE NorthwindDW..factOrder as t
    USING sourceData as s
ON (s.orderBK = t.orderBK AND s.productKey = t.productKey)
WHEN MATCHED AND (s.dataHash <> t.dataHash)
    THEN UPDATE 
        SET 
            t.customerKey = s.customerKey ,
            t.employeeKey = s.employeeKey ,
            t.productKey = s.productKey ,
            t.shipperKey = s.shipperKey ,
            t.orderDateKey = s.orderDateKey ,
            t.shippedDateKey = s.shippedDateKey ,
            t.requiredDateKey = s.requiredDateKey ,
            t.shipLocationKey = s.shipLocationKey , 
            t.customerLocationKey = s.customerLocationKey ,
            t.productSupplierLocationKey = s.productSupplierLocationKey , 
            t.orderDate = s.orderDate , 
            t.requiredDate = s.requiredDate , 
            t.shippedDate = s.shippedDate , 
            t.unitPrice = s.unitPrice , 
            t.quantity = s.quantity , 
            t.discount = s.discount , 
            t.freight = s.freight ,
            t.shipPostalCode = s.shipPostalCode , 
            t.dataHash = s.dataHash , 
            t.verRec = s.verRec ,
            t.fetchedAt =  GETDATE()


WHEN NOT MATCHED BY TARGET 
    THEN 
        INSERT (
            orderKey ,
            orderBK ,
            customerKey ,
            employeeKey ,
            productKey ,
            shipperKey ,
            orderDateKey ,
            shippedDateKey ,
            requiredDateKey ,
            shipLocationKey , 
            customerLocationKey ,
            productSupplierLocationKey , 
            orderDate , 
            requiredDate , 
            shippedDate , 
            unitPrice , 
            quantity , 
            discount ,
            freight , 
            shipPostalCode , 
            dataHash , 
            verRec
               )
         VALUES (
                s.orderKey ,
                s.orderBK ,
                s.customerKey ,
                s.employeeKey ,
                s.productKey ,
                s.shipperKey ,
                s.orderDateKey ,
                s.shippedDateKey ,
                s.requiredDateKey ,
                s.shipLocationKey ,
                s.customerLocationKey ,
                s.productSupplierLocationKey ,
                s.orderDate ,
                s.requiredDate ,
                s.shippedDate ,
                s.unitPrice ,
                s.quantity ,
                s.discount ,
                s.freight ,
                s.shipPostalCode ,
                s.dataHash ,
                s.verRec
         );

-- truncate factOrder
TRUNCATE TABLE NorthwindDW..factOrder
go
-- check factOrder
select 
    * 
from NorthwindDW..factOrder
order by verRec DESC
GO
-- check OrderStg
select 
    *
from NorthwindStg..OrderStg
GO

-- check DWConf
SELECT
    *
FROM NorthwindDWConf..DWConf
GO

-- reset DWConf
UPDATE NorthwindDWConf..DWConf
SET 
    lastFetchedRowVer = 0
GO

-- update DWConf
UPDATE NorthwindDWConf..DWConf
SET 
    lastFetchedRowVer = (
        select 
            max(verRec)
        from NorthwindDW..factOrder
    )
WHERE tableName = 'Orders'
GO






--
-- truncate customerStg
TRUNCATE TABLE NorthwindStg..customerStg
GO
-- Get lastFetchedRowVer from NorthwindDWConf..DWConf for Customers
SELECT
    lastFetchedRowVer
FROM NorthwindDWConf..DWConf
WHERE tableName = 'Customers'
-- fetch customer's data for customerStg
select 
    CustomerID ,
    CompanyName as customerName,
    coalesce(Country ,'None') as country,
    coalesce(City ,'None') as city,
    coalesce(Region, 'None') as region,
    coalesce(PostalCode , 'None') as postalCode ,
    cast(verRec as bigint) as verRec  

from Northwind..Customers
WHERE verRec > CAST( cast( 0 as bigint) as timestamp)

-- calculate hashes for customerStg
update NorthwindStg..customerStg
SET 
    dataHash = 
                HASHBYTES('SHA2_512' ,
                    CONCAT(customerName , 
                            country , 
                            city , 
                            region , 
                            postalCode)
                ),
    locationHash = 
                    HASHBYTES('SHA2_512' ,
                        CONCAT(country , city , region)
                    )

-- fill dimCustomer
WITH sourceData as (
    select 
        c.customerId as customerBK ,
        c.customerName , 
        c.city as customerCity , 
        c.region as customerRegion , 
        c.country as customerCountry ,
        c.postalCode , 
        c.verRec , 
        c.dataHash , 
        l.locationKey as customerLocationKey
    from NorthwindStg..customerStg as c
    left join NorthwindDW..dimLocation as l on l.dataHash = c.locationHash)
MERGE NorthwindDW..dimCustomer as t
    USING sourceData as s
ON (s.customerBK = t.customerBK)
WHEN MATCHED AND (s.dataHash <> t.dataHash)
    THEN UPDATE 
        SET 
            t.customerName = s.customerName , 
            t.customerCity = s.customerCity , 
            t.customerRegion = s.customerRegion , 
            t.customerCountry = s.customerCountry ,
            t.postalCode = s.postalCode , 
            t.verRec = s.verRec , 
            t.dataHash = s.dataHash , 
            t.customerLocationKey = s.customerLocationKey , 
            t.fetchedAt = GETDATE()
WHEN NOT MATCHED BY TARGET 
    THEN 
        INSERT (
            customerBK ,
            customerName ,
            customerCity ,
            customerRegion ,
            customerCountry ,
            postalCode ,
            verRec ,
            dataHash ,
            customerLocationKey
        )
        VALUES (
            s.customerBK ,
            s.customerName ,
            s.customerCity ,
            s.customerRegion ,
            s.customerCountry ,
            s.postalCode ,
            s.verRec ,
            s.dataHash ,
            s.customerLocationKey
        ) ;

-- truncate dimCustomer
TRUNCATE TABLE NorthwindDW..dimCustomer
go
-- check dimCustomer
select 
    * 
from NorthwindDW..dimCustomer
GO
-- check CustomerStg
select 
    *
from NorthwindStg..CustomerStg
GO

-- check DWConf
SELECT
    *
FROM NorthwindDWConf..DWConf
GO

-- reset DWConf
UPDATE NorthwindDWConf..DWConf
SET 
    lastFetchedRowVer = 0
GO

-- update DWConf
UPDATE NorthwindDWConf..DWConf
SET 
    lastFetchedRowVer = (
        select 
            max(verRec)
        from NorthwindDW..dimCustomer
    )
WHERE tableName = 'Customers'
GO



--
-- truncate locationStg
TRUNCATE TABLE NorthwindStg..locationStg
GO

-- fill locationStg
INSERT into 
    NorthwindStg..locationStg 
    (country , city , region , dataHash)
(
    SELECT
        country,
        city,
        region,
        locationHash as dataHash
    FROM NorthwindStg..customerStg
    UNION
    SELECT
        supplierCountry as country ,
        supplierCity as city ,
        supplierRegion as region ,
        supplierLocationHash as dataHash
    from NorthwindStg..ProductStg
    UNION
    SELECT
        shipCountry as country , 
        shipCity as city ,
        shipRegion as region ,
        shipLocationHash as dataHash
    FROM NorthwindStg..orderStg
)

-- fill dimLocation
MERGE NorthwindDW..dimLocation as t
    USING NorthwindStg..locationStg as s
ON ( s.dataHash = t.dataHash )
WHEN NOT MATCHED BY TARGET
    THEN
        INSERT ( city , region , country , dataHash )
        VALUES (s.city , s.region , s.country , s.dataHash);

-- check dimLocation
select 
    *
from NorthwindDW..dimLocation



-- chech locationStg
select 
    *
from NorthwindStg..locationStg
GO



-- fill dimDate query


BEGIN TRANSACTION
	DECLARE @MinStgDate DATE , @MaxStgDate DATE , @MinDimDate DATE , @MaxDimDate DATE , @CountDimDate int , @TempDate DATE
	select 
		@MaxStgDate = (t.DateRec)
	from (
			SELECT 
				max(orderDate) as DateRec
			from NorthwindStg..orderStg
			WHERE orderDate IS NOT NULL
			UNION
			SELECT 
				max(requiredDate) as DateRec
			from NorthwindStg..orderStg
			WHERE requiredDate IS NOT NULL
			UNION
			SELECT 
				max(shippedDate) as DateRec
			from NorthwindStg..orderStg
			WHERE shippedDate IS NOT NULL
		) as t
	


	select 
		@MinStgDate = MIN(t.DateRec)
	from (
			SELECT 
				Min(orderDate) as DateRec
			from NorthwindStg..orderStg
			WHERE orderDate IS NOT NULL
			UNION
			SELECT 
				Min(requiredDate) as DateRec
			from NorthwindStg..orderStg
			WHERE requiredDate IS NOT NULL
			UNION
			SELECT 
				Min(shippedDate) as DateRec
			from NorthwindStg..orderStg
			WHERE shippedDate IS NOT NULL
	) as t
	

	select
		@MinDimDate =  MIN(fullDate)
	from NorthwindDW..dimDate
	

	select
		@MaxDimDate = Max(fullDate)
	from NorthwindDW..dimDate

	select
		@CountDimDate = COUNT(*)
	from NorthwindDW..dimDate

	IF @CountDimDate = 0 
	BEGIN
		EXECUTE usp_fillDimDate @MinStgDate , @MaxStgDate
	END
		
	ELSE
		BEGIN
			IF @MaxDimDate < @MaxStgDate
			BEGIN
				select @TempDate = DATEADD(DAY , 1 , @MaxDimDate)
				EXECUTE usp_fillDimDate @TempDate , @MaxStgDate
			END

			IF @MinDimDate > @MinStgDate
			BEGIN
				select @TempDate = DATEADD(DAY , -1 , @MinDimDate)
				EXECUTE usp_fillDimDate @MinStgDate , @TempDate
			END
		END
COMMIT;
