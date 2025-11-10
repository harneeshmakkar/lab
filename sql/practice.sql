-- SQL Practice Questions:

-- EASY:

-- =============================================================================================================



-- 1. Assume you're given a table Twitter tweet data, write a query to obtain a histogram of tweets posted per user in 2022. Output the tweet count per user as the bucket and the number of Twitter users who fall into that bucket. 
-- In other words, group the users by the number of tweets they posted in 2022 and count the number of users in each group.

SELECT tweet_count_per_user AS tweet_bucket,
COUNT (user_id) AS users_num 
FROM 

(
SELECT user_id,COUNT(tweet_id) AS tweet_count_per_user
FROM tweets
WHERE tweet_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY user_id) 

AS total_tweets

GROUP BY tweet_count_per_user;







-- 2. Given a table of candidates and their skills, you're tasked with finding the candidates best suited for an open Data Science job. You want to find candidates who are proficient in Python, Tableau, and PostgreSQL.

-- Write a query to list the candidates who possess all of the required skills for the job. Sort the output by candidate ID in ascending order.

SELECT DISTINCT(candidate_id)
FROM candidates
WHERE skill IN ('Python' , 'Tableau' , 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(skill) = 3
ORDER BY candidate_id DESC;






-- 3. Assume you're given two tables containing data about Facebook Pages and their respective likes (as in "Like a Facebook Page").

-- Write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs.

SELECT page_id FROM pages
EXCEPT 
SELECT page_id FROM page_likes
ORDER BY page_id;

-- Note: Using the EXCEPT operator, we subtract the page IDs with likes from the initial set of all page IDs. The resulting query will give us the IDs of the Facebook pages that do not possess any likes.







-- 4. Tesla is investigating production bottlenecks and they need your help to extract the relevant data. Write a query to determine which parts have begun the assembly process but are not yet finished.

-- Assumptions:

-- parts_assembly table contains all parts currently in production, each at varying stages of the assembly process.
-- An unfinished part is one that lacks a finish_date.

SELECT part, assembly_step FROM parts_assembly
WHERE finish_date IS NULL;










-- 5. Assume you're given the table on user viewership categorised by device type where the three types are laptop, tablet, and phone.

-- Write a query that calculates the total viewership for laptops and mobile devices where mobile is defined as the sum of tablet and phone viewership. Output the total viewership for laptops as laptop_reviews and the total viewership for mobile devices as mobile_views.

SELECT 

COUNT(*) FILTER (WHERE device_type = 'laptop') AS laptop_views,
COUNT(*) FILTER (WHERE device_type IN ('phone', 'tablet')) AS mobile_views

FROM viewership;







-- 6. Given a table of Facebook posts, for each user who posted at least twice in 2021, write a query to find the number of days between each user’s first post of the year and last post of the year in the year 2021. Output the user and number of the days between each user's first and last post.

-- First, we can use the MIN() and MAX() aggregate functions on the post_date column to retrieve the earliest and latest post dates, and substract one from another accordingly.

-- To calculate the difference for each user, we GROUP the results by user_id, and then filter for posts made in the year 2021. To do so, we use the DATE_PART() function to extract the year from the post_date column.

-- In the final step, to exclude users who have posted only once during the year, we apply the HAVING clause with a COUNT() condition greater than 1.

SELECT user_id, MAX(post_date::DATE) - MIN(post_date::DATE) AS days_between
FROM posts
WHERE DATE_PART('year', post_date::DATE) = '2021'
GROUP BY user_id
HAVING COUNT(post_id) >1;









-- 7. Write a query to identify the top 2 Power Users who sent the highest number of messages on Microsoft Teams in August 2022. Display the IDs of these 2 users along with the total number of messages they sent. Output the results in descending order based on the count of the messages.

SELECT sender_id, COUNT(message_id) AS message_count
FROM messages
WHERE EXTRACT(MONTH FROM sent_date) = '8'
AND EXTRACT(YEAR FROM sent_date) = '2022'
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2;







-- 8. Assume you're given a table containing job postings from various companies on the LinkedIn platform. Write a query to retrieve the count of companies that have posted duplicate job listings.

-- Definition:

-- Duplicate job listings are defined as two job listings within the same company that share identical titles and descriptions.

WITH job_count_cte AS (

SELECT company_id, title, description, count(job_id) AS job_count
FROM job_listings
GROUP BY company_id, title,description

)

SELECT count(DISTINCT(company_id)) 
FROM job_count_cte
WHERE job_count >1;








-- 9. Assume you're given the tables containing completed trade orders and user details in a Robinhood trading system.

-- Write a query to retrieve the top three cities that have the highest number of completed trade orders listed in descending order. Output the city name and the corresponding number of completed trade orders.

SELECT users.city, COUNT(trades.order_id) AS total_orders  
FROM trades
INNER JOIN users
ON users.user_id = trades.user_id
WHERE trades.status = 'Completed'
GROUP BY users.city
ORDER BY total_orders DESC
LIMIT 3;








-- 10. Given the reviews table, write a query to retrieve the average star rating for each product, grouped by month. The output should display the month as a numerical value, product ID, and average star rating rounded to two decimal places. Sort the output first by month and then by product ID.

SELECT EXTRACT(MONTH FROM submit_date) AS mth,
product_id, 
ROUND(AVG(stars), 2) AS avg_stars
FROM reviews
GROUP BY mth, product_id
ORDER BY mth, product_id;








-- 11. Companies often perform salary analyses to ensure fair compensation practices. One useful analysis is to check if there are any employees earning more than their direct managers.

-- As a HR Analyst, you're asked to identify all employees who earn more than their direct managers. The result should include the employee's ID and name.

SELECT 

emp.employee_id AS employee_id,
emp.name AS employee_name

FROM employee AS mgr

INNER JOIN employee AS emp
ON emp.manager_id = mgr.employee_id

WHERE emp.salary > mgr.salary;









-- 12. Given a table containing information about bank deposits and withdrawals made using Paypal, write a query to retrieve the final account balance for each account, taking into account all the transactions recorded in the table with the assumption that there are no missing transactions.

SELECT account_id,
SUM(

CASE 
WHEN transaction_type = 'Deposit' THEN amount
ELSE -amount
END )

AS final_balance
FROM transactions
GROUP BY account_id;








-- 13. Assume you have an events table on Facebook app analytics. Write a query to calculate the click-through rate (CTR) for the app in 2022 and round the results to 2 decimal places.

-- Definition and note:

-- Percentage of click-through rate (CTR) = 100.0 * Number of clicks / Number of impressions
-- To avoid integer division, multiply the CTR by 100.0, not 100.

-- Step 1: Filter for analytics events from year 2022

-- Next, find the number of clicks and impressions using the CASE statement to assign a value of 1 for 'click' events and 0 for other events

-- Then, we add up the clicks and impressions by wrapping the CASE statements with a SUM() aggregate function and group the results by app_id

-- Finally, calculate the percentage of click-through rate (CTR) by dividing the number of clicks by the number of impressions and multiplying by 100.0, rounded to 2 decimal places using the ROUND() function.

SELECT 

app_id,
ROUND(

100.00 *
SUM(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END) /
SUM(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END), 2)

AS ctr 

FROM events

WHERE
timestamp >= '2022-01-01'
AND
timestamp <= '2022-12-31'

GROUP BY app_id;







-- 14. Assume you're given tables with information about TikTok user sign-ups and confirmations through email and text. New users on TikTok sign up using their email addresses, and upon sign-up, each user receives a text message confirmation to activate their account.

-- Write a query to display the user IDs of those who did not confirm their sign-up on the first day, but confirmed on the second day.

SELECT DISTINCT emails.user_id 
FROM emails
INNER JOIN texts
ON emails.email_id = texts.email_id
WHERE texts.action_date = emails.signup_date + INTERVAL '1 day'
AND texts.signup_action = 'Confirmed';







-- 15. IBM is analyzing how their employees are utilizing the Db2 database by tracking the SQL queries executed by their employees. The objective is to generate data to populate a histogram that shows the number of unique queries run by employees during the third quarter of 2023 (July to September). Additionally, it should count the number of employees who did not run any queries during this period.

-- Display the number of unique queries as histogram categories, along with the count of employees who executed that number of unique queries.

-- Step 1: Identify Queries in the Third Quarter of 2023
-- First, we need to filter the queries table to include only those queries executed between July 1, 2023, and September 30, 2023. We use these dates because they correspond to the third quarter of the year.

-- Using the COUNT() function, we also count the number of unique queries per employee within this time frame.

-- Step 2: Ensure All Employees are Counted
-- Next, we need to ensure that all employees are included, even if they did not run any queries during the third quarter. Using the same query in Step 1, we'll use a LEFT JOIN to achieve this, combining the employees table with the results from Step 1.

-- We'll also use COALESCE() function to set the query count to 0 for employees with no queries.

-- Step 3: Count Employees by Unique Query Count
-- Finally, in the main query, we group the results by the number of unique queries and count how many employees fall into each group. We also order the results by the number of unique queries to generate the histogram.

-- WITH employee_queries AS(

SELECT e.employee_id,
COALESCE(COUNT(DISTINCT q.query_id), 0) AS unique_queries
FROM employees AS e 
LEFT JOIN queries AS q
ON e.employee_id = q.employee_id
AND q.query_starttime >= '2023-07-01'
AND q.query_starttime < '2023-10-01'
GROUP BY e.employee_id
)

SELECT unique_queries, COUNT(employee_id) AS employee_count
FROM employee_queries
GROUP BY unique_queries
ORDER BY unique_queries;






-- 16. Your team at JPMorgan Chase is preparing to launch a new credit card, and to gain some insights, you're analyzing how many credit cards were issued each month.

-- Write a query that outputs the name of each credit card and the difference in the number of issued cards between the month with the highest issuance cards and the lowest issuance. Arrange the results based on the largest disparity.

SELECT card_name, MAX(issued_amount) - MIN(issued_amount) AS difference
FROM monthly_cards_issued
group BY card_name
ORDER BY difference DESC;






-- 17. You're trying to find the mean number of items per order on Alibaba, rounded to 1 decimal place using tables which includes information on the count of items in each order (item_count table) and the corresponding number of orders for each item count (order_occurrences table).

SELECT ROUND(SUM(item_count::DECIMAL*order_occurrences)
/ SUM(order_occurrences), 1) AS mean
FROM items_per_order;







-- 18. CVS Health is trying to better understand its pharmacy sales, and how well different products are selling. Each drug can only be produced by one manufacturer.

-- Write a query to find the top 3 most profitable drugs sold, and how much profit they made. Assume that there are no ties in the profits. Display the result from the highest to the lowest total profit.

SELECT drug, total_sales - cogs AS total_profit
FROM pharmacy_sales
ORDER BY total_profit DESC
LIMIT 3;







-- 19. CVS Health is analyzing its pharmacy sales data, and how well different products are selling in the market. Each drug is exclusively manufactured by a single manufacturer.

-- Write a query to identify the manufacturers associated with the drugs that resulted in losses for CVS Health and calculate the total amount of losses incurred.

-- Output the manufacturer's name, the number of drugs associated with losses, and the total losses in absolute value. Display the results sorted in descending order with the highest losses displayed at the top.

SELECT manufacturer,COUNT(drug) AS drug_count,
ABS(SUM(total_sales - cogs)) AS total_loss
FROM pharmacy_sales
WHERE total_sales - cogs <= 0
GROUP BY manufacturer
ORDER BY total_loss DESC;








-- 20. CVS Health wants to gain a clearer understanding of its pharmacy sales and the performance of various products.

-- Write a query to calculate the total drug sales for each manufacturer. Round the answer to the nearest million and report your results in descending order of total sales. In case of any duplicates, sort them alphabetically by the manufacturer name.

-- Since this data will be displayed on a dashboard viewed by business stakeholders, please format your results as follows: "$36 million".

SELECT manufacturer, 
CONCAT('$', ROUND(SUM(total_sales)/1000000), ' million') AS sale
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC, manufacturer;








-- 21. UnitedHealth Group (UHG) has a program called Advocate4Me, which allows policy holders (or, members) to call an advocate and receive support for their health care needs – whether that's claims and benefits support, drug coverage, pre- and post-authorisation, medical records, emergency assistance, or member portal services.

-- Write a query to find how many UHG policy holders made three, or more calls, assuming each call is identified by the case_id column.

WITH policy_count AS(

SELECT policy_holder_id, COUNT(case_id) AS call_count
FROM callers
GROUP BY policy_holder_id
HAVING COUNT(case_id) >= 3
)

SELECT COUNT(policy_holder_id)
FROM policy_count;









-- MEDIUM:


-- 1. Assume you are given the table below on Uber transactions made by users. Write a query to obtain the third transaction of every user. Output the user id, spend and transaction date.

WITH user_order AS(

SELECT *, 
ROW_NUMBER () OVER (
PARTITION BY user_id ORDER BY transaction_date) AS row_num
FROM transactions
)

SELECT user_id, spend, transaction_date
FROM user_order
WHERE row_num =3;







-- 2. Imagine you're an HR analyst at a tech company tasked with analyzing employee salaries. Your manager is keen on understanding the pay distribution and asks you to determine the second highest salary among all employees.

-- It's possible that multiple employees may share the same second highest salary. In case of duplicate, display the salary only once.

SELECT MAX(salary) AS second_highest_salary
FROM employee
WHERE salary < (

SELECT MAX(salary)
FROM employee);








-- 3. Assume you're given tables with information on Snapchat users, including their ages and time spent sending and opening snaps.

-- Write a query to obtain a breakdown of the time spent sending vs. opening snaps as a percentage of total time spent on these activities grouped by age group. Round the percentage to 2 decimal places in the output.

-- Notes:

-- Calculate the following percentages:
-- time spent sending / (Time spent sending + Time spent opening)
-- Time spent opening / (Time spent sending + Time spent opening)
-- To avoid integer division in percentages, multiply by 100.0 and not 100.

SELECT ag.age_bucket,

ROUND(100.0 * 
  SUM(act.time_spent) FILTER (WHERE act.activity_type = 'open') /
  SUM(act.time_spent), 2) AS open_perc,

ROUND(100.0 * 
  SUM(act.time_spent) FILTER (WHERE act.activity_type = 'send')/
  SUM(act.time_spent), 2) AS send_perc

FROM activities act  

INNER JOIN age_breakdown ag  
ON act.user_id = ag.user_id

WHERE act.activity_type IN ('send' , 'open')

GROUP BY ag.age_bucket;







-- 4. Given a table of tweet data over a specified time period, calculate the 3-day rolling average of tweets for each user. Output the user ID, tweet date, and rolling averages rounded to 2 decimal places.

SELECT user_id, tweet_date,

ROUND(
AVG(tweet_count) OVER (
PARTITION BY user_id
ORDER BY tweet_date
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_avg

FROM tweets;








-- 5. Assume you're given a table containing data on Amazon customers and their spending on products in different category, write a query to identify the top two highest-grossing products within each category in the year 2022. The output should include the category, product, and total spend.

SELECT category, product, total_spend
FROM(

SELECT category, product, SUM(spend) AS total_spend,
RANK() OVER(
PARTITION BY category
ORDER BY SUM(spend) DESC) AS ranking
FROM product_spend
WHERE EXTRACT(YEAR FROM transaction_date) = 2022
GROUP BY category, product
) AS ranked_spending

WHERE ranking<=2
ORDER BY category, ranking;






































