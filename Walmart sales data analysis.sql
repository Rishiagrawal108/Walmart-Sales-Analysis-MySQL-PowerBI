Create database Walmart;

Drop table if exists sales_data;

Create table sales_data (
invoice_id varchar(30) not null,
branch varchar(5) not null,
city varchar (30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar (100) not null,
unit_price dec (10,2) not null,
quantity integer not null,
vat Float  not null,
total decimal(12,4) not null,
date datetime not null,
time time not null,
payments varchar (15) not null,
cogs dec (10,2) not null,
gross_margin_pct float,
gross_income dec (12,4),
rating float 
);

-- Import data to sales_data table --

select *
from sales_data;

-- Featuring Engineering --

select time,
(case
		when time between '00:00:00' and '12:00:00' then 'morning'
        when time between '12:01:00' and '16:00:00' then 'afternoon'
        else 'evening'
end) as time_of_day
from sales_data;

-- Adding a New Column = time_of_day --

alter table sales_data add column time_of_day varchar (20);

SET SQL_SAFE_UPDATES = 0; -- This step is taken to disable safe mode --

update sales_data
set time_of_day = (
case 
	when time  between '00:00:00' and '12:00:00' then 'morning'
	when time between '12:01:00' and '16:00:00' then 'afternoon'
	else 'evening'
end)
where time_of_day is null; 
SET SQL_SAFE_UPDATES = 1; -- This is step is taken to enable safe mode --

-- creating day_name column--

select date(date), dayname(date) as day_name
from sales_data;

SET SQL_SAFE_UPDATES = 0; -- This step is taken to disable safe mode --

alter table sales_data add column day_name varchar (20);

update sales_data
set day_name = dayname(date),
	date = date(date);
    
SET SQL_SAFE_UPDATES = 1; -- This is step is taken to enable safe mode --

-- Create a month column --

select monthname(date) a
from sales_data;

SET SQL_SAFE_UPDATES = 0; -- This step is taken to disable safe mode --

alter table sales_data add column months varchar (20);

update sales_data
set months = monthname(date); 

SET SQL_SAFE_UPDATES = 1; -- This is step is taken to enable safe mode --


select *
from sales_data;

-- 1.How many distinct cities are present in the dataset? --

select distinct city
from sales_data;

-- 2.In which city is each branch situated? --

select distinct branch,city
from sales_data ;

-- PRODUCT ANALYSE--

-- 1.How many distinct product lines are there in the dataset? --

select distinct product_line
from sales_data;

-- 2.What is the most common payment method? --

select payments, count(payments) as Common_payment_method
from sales_data
group by payments
order by payments desc
limit 1;

-- 3.What is the most selling product line? --

select product_line, count(product_line) as Most_selling_product
from sales_data
group by product_line
order by count(product_line) desc
limit 1;

-- 4.What is the total revenue by month?--

select months, sum(gross_income ) as Total_revenue
from sales_data
group by months
order by sum(gross_income) desc
limit 1;

-- 5.Which month recorded the highest Cost of Goods Sold (COGS)? --

select months, sum(cogs) as Total_cogs
from sales_data
group by months
order by Total_cogs desc
limit 1;

-- 6.Which product line generated the highest revenue?--

select product_line, sum(gross_income) as Revenue
from sales_data
group by product_line
order by Revenue desc
limit 1;

-- 7.Which city has produced the highest revenue?--

select city, sum(gross_income) as Revenue
from sales_data 
group by city
order by Revenue desc
limit 1; 

-- 8.Which product line incurred the highest VAT? --

select product_line, sum(vat) as Total_VAT
from sales_data
group by product_line 
order by Total_VAT
limit 1;

-- 9.Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,'based on whether its sales are above the average.--

alter table sales_data add column product_category varchar (20);

SET SQL_SAFE_UPDATES = 0; -- This step is taken to disable safe mode --

set @avg_total = (select avg(total) from sales_data);
update sales_data 
set product_category = (
case 
	when total >= @avg_total then 'GOOD'
    else 'BAD'
END );

-- 10.Which branch sold more products than average product sold? --

select branch, sum(quantity) as Total
from sales_data 
group by branch
having sum(quantity) >= avg(quantity)
order by branch desc 
limit 1;

-- 11.What is the most common product line by gender Male ? --

SELECT gender, product_line, COUNT(gender) total_count
FROM sales_data 
GROUP BY gender, product_line 
ORDER BY gender;

-- 12.What is the average rating of each product line?

select product_line, round(avg(rating),2) as Average
from sales_data 
group by product_line;

-- Sales Analysis --

-- 1.Number of sales made in each time of the day per weekday

select time_of_day, day_name, count(invoice_id) 
from sales_data
where day_name not in ('Saturday','Sunday')
group by time_of_day, day_name;

-- 2.Identify the customer type that generates the highest revenue.--

select customer_type, sum(gross_income) as Total
from sales_data
group by customer_type
order by Total desc
limit 1;

-- 3.Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT city, max(vat) as largest_VAT
FROM sales_data 
group by city
ORDER BY largest_VAT DESC
LIMIT 1;

-- 4.Which customer type pays the most in VAT?--

select customer_type , sum(vat) as VAT
from sales_data
group by customer_type
order by VAT desc;

-- Customer Analysis --

-- 1.How many unique customer types does the data have? --

select count(distinct customer_type) as Total_Types
from sales_data;

-- 2.How many unique payment methods does the data have? --

select count(distinct payments)
from sales_data;

-- 3.Which is the most common customer type?--

select customer_type, count(customer_type)
from sales_data
group by customer_type
order by count(customer_type) desc
limit 1;

-- 4.Which customer type buys the most? --

select customer_type, sum(total) as Most_buys
from sales_data
group by customer_type
order by Most_buys
limit 1;

-- 5.What is the gender of most of the customers? --

select gender, count(gender) as Most_customers
from sales_data
group by gender
order by Most_customers desc 
limit 1;

-- 6.What is the gender distribution per branch?--

select branch, gender, count(gender)
from sales_data
group by branch , gender
order by branch;

-- 7.Which time of the day do customers give most ratings? -- 

select time_of_day ,count(rating) as Total_rating
from sales_data
group by time_of_day
order by Total_rating desc
limit 1;

-- 8.Which time of the day do customers give most ratings per branch? --

select time_of_day ,count(rating) as Total_rating, branch
from sales_data
group by time_of_day, branch
order by Total_rating desc
limit 1;

-- 9.Which day of the week has the best avg ratings? --

select day_name, avg(rating) as Avg_rating
from sales_data
group by day_name
order by avg(rating) desc
limit 1;

-- 10.Which day of the week has the best average ratings per branch? --

select branch, day_name, avg(rating) as Avg_rating
from sales_data
group by branch, day_name
order by avg(rating) desc
limit 1;














