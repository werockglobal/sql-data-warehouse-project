/*
======================================================================================
##Create Database and Schemas
======================================================================================
**Script Purpose:**
This script is designed to create a new database titled 'DataWarehouse' after confirming 
whether it currently exists. Should the database be present, it will be dropped and subsequently 
recreated. Additionally, the script sets up three distinct schemas within the database: 'bronze', 
'silver', and 'gold'.

**Important Notice:**
Please be aware that executing this script will lead to the complete removal of the 'DataWarehouse' 
database if it is found to exist. This action will result in the permanent loss of all data within 
the database. It is essential to proceed with caution and to ensure that proper backups are in place 
prior to running this script.
*/


USE master;
GO
  
-- Drop and recreate the 'DataWarehouse' database
USE DataWarehouse;
IF DB_ID(N'DataWarehouse') IS NULL
  
BEGIN
    CREATE DATABASE DataWarehouse;
END
GO

USE DataWarehouse;
GO
  
--- Creating the Schemas 
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
