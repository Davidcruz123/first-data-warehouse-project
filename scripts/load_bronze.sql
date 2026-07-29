CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
    RAISE NOTICE 'Starting Bronze Layer Loading Process';
    RAISE NOTICE '==================================================';

    -- --------------------------------------------------
    -- 1. Load CRM Source Tables
    -- --------------------------------------------------
    RAISE NOTICE '--------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables...';
    RAISE NOTICE '--------------------------------------------------';

    -- Table: crm_prd_info
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and loading: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    COPY bronze.crm_prd_info
    FROM '/Users/david/Documents/David/david-development/sql-data-warehouse-project-main/datasets/source_crm/prd_info.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load completed in % seconds', ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time))::numeric, 2);

    -- Table: crm_sales_details
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and loading: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    COPY bronze.crm_sales_details
    FROM '/Users/david/Documents/David/david-development/sql-data-warehouse-project-main/datasets/source_crm/sales_details.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load completed in % seconds', ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time))::numeric, 2);


    -- --------------------------------------------------
    -- 2. Load ERP Source Tables
    -- --------------------------------------------------
    RAISE NOTICE '--------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables...';
    RAISE NOTICE '--------------------------------------------------';

    -- Table: erp_cust_az12
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and loading: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    COPY bronze.erp_cust_az12
    FROM '/Users/david/Documents/David/david-development/sql-data-warehouse-project-main/datasets/source_erp/CUST_AZ12.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load completed in % seconds', ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time))::numeric, 2);

    -- Table: erp_loc_a101
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and loading: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    COPY bronze.erp_loc_a101
    FROM '/Users/david/Documents/David/david-development/sql-data-warehouse-project-main/datasets/source_erp/LOC_A101.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load completed in % seconds', ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time))::numeric, 2);

    -- Table: erp_px_cat_g1v2
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating and loading: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    COPY bronze.erp_px_cat_g1v2
    FROM '/Users/david/Documents/David/david-development/sql-data-warehouse-project-main/datasets/source_erp/PX_CAT_G1V2.csv'
    WITH (FORMAT CSV, HEADER true, DELIMITER ',');
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load completed in % seconds', ROUND(EXTRACT(EPOCH FROM (v_end_time - v_start_time))::numeric, 2);

    -- Final Summary
    v_batch_end_time := clock_timestamp();
    RAISE NOTICE '==================================================';
    RAISE NOTICE 'Bronze layer load successfully completed.';
    RAISE NOTICE 'Total execution time: % seconds', ROUND(EXTRACT(EPOCH FROM (v_batch_end_time - v_batch_start_time))::numeric, 2);
    RAISE NOTICE '==================================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '==================================================';
        RAISE NOTICE 'ERROR OCCURRED DURING BRONZE LOAD: %', SQLERRM;
        RAISE NOTICE '==================================================';
        RAISE;
END;
$$;
