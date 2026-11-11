/*
==========================================================================================
DDL Script: Load Silver Layer (Bronza-> Silver)
==========================================================================================
Script Purpose:
   This stored procedure performs the ETL (Extract, Transform, Load) process
    to populate the 'silver' schema tables from the 'bronze' schema.
    Actions performed:
        - Truncates the silver tables.
        - Inserts transformed and cleansed data from bronze into silver.
 
Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.
 
Usage Example:
    EXEC silver.load_silver;
==========================================================================================
*/

EXEC silver.load_silver
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '==============================================';
        PRINT 'Loading Silver Layer';
        PRINT '==============================================';

        PRINT '----------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '----------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;
        PRINT '>>Inserting Data Into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'N/A'
            END AS cst_marital_status,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'N/A'
            END AS cst_gndr,
            cst_create_date
        FROM (
            SELECT
                cst_id,
                cst_key,
                cst_firstname,
                cst_lastname,
                cst_marital_status,
                cst_gndr,
                cst_create_date,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t WHERE flag_last = 1; -- Select only the most recent record for each cst_id based on cst_
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
        PRINT '----------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;
        PRINT '>>Inserting Data Into: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_strat_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,       -- category part of the key, e.g. AC-HE -> AC_HE
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,              -- product part of the key (matches sls_prd_key)
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_strat_dt AS DATE) AS prd_strat_dt,
            -- end date = the day before the next version of the same product starts
            CAST(LEAD(prd_strat_dt) OVER (PARTITION BY prd_key ORDER BY prd_strat_dt) - 1 AS DATE) AS prd_end_dt
        FROM bronze.crm_prd_info;
        SET @batch_end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
        PRINT '----------------------------------------------';

        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;
        PRINT '>>Inserting Data Into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL 
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
        END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL 
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
        END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL 
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
        END AS sls_due_dt,
        CASE WHEN sls_sales IS NULL OR sls_sales <= 0  OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,
        sls_quantity,
        CASE WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price
        FROM bronze.crm_sales_details
        SET @batch_end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
        PRINT '----------------------------------------------';
        
        PRINT '----------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '----------------------------------------------';
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT '>>Inserting Data Into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12 (
            cust_cid,
            cust_bdate,
            cust_gen
        )
        SELECT
            CASE
                WHEN cust_cid LIKE 'NAS%' THEN SUBSTRING(cust_cid, 4, LEN(cust_cid))   -- strip 'NAS' prefix
                ELSE cust_cid
            END AS cid,
            CASE
                WHEN cust_bdate > GETDATE() THEN NULL       -- future birthdates are invalid
                ELSE cust_bdate
            END AS bdate,
            CASE
                WHEN UPPER(TRIM(cust_gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(cust_gen)) IN ('M', 'MALE')   THEN 'Male'
                ELSE 'n/a'                        -- NULLs, blanks, unknown values
            END AS cust_gen
        FROM bronze.erp_cust_az12
        SET @batch_end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
        PRINT '----------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT '>>Inserting Data Into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101 (
            loc_cid, 
            loc_cntry
        )
        SELECT
            REPLACE(loc_cid, '-', '') loc_cid,
            -- Data standardization and consistency
            -- REPLACE(..., CHAR(13), '') strips the hidden carriage return left by BULK INSERT
            CASE
                WHEN TRIM(REPLACE(loc_cntry, CHAR(13), '')) = 'DE'           THEN 'Germany'
                WHEN TRIM(REPLACE(loc_cntry, CHAR(13), '')) IN ('US', 'USA') THEN 'United States'
                WHEN loc_cntry IS NULL
                OR TRIM(REPLACE(loc_cntry, CHAR(13), '')) = ''             THEN 'n/a'
                ELSE TRIM(REPLACE(loc_cntry, CHAR(13), ''))
            END AS loc_cntry
        FROM bronze.erp_loc_a101
        SET @batch_end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @start_time, @end_time) AS VARCHAR) + ' ms';
        PRINT '----------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT '>>Inserting Data Into: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2(
            px_id,
            px_cat,
            px_subcat,
            px_maintenance
        )
        SELECT
        px_id,
        px_cat,
        px_subcat,
        px_maintenance
        FROM bronze.erp_px_cat_g1v2
        SET @batch_end_time = GETDATE();
        PRINT '==============================================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT 'Total Load Duration: ' + CAST(DATEDIFF(MILLISECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + ' ms';
        PRINT '==============================================';
    END TRY
    BEGIN CATCH
        PRINT '==============================================';
        PRINT 'Error Occurred While Loading Silver Layer';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(10));
        PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT '==============================================';
        THROW;   -- re-raise so the caller knows the load failed
    END CATCH
END
