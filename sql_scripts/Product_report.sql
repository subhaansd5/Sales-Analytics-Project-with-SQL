---------**** #### Reporting #### ****----------------

/*
=================================================================================
Product Report
=================================================================================
Purpose:-  This report consolidates key product metrics and behaviour.

Highlights: 
	1. Gather essential fields such product name, category, subcategory, and cost.
	2. Segment products by revenue to identify high performers, mid-range, and low performers.
	3. Aggregate product-level metrics.
		- total orders
		- total sales
		- total quantity sold
		- total unique customers
		- lifespan (in months)

	4. Calculate Valuable KPIs:
		- Recency (Month since last sale)
		- Average Order Revenue (AOR)
		- Average Monthly Revenue

==================================================================================

*/
CREATE VIEW gold.report_products AS

WITH base_query AS (

/*
=====================================================
Base Query: retrieves core columns from the tables
=====================================================
*/

SELECT f.order_number,
	   f.order_date,
	   f.customer_key,
	   f.quanity AS quantity,
	   f.sales_amount,
	   p.product_key,
	   p.product_name,
	   p.category,
	   p.sub_category,
	   p.product_cost

FROM gold.dim_products p
LEFT JOIN gold.fact_sales f
ON p.product_key = f.customer_key
WHERE order_date IS NOT NULL

)
, product_aggregations AS (
/*
=============================================================
product_aggregations: summarizes key metrics at product level
=============================================================
*/

SELECT 
	   product_key,
	   product_name,
	   category,
	   sub_category,
	   product_cost,
	   DATEDIFF(Month,MIN(order_date),MAX(order_date)) AS lifespan,
	   MAX(order_date) AS last_sale_date,
       COUNT(DISTINCT order_number) AS total_orders, 
	   SUM(sales_amount) AS total_sales,
	   SUM(quantity) AS total_quantity_sold,
	   COUNT(DISTINCT customer_key) AS total_customer,
	   ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity,0)),2) AS avg_selling_price
FROM base_query
GROUP BY product_key,
	   product_name,
	   category,
	   sub_category,
	   product_cost )

/*
==============================================================
Final query : Combine all product results into one output 
==============================================================
*/

SELECT product_key,
	   product_name,
	   category,
	   sub_category,
	   product_cost,
	   last_sale_date,
	   DATEDIFF(month, last_sale_date, GETDATE()) AS recency_in_months,
	   CASE WHEN total_sales > 10000 THEN 'High Performer'
			WHEN total_sales >=3000 THEN 'Mid-range'
			ELSE 'Low Perfomer'
	   END AS 'Pproduct_segement',
	   lifespan,
	   total_orders, 
	   total_sales,
	   total_quantity_sold,
	   total_customer,
	   avg_selling_price
FROM product_aggregations

SELECT * FROM gold.report_products