# Northwind ETL
In this project I designed a sample data warehouse for the Northwind database and also created an ETL pipeline using SSIS to incrementally load data from the OLTP database into the data warehouse.

## How to setup project
You can find all SQL Queries in 'queries/' folder <br/>
And all SSIS files in 'NWSSIS/'
### 1 : Create Northwind OLTP database
Run 'queries/northwindOLTP.sql' file to create the Northwind database. 
### 2 : Create NorthwindStg database
NorthwindStg is the staging database <br/>
To create staging database Run 'queries/createStagingArea.sql' file.
### 3 : create config database and feed it
I used config database ( NorthwindDWConf ) to store the last fetched row versions of each table to implement incremental loading.<br/>
Running the 'queries/createNorthwindDWConfTable.sql' file will create the NorthwindDWConf database and the DWConf table within it, and finally it will feed DWConf table.

### 4 : Now it's time to create our data warehouse
Running the 'queries/createDW.sql' file will create 'NorthwindDW' database <br/>
*** *Before running the file, you must specify `filename` for 'factData1' , 'factData2' , 'dimData1' and 'dimData2' data files inside the 'queries/createNorthwindDWConfTable.sql'*.
### 5 : Run 'queries/usp_fillDimDate.sql'
Running this file will create a STORED PROCEDURE inside `NorthwindDW` named `usp_fillDimDate` which is used to fill DimDate in the data warehouse
### 6 : Setup a SSIS project
Create a SSIS project using files inside 'NWSSIS/' folder and set database parameters. <br/>
***All database parameters are project parameter.***
#### Database parameters : 
- `Northwind_InitialCatalog` : This parameter is used to set initial catalog for `Northwind.conmgr` connection manager and it's default value is `Northwind` .
- `Northwind_ServerName` : This parameter is used to set server name for `Northwind.conmgr` connection manager and it's default value is `.` ( dot ) .
- `NorthwindDW_InitialCatalog` : This parameter is used to set initial catalog for `NorthwindDW.conmgr` connection manager and it's default value is `NorthwindDW` .
- `NorthwindDW_ServerName` : This parameter is used to set server name for `NorthwindDW.conmgr` connection manager and it's default value is `.` ( dot ) .
- `NorthwindDWConf_InitialCatalog` : This parameter is used to set initial catalog for `NorthwindDWConf.conmgr` connection manager and it's default value is `NorthwindDWConf` .
- `NorthwindDWConf_ServerName` : This parameter is used to set server name for `NorthwindDWConf.conmgr` connection manager and it's default value is `.` ( dot ) .
- `NorthwindStg_InitialCatalog` : This parameter is used to set initial catalog for `NorthwindStg.conmgr` connection manager and it's default value is `NorthwindStg` .
- `NorthwindStg_ServerName` : This parameter is used to set server name for `NorthwindStg.conmgr` connection manager and it's default value is `.` ( dot ) .

#### Connection managers : 
Here is a list of all connection managers which are used inside the project : 
- `Northwind.conmgr` : which is an `OLE DB` connection for sql server , it uses windows authentication to connect , it's initial catalog is `Northwind` and used to read and write data from and to `Northwind` databae
- `NorthwindDW.conmgr` : which is an `OLE DB` connection for sql server , it uses windows authentication to connect , it's initial catalog is `NorthwindDW` and used to read and write data from and to `NorthwindDW` databae
-`NorthwindDWConf` :  which is an `OLE DB` connection for sql server , it uses windows authentication to connect , it's initial catalog is `NorthwindDWConf` and used to read and write data from and to `NorthwindDWConf` databae
-`NorthwindStg`: which is an `OLE DB` connection for sql server , it uses windows authentication to connect , it's initial catalog is `NorthwindStg` and used to read and write data from and to `NorthwindStg` databae

### 7 : Run PackageOrchestrator and deploy the project
Running `PackageOrchestrator` package will run all packages.
