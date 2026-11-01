/*
==================================================================================
DDL Script: Created 6 Bronze Tables
==================================================================================
Script Purposes:
  This Script was used to create the bronze tables in the bronze schema and drop 
  existing tables if they already exist.
  Run this script to redefine the DDL structure of 'bronze' tables

==================================================================================
*/


IF OBJECT_ID('bronze.crm_cust_info' , 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_cust_info;
END
CREATE TABLE bronze.crm_cust_info (
    cst_id INT ,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_material_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);

IF OBJECT_ID('bronze.crm_prd_info' , 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_prd_info;
END
CREATE TABLE bronze.crm_prd_info (
    prd_id INT ,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_strat_dt DATETIME,
    prd_end_dt DATETIME
);

IF OBJECT_ID('bronze.crm_sales_details' , 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.crm_sales_details;
END
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id NVARCHAR(50),
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
);

IF OBJECT_ID('bronze.erp_loc_a101' , 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_loc_a101;
END
CREATE TABLE bronze.erp_loc_a101 (
    loc_cid NVARCHAR(50),
    loc_cntry NVARCHAR(50)
);

IF OBJECT_ID('bronze.erp_cust_az12' , 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_cust_az12;
END
CREATE TABLE bronze.erp_cust_az12(
    cust_cid NVARCHAR(50),
    cust_bdate DATE,
    cust_gen NVARCHAR(50),
);

IF OBJECT_ID('bronze.erp_px_cat_g1v2' , 'U') IS NOT NULL
BEGIN
    DROP TABLE bronze.erp_px_cat_g1v2;
END
CREATE TABLE bronze.erp_px_cat_g1v2(
    px_id NVARCHAR(50),
    px_cat NVARCHAR(50),
    px_subcat NVARCHAR(50),
    px_maintenance NVARCHAR(50),
);

