use walmart_db;
select count(distinct Branch) as count from walmart ;
select max(quantity) from walmart;
-- Business Problems
-- Q1. Find the different payment method and number of transactions and no of quantity sold
select 
	payment_method, 
    count(*) as no_of_transactions ,
    sum(quantity) as no_of_qty
from walmart 
group by payment_method 
order by no_of_transactions desc;
-- Q2. Which category received the highest average rating in each branch?
select * from (
select 
	Branch,
	category,
    avg(rating) as avg_rating,
    RANK() over(partition by Branch order by avg(rating) desc) as rnk
from walmart
group by Branch,category) as maximum
where rnk=1;
-- Q3. : What is the busiest day of the week for each branch based on transaction volume?
select * from (select 
	branch,
    Dayname(str_to_date(date,'%d/%m/%Y')) as day_name,
    count(*) as no_of_transactions,
    rank() over(partition by branch order by count(*) desc)as rnk
from walmart
group by branch, day_name
) as busiest_days where rnk=1;

-- Q4. : How many items were sold through each payment method?
select 
	payment_method, 
    sum(quantity) as no_of_qty
from walmart 
group by payment_method 
order by no_of_qty desc;

-- Q5.What are the average, minimum, and maximum ratings for each category in each city?
 
 select 
	city,
    category,
    avg(rating) as avg_rating,
    min(rating) as min_rating,
    max(rating) as max_rating
from walmart
group by city,category
order by city asc;

-- Q6.: What is the total profit for each category, ranked from highest to lowest?
select
	category,
    sum(total * profit_margin) as total_profit
from walmart
group by category
order by total_profit desc;

-- Q7. What is the most frequently used payment method in each branch?
select * from( select 
	branch,
    payment_method,
    count(*) as total_payments,
    RANK() over(partition by branch order by count(*) desc) as rnk
from walmart
group by branch,payment_method) as freq_used_method
where rnk=1;

-- Q8. How many transactions occur in each shift (Morning, Afternoon, Evening)across branches?
select 
	branch,
	case 
		when HOUR (str_to_date(time, '%H:%i:%s'))<12 then'Morning'
		when HOUR( str_to_date(time, '%H:%i:%s'))between 12 and 17 then'Afternoon'
		else 'evening'
	end as time_of_day,
    COUNT(*) AS total_transactions
from walmart
group by branch,time_of_day
order by branch, total_transactions desc;
-- Q9. : Which branches experienced the largest decrease in revenue compared to the previous year?
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
select * from walmart;

-- Q10. Are the highest-rated categories also the most profitable?

SELECT 
    category,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(SUM(total * profit_margin), 2) AS total_profit
FROM walmart
GROUP BY category
ORDER BY avg_rating DESC;

-- Q11. Do customers spend more on weekends than weekdays in each branch?
SELECT 
    branch,
    CASE 
        WHEN DAYOFWEEK(STR_TO_DATE(date, '%d/%m/%Y')) IN (1,7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    ROUND(SUM(total),2) AS total_revenue,
    ROUND(AVG(total),2) AS avg_transaction_value
FROM walmart
GROUP BY branch, day_type
ORDER BY branch, day_type;

-- Q12. Which branch has the most consistent daily sales (low volatility)?
WITH daily_sales AS (
    SELECT branch, DATE(STR_TO_DATE(date, '%d/%m/%Y')) AS sales_date, SUM(total) AS daily_revenue
    FROM walmart
    GROUP BY branch, sales_date
)
SELECT branch,
       ROUND(STDDEV(daily_revenue),2) AS revenue_volatility,
       ROUND(AVG(daily_revenue),2) AS avg_daily_revenue
FROM daily_sales
GROUP BY branch
ORDER BY revenue_volatility ASC;
 
 -- Q13. Are some categories more popular in certain months?
 SELECT 
    category,
    MONTH(STR_TO_DATE(date, '%d/%m/%Y')) AS month,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY category, month
ORDER BY category, month;

-- Q14. Which branch-category pairs contribute the most to overall revenue?
SELECT 
    branch,
    category,
    ROUND(SUM(total),2) AS total_revenue
FROM walmart
GROUP BY branch, category
ORDER BY total_revenue DESC
LIMIT 5;

-- Q15. Which branch achieves the highest profit per customer transaction?

SELECT 
    branch,
    ROUND(SUM(total * profit_margin),2) AS total_profit,
    COUNT(invoice_id) AS total_transactions,
    ROUND(SUM(total * profit_margin) / COUNT(invoice_id), 2) AS profit_per_transaction
FROM walmart
GROUP BY branch
ORDER BY profit_per_transaction DESC;