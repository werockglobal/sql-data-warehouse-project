/*
==========================================================================================
DDL Script: Create Silver Tables
==========================================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of the 'silver' tables.
 
Notes:
    - Requires SQL Server 2016+ (DROP TABLE IF EXISTS).
    - Each table carries a dwh_create_date audit column, filled automatically
      when a row is loaded.
==========================================================================================
*/


USE DataWarehouse;
GO

IF SCHEMA_ID(N'silver') IS NULL
    EXEC('CREATE SCHEMA silver');
GO

IF OBJECT_ID('silver.crm_cust_info' , 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.crm_cust_info;
END
CREATE TABLE silver.crm_cust_info (
    cst_id INT ,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_prd_info' , 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.crm_prd_info;
END
CREATE TABLE silver.crm_prd_info (
    prd_id INT ,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_strat_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_sales_details' , 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.crm_sales_details;
END
CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_loc_a101' , 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.erp_loc_a101;
END
CREATE TABLE silver.erp_loc_a101 (
    loc_cid NVARCHAR(50),
    loc_cntry NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_cust_az12' , 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.erp_cust_az12;
END
CREATE TABLE silver.erp_cust_az12(
    cust_cid NVARCHAR(50),
    cust_bdate DATE,
    cust_gen NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_px_cat_g1v2' , 'U') IS NOT NULL
BEGIN
    DROP TABLE silver.erp_px_cat_g1v2;
END
CREATE TABLE silver.erp_px_cat_g1v2(
    px_id NVARCHAR(50),
    px_cat NVARCHAR(50),
    px_subcat NVARCHAR(50),
    px_maintenance NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

