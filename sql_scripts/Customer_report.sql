---------**** #### Reporting #### ****----------------

/*
=================================================================================
Customer Report
=================================================================================
Purpose:-  This report consolidates key customer metrics and behaviour

Highlights: 
	1. Gather essential fields such names, ages and transactional details.
	2. Segment customer in categories (VIP, Regular, New) and Age groups.
	3. Aggregate customer-level metrics.
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)

	4. Calculate Valuable KPIs:
		- Recency (Month since last order)
		- Average Order Value
		- Average Monthly Spend

==================================================================================

*/
IF EXISTS (SELECT * FROM sys.views WHERE name = 'gold.report_customers')
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS
WITH base_query AS (

/*
=====================================================
Base Query: retrieves core columns from the tables
=====================================================
*/

SELECT 
	   CONCAT(c.first_name,' ',c.last_name) AS customer_name,
	   DATEDIFF(YEAR,c.birthdate,GETDATE()) AS Age,
	   c.customer_key,
	   c.custome_number,
	   f.order_date,
	   f.product_key,
	   f.order_number,
	   f.sales_amount,
	   f.quanity AS quantity

FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
WHERE order_date IS NOT NULL
)

, customer_aggregation AS 
(
/*
==================================================================
Customer Aggregates : Summarizes key metrics at customers level
==================================================================
*/
SELECT 
	   customer_name,
	   Age,
	   customer_key,
	   custome_number,
	   COUNT(DISTINCT order_number) AS total_orders,
	   SUM(sales_amount) AS total_sales,
	   SUM(quantity) AS total_quantity,
	   COUNT(DISTINCT product_key) AS total_products,
	   MAX(order_date) AS last_order_date,
	   DATEDIFF(month, MIN(order_date), GETDATE()) AS lifespan
FROM base_query
GROUP BY customer_name,
	   Age,
	   customer_key,
	   custome_number

)

SELECT 
	   customer_name,
	   customer_key,
	   custome_number,
	   Age,
	   CASE WHEN Age < 20 THEN 'Under 20'
			WHEN Age BETWEEN 20 AND 29 THEN '20 - 29'
			WHEN Age BETWEEN 30 AND 39 THEN '30 - 39'
			WHEN Age BETWEEN 40 AND 49 THEN '40 - 49'
			ELSE '50 and Above'
	   END 'Age_group',
	   CASE WHEN total_sales > 5000 AND lifespan >= 12 THEN 'VIP'
		    WHEN total_sales <=5000 AND lifespan >= 12 THEN 'Regular'
		    ELSE 'New'
	   END 'cx_segment',
	   last_order_date,
	   DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	   total_orders,
	   total_sales,
	   total_quantity,
	   total_products,
	   lifespan,
	   --compuate average order value
	   CASE WHEN total_sales = 0 THEN 0
	   ELSE total_sales / total_orders 
	   END AS AOV,
	   --compuate avreage monthly spend
	   CASE WHEN  lifespan = 0 THEN total_sales
	   ELSE	ROUND(CAST(total_sales AS FLOAT),2) / lifespan 
	   END AS 'AMS'
FROM customer_aggregation

--SELECT * FROM gold.report_customers