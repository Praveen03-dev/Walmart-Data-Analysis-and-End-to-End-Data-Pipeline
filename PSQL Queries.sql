SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

SELECT 
	payment_method,
	count(*)
FROM walmart
GROUP BY payment_method;


SELECT
	COUNT(DISTINCT branch)
FROM walmart;


SELECT MAX(quantity) FROM walmart;

SELECT MIN(quantity) FROM walmart;


-- Business Problem
-- Q.1. Find the different payment method and number of transaction, number of qty sold

SELECT 
	payment_method,
	count(*) AS transactions,
	SUM(quantity) as quantity
FROM walmart
GROUP BY payment_method;


--Q.2. Identify the highest-rated category in each branch, displaying the branch, category and AVG rating

SELECT *
FROM (
	SELECT
		branch,
		category as highest_rated_category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY branch, category
)
WHERE rank = 1

-- Q.3. Identify the busiest day for each branch on the number of transactions
SELECT *
FROM (
	SELECT 
		branch,
		TO_CHAR(TO_DATE(date,'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1,2
)
WHERE rank = 1;

--Q.4. Calculate the total quantity of items sold per payment method. List payment_method and total_quantity

SELECT 
	payment_method,
	SUM(quantity) as quantity
FROM walmart
GROUP BY payment_method;


-- Q.5. Determine the average, minimum, and maximum rating of products for each city.
-- List the city, average_rating, min_rating, and max_rating.

SELECT
	city,
	category,
	AVG(rating) as avg_rating,
	MIN(rating) as minn_rating,
	MAX(rating) as max_rating
FROM walmart
GROUP BY 1,2;

-- Q.6. Calculate the total profit for each category by considering total_profit as 
-- (unit_price * quantity * profit_margin). List category and total_profit, ordered from highest to lowest profit.

SELECT
	category,
	SUM(unit_price * quantity * profit_margin) as total_profit
FROM walmart
GROUP BY 1
ORDER BY total_profit DESC;


-- Q.7 Determine the most common payment method for each branch. Display branch and the preffered_payment_method.

WITH cte
AS
(SELECT
	branch,
	payment_method,
	count(*) as total_transaction,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY branch, payment_method)
SELECT *
FROM cte
WHERE rank = 1;

-- Q.8. Categorize sales into 3 groups MORNING, AFTERNOON, EVENING. Find out which of the shift and number of invoices.

SELECT
	branch,
	CASE 
		WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	count(*) as no_transactions
FROM walmart
GROUP BY 1,2
ORDER BY 1,3;

-- Q.9. Identify 5 branch with highest decrease ratio in revenue compare to last year (current year is 2023 and last year is 2022)
-- rdr = ((last_rev - cr_rev)/ls_rev)*100

WITH revenue_2022
AS
(
	SELECT
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2022
	GROUP BY 1
),
revenue_2023
AS
(
	SELECT
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2023
	GROUP BY 1
)
SELECT
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ROUND(((ls.revenue::numeric - cs.revenue::numeric) / ls.revenue::numeric) * 100, 2) as decrease_ratio_in_revenue
FROM revenue_2022 as ls
JOIN 
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;



