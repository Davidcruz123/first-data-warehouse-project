/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

CREATE OR REPLACE VIEW gold.dim_customers AS (
SELECT
ROW_NUMBER() OVER(ORDER BY cust_info.cst_id) AS customer_key, --Surrogate key
cust_info.cst_id AS customer_id,cust_info.cst_key AS customer_number,
cust_info.cst_firstname AS first_name,
cust_info.cst_lastname AS last_name,
cust_loc.cntry AS country,
cust_info.cst_marital_status AS marital_status,
CASE 
	WHEN cust_info.cst_gndr !='n/a' THEN cust_info.cst_gndr
	ELSE COALESCE(cust_det.gen,'n/a') END AS gender,
cust_det.bdate AS birthday,

cust_info.cst_create_date AS create_date

FROM silver.crm_cust_info AS cust_info
	LEFT JOIN silver.erp_cust_az12 AS cust_det
	ON cust_info.cst_key=cust_det.cid
	LEFT JOIN silver.erp_loc_a101 AS cust_loc
	ON cust_info.cst_key = cust_loc.cid

);

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

CREATE OR REPLACE VIEW gold.dim_products AS (
	SELECT 
	ROW_NUMBER() OVER(ORDER BY p_inf.prd_start_dt,p_inf.prd_id) AS product_key,
	p_inf.prd_id AS product_id,
	p_inf.prd_key AS product_number,
	p_inf.prd_nm AS product_name,
	p_inf.cat_id AS category_id,
	p_cat.cat AS category,
	p_cat.subcat AS subcategory,
	p_cat.maintenance AS maintenance_required,
	p_inf.prd_cost AS product_cost,p_inf.prd_line AS product_line,p_inf.prd_start_dt AS product_start_date
	FROM silver.crm_prd_info AS p_inf
	LEFT JOIN silver.erp_px_cat_g1v2 AS p_cat
	ON p_inf.cat_id = p_cat.id
	WHERE p_inf.prd_end_dt IS NULL 

);

-- =============================================================================
-- Create Dimension: gold.fact_sales
-- =============================================================================

CREATE OR REPLACE VIEW gold.fact_sales AS (
	SELECT "sls_ord_num" AS order_number,
	"product_key",
	customer_key,
	"sls_order_dt" AS order_date,
	"sls_ship_dt" AS shipping_date,
	"sls_due_dt" AS due_date,
	"sls_sales" AS sales_amount,
	"sls_quantity" AS quantity,
	"sls_price" AS price
	FROM silver.crm_sales_details AS sales
	LEFT JOIN gold.dim_products AS prod
	ON sales.sls_prd_key = prod.product_number
	LEFT JOIN gold.dim_customers AS cust
	ON sales.sls_cust_id=cust.customer_id
);
