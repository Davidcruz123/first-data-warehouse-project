/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_batch_start_time TIMESTAMP;
    v_batch_end_time TIMESTAMP;
BEGIN
  v_batch_start_time := clock_timestamp();
     RAISE NOTICE '==================================================';
    RAISE NOTICE 'Starting Silver Layer Loading Process';
    RAISE NOTICE '==================================================';
    -- --------------------------------------------------
    -- 1. Load CRM Source Tables
    -- --------------------------------------------------
    RAISE NOTICE '--------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables...';
    RAISE NOTICE '--------------------------------------------------';

    -- Table: crm_cust_info
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and loading: silver.crm_cust_info';

    TRUNCATE TABLE silver.crm_cust_info;
    INSERT INTO silver.crm_cust_info (
    cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date
    ) 
    SELECT cst_id,cst_key,TRIM(cst_firstname) AS cst_firstname,TRIM(cst_lastname) AS cst_lastname,
    	CASE WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
    		WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
    		ELSE 'n/a' END AS cst_marital_status,
    	CASE WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
    		WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
    		ELSE 'n/a' END AS cst_gndr,
    	cst_create_date
    FROM (
    	SELECT *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    	FROM bronze.crm_cust_info
    	WHERE cst_id IS NOT NULL
    )t 
    WHERE flag_last=1;
      
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load completed in % seconds', ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time))::numeric, 2);

   -- Table: crm_sales_details
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and loading: silver.crm_sales_details';

    TRUNCATE TABLE silver.crm_sales_details;
	WITH transactions_cleaned AS (
		SELECT sls_ord_num,sls_prd_key,sls_cust_id,
		CASE WHEN LENGTH(sls_order_dt::TEXT)<8 THEN NULL
			ELSE TO_DATE(sls_order_dt::TEXT,'YYYYMMDD') END AS sls_order_dt,
		CASE WHEN LENGTH(sls_ship_dt::TEXT)<8 THEN NULL
			ELSE TO_DATE(sls_ship_dt::TEXT,'YYYYMMDD') END AS sls_ship_dt, 
		CASE WHEN LENGTH(sls_due_dt::TEXT)<8 THEN NULL
			ELSE TO_DATE(sls_due_dt::TEXT,'YYYYMMDD') END AS sls_due_dt,
		sls_sales,
		sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price<0 THEN sls_sales/NULLIF(sls_quantity,0)
			ELSE ABS(sls_price) END AS sls_price
		FROM bronze.crm_sales_details
	)
	
	INSERT INTO silver.crm_sales_details (
	sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price
	)
	SELECT sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,
	ABS(sls_quantity*sls_price) AS sls_sales,
	sls_quantity,sls_price
	FROM transactions_cleaned;


      
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load completed in % seconds', ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time))::numeric, 2);

-- Table: erp_cust_az12
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and loading: silver.erp_cust_az12';

    TRUNCATE TABLE silver.erp_cust_az12;

	INSERT INTO silver.erp_cust_az12 (cid,bdate,gen)
	SELECT  
		CASE
			WHEN LEFT(UPPER(cid),3)='NAS' THEN SUBSTRING(cid,4)
			ELSE cid
			END AS cid,
		CASE 
			WHEN bdate > '2007-01-01' THEN NULL
			ELSE bdate
		END AS bdate,
		CASE
			WHEN TRIM(gen) IN ('M','Male') THEN 'Male'
			WHEN TRIM(gen) IN ('F','Female') THEN 'Female'
			ELSE 'n/a' 
		END AS gen
	FROM bronze.erp_cust_az12;


    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load completed in % seconds', ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time))::numeric, 2);

    -- Final Summary
    v_batch_end_time := clock_timestamp();
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'Silver layer load successfully completed.';
    RAISE NOTICE 'Total execution time: % seconds', ROUND(EXTRACT(EPOCH FROM (v_batch_end_time - v_batch_start_time))::numeric, 2);
    RAISE NOTICE '==================================================';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '==================================================';
        RAISE NOTICE 'ERROR OCCURRED DURING SILVER LOAD: %', SQLERRM;
        RAISE NOTICE '==================================================';
        RAISE;
END;
$$;
