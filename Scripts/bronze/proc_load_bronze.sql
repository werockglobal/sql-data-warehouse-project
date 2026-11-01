/*
========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
========================================================================
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following:
    - Truncates the bronze tables before loading data.
    - Uses the 'BULK INSERT' command to load data from CSV files into bronze tables.

Usage Example
To execute code, RUN 
'EXEC bronze.load_bronze'
========================================================================
*/

EXEC bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY;
        SET @batch_start_time = GETDATE();
        Print '==============================================';
        Print 'Loading bronze layer';
        Print '==============================================';
        
        Print '----------------------------------------------';
        Print 'Loading CRM Tables';
        Print '----------------------------------------------';
        
        SET @start_time = GETDATE();
        Print '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        print '>> Inserting Data into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/datasets/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        Print '>> Load dURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        Print '----------------------------------------------';

        SET @start_time = GETDATE();
        Print '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        Print '>> Inserting Data into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/datasets/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        Print '>> Load dURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        Print '----------------------------------------------';

        SET @start_time = GETDATE();
        Print '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        Print '>> Inserting Data into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/datasets/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        Print '>> Load dURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        Print '----------------------------------------------';

        Print '----------------------------------------------';
        Print 'Loading ERP Tables';
        Print '----------------------------------------------';

        
        SET @start_time = GETDATE();Print '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        Print '>> Inserting Data into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/datasets/cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        Print '>> Load dURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        Print '----------------------------------------------';

        SET @start_time = GETDATE();
        Print '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        Print '>> Inserting Data into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/datasets/loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        Print '>> Load dURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        Print '----------------------------------------------';

        SET @start_time = GETDATE();
        Print '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        Print '>> Inserting Data into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/datasets/px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        Print '>> Load dURATION: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        Print '----------------------------------------------';
        
        SET @batch_end_time = GETDATE();
        Print '==============================================';
        Print 'Loading Bronze Layer is Completed';
        Print 'Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';
        Print '==============================================';
    END TRY
    BEGIN CATCH
        Print '==============================================';
        Print 'Error Occurred while loading bronze layer';
        print 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        print 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        print 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(10));
        print 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        print 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        Print '==============================================';
    END CATCH

END


