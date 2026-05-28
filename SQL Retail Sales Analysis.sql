SELECT * FROM public.retails_sales_data
ORDER BY transactions_id ASC LIMIT 100

SELECT COUNT (*)
FROM retails_sales_data

--DATA CLEANING
--Viewing NULL values (column by column)
SELECT * FROM retails_sales_data
WHERE sale_date IS NULL

SELECT * FROM retails_sales_data
WHERE sale_time IS NULL

SELECT * FROM retails_sales_data
WHERE customer_id IS NULL

SELECT * FROM retails_sales_data
WHERE gender IS NULL

SELECT * FROM retails_sales_data
WHERE age IS NULL


--Viewing NULL values (entire table)
SELECT FROM retails_sales_data
WHERE
	transactions_id IS NULL
or
	sale_date IS NULL
or
	sale_time IS NULL
or	
	customer_id IS NULL
or
	gender IS NULL
or
	age IS NULL
or 
	category IS NULL
or
	quantiy IS NULL
or
	price_per_unit IS NULL
or
	cogs IS NULL
or
	total_sale IS NULL;


--Delecting NULL values
DELETE FROM retails_sales_data
WHERE
	transactions_id IS NULL
or
	sale_date IS NULL
or
	sale_time IS NULL
or	
	customer_id IS NULL
or
	gender IS NULL
or
	age IS NULL
or 
	category IS NULL
or
	quantiy IS NULL
or
	price_per_unit IS NULL
or
	cogs IS NULL
or
	total_sale IS NULL;



--DATA EXPLORATION

--How many sales record do we have?
SELECT COUNT(*) AS total_sales
FROM retails_sales_data

--How many customers do we have?
SELECT COUNT(DISTINCT customer_id) AS total_num_customers
FROM retails_sales_data

--What are the categories  we have?
SELECT DISTINCT category
FROM retails_sales_data 



--DATA ANALYTICS AND BUSINESS KEY PROBLEMS
--Q1: Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT *
FROM  retails_sales_data
WHERE sale_date = '2022-11-05';

--Q2:Write a SQL query to retrieve all transactions where the category is 'Clothing' 
--and the quantity sold is more than 4 in the month of Nov-2022: 

SELECT 
	*
FROM retails_sales_data
WHERE category = 'Clothing'
	AND 
	quantiy >= 4
	AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'

--Q3. Write a SQL query to calculate the total sales (total_sale) for each category.:
SELECT category, SUM(total_sale) as total_sales
FROM retails_sales_data
GROUP BY category

--to add the total orders
SELECT category, SUM(total_sale) as total_sales, count(*) as total_orders
FROM retails_sales_data

--Q4.Write a SQL query to find the average age of customers 
--who purchased items from the 'Beauty' category.:
--using the round functions to make it 2 dec. places

SELECT ROUND(AVG(age), 2) as Avg_age
FROM retails_sales_data
WHERE category = 'Beauty'


--Q5.Write a SQL query to find all transactions 
--where the total_sale is greater than 1000.

SELECT *
FROM retails_sales_data
WHERE total_sale > 1000

--Q6. Write a SQL query to find the total number of transactions (transaction_id)
--made by each gender in each category.
--use the order by to organize your data
SELECT category, gender, COUNT (*) AS total_trans
FROM retails_sales_data
GROUP BY 1,2
ORDER BY 1



--Q7. Write a SQL query to calculate the average sale for each month. 
--Find out best selling month in each year:
--order by total sales desc to view from highest sales to least in each year


SELECT EXTRACT (YEAR FROM sale_date) AS year,
	EXTRACT (MONTH FROM sale_date)AS month,
	AVG(total_sale) avg_sale
FROM retails_sales_data
GROUP BY 1, 2
ORDER BY 1, 3 DESC 
--Using the window function RANK to rank the sales of each year
--(NOTE: you can use alias in windows funct.)
SELECT 	EXTRACT (YEAR FROM sale_date) AS year,
		EXTRACT (MONTH FROM sale_date)AS month,
		AVG(total_sale) avg_sale,
			RANK() OVER(PARTITION BY EXTRACT (YEAR FROM sale_date)
			ORDER BY AVG(total_sale) DESC ) rank
FROM retails_sales_data
GROUP BY 1, 2

--Now to get the highest sales for each year we will use SUBQUERY
SELECT 
		year,
		month,
		avg_sale
FROM 
(	
	SELECT 	EXTRACT (YEAR FROM sale_date) AS year,
		EXTRACT (MONTH FROM sale_date)AS month,
		AVG(total_sale) avg_sale,
			RANK() OVER(PARTITION BY EXTRACT (YEAR FROM sale_date)
			ORDER BY AVG(total_sale) DESC ) rank
	FROM retails_sales_data
	GROUP BY 1, 2
) AS t1
WHERE rank = 1

--Q8. Write a SQL query to find the top 5 customers 
--based on the highest total sales
SELECT customer_id, SUM(total_sale) AS total_sales
FROM retails_sales_data
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--Write a SQL query to find the number of unique customers
--who purchased items from each category
SELECT category, COUNT(DISTINCT customer_id) AS cnt_unique_customers
FROM retails_sales_data
GROUP BY 1

--Q10. Write a SQL query to create each shift and number of 
--orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
--Using the CASE STATEMENT and CTE

SELECT *,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'morning'
		WHEN  EXTRACT(HOUR FROM  sale_time) BETWEEN 12 AND 17 THEN 'afternoon'
		ELSE 'evening'
	END AS shift
FROM  retails_sales_data
--this will create a new column called shift(morning, afternoon and evening)

--to get the each shifts number of orders we will store it in a CTE.
WITH hourly_sale
AS 
(
SELECT *,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'morning'
		WHEN  EXTRACT(HOUR FROM  sale_time) BETWEEN 12 AND 17 THEN 'afternoon'
		ELSE 'evening'
	END AS shift
FROM  retails_sales_data
)
SELECT 
	shift,
	COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift