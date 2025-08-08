-- ***### Analytics ###***---

--- Trend ( Change over Time)
-- By year
SELECT YEAR(order_date) AS order_year,
	   SUM(sales_amount) AS total_sales,
	   COUNT(DISTINCT customer_key) AS total_customers,
	   SUM(quanity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

-- By Month
SELECT MONTH(order_date) AS order_month,
	   SUM(sales_amount) AS total_sales,
	   COUNT(DISTINCT customer_key) AS total_customers,
	   SUM(quanity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date)

-- By using Datetrunc to get each month of each year
SELECT DATETRUNC(MONTH, order_date) AS order_date,
	   SUM(sales_amount) AS total_sales,
	   COUNT(DISTINCT customer_key) AS total_customers,
	   SUM(quanity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date) 
ORDER BY DATETRUNC(MONTH, order_date)


--- Cumulative Analysis

-- Calculate the total sales per month
-- and running total of sales over the time

SELECT order_date,
	   total_sales,
	   avg_price,
	   SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	   AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
SELECT 
	DATETRUNC(Month,order_date) As Order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(Month,order_date) 
)t

--- Performance analysis

-- Analyze the yearly performance of the products by comapring their sales
-- avg sales of the product and previous years sales.


WITH yearly_products_sales 
AS (
SELECT YEAR(f.order_date) AS order_year,
	   p.product_name,
	   SUM(sales_amount) AS actual_sales
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p
ON f.customer_key = p.product_key
WHERE order_date IS NOT NULL AND product_name IS NOT NULL
GROUP BY YEAR(f.order_date),
p.product_name
)

SELECT order_year,
	   product_name,
	   actual_sales,
	   --Y-O-Y--- Analysis
	   AVG(actual_sales) OVER (PARTITION BY product_name) AS yearly_avg_sales,
	   actual_sales - AVG(actual_sales) OVER (PARTITION BY product_name) AS diff_sales,
	   CASE WHEN actual_sales - AVG(actual_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
			WHEN actual_sales - AVG(actual_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
			ELSE 'Avg'
	   END avg_change,
	   LAG(actual_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS P_Y_sales,
	   actual_sales - LAG(actual_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS P_Y_S_diff,
	   CASE WHEN actual_sales - LAG(actual_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'S_increase'
			WHEN actual_sales - LAG(actual_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'S_decrease'
			WHEN actual_sales - LAG(actual_sales) OVER(PARTITION BY product_name ORDER BY order_year) IS NULL THEN 'No Previous Year'
			ELSE 'No_change'
			END 'Sales_change'


FROM yearly_products_sales
ORDER BY product_name, order_year	   


--- Part to whole analysis----
-- Calculate which category contributes most to overall sales
WITH category_sales AS
(
SELECT p.category,
	   SUM(sales_amount) AS total_sales
FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p
ON f.customer_key = p.product_key
GROUP BY category
)

SELECT category,
	   total_sales,
	   SUM(total_sales) OVER() AS Overall_sales,
	   CONCAT(ROUND((CAST(total_sales AS float) / SUM(total_sales) OVER() ) * 100, 2), '%') AS percentage_as_total
FROM category_sales
ORDER BY total_sales DESC





--- Data Segmentation

/* Segment a products in to cost ranges and count how many products fall into each segment*/
 WITH products_segments AS 
 (
 SELECT p.product_key,
		p.product_name,
		p.product_cost,
		CASE WHEN p.product_cost < 100 THEN 'Below 100'
			 WHEN p.product_cost BETWEEN 100 AND 500 THEN '100 - 500'
			 WHEN p.product_cost BETWEEN 500 AND 1000 THEN '500 - 1000'
			 ELSE 'Above 1000'
		END 'cost_range'
 FROM gold.dim_products p )

 SELECT cost_range,
		COUNT(product_key) AS total_products
 FROM products_segments
 GROUP BY cost_range 
 ORDER BY total_products DESC


--- Group customers into 3 segments based on their spending behaviour
--VIP : atleast 12 month of history and spending more than 5000
--regular :  atleast 12 month of history and spending but spending 5000 or less
-- New : lifespan less than 12 month.

WITH customer_spending AS 
(
 SELECT c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		MIN(order_date) AS first_order,
		MAX(order_date) AS last_order,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
 FROM gold.dim_customers c 
 LEFT JOIN gold.fact_sales f
 ON c.customer_key = f.customer_key
 GROUP BY c.customer_key )

	SELECT cx_segment,
		COUNT(customer_key) AS total_customers
	FROM(	
			SELECT customer_key,
				   CASE WHEN total_spending > 5000 AND lifespan >= 12 THEN 'VIP'
				        WHEN total_spending <=5000 AND lifespan >= 12 THEN 'Regular'
				   ELSE 'New'
			       END 'cx_segment'
		    FROM customer_spending)t
			GROUP BY cx_segment
			ORDER BY total_customers DESC