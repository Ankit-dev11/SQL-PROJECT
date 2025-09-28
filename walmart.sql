create database walmart;
# Create database


# Use database
USE walmart;

# Create table
CREATE TABLE IF NOT EXISTS sales_data(
	invoice_id VARCHAR(30) PRIMARY KEY,
    branch VARCHAR(10) NOT NULL,
    city VARCHAR(30) NOT NULL,
      customer_type  VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price FLOAT NOT NULL,
    quantity INT NOT NULL,
    tax_percentage FLOAT NOT NULL,
    total_sales FLOAT NOT NULL,
    purchase_date DATE NOT NULL,
    purchase_time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cost_of_goods_sold FLOAT NOT NULL,
    gross_margin_percentage FLOAT,
    gross_income FLOAT,
    rating FLOAT
);

select* from sales_data;
-- ------------------------- Data Processing Queries ---------------------------------
# Add a new column named 'time_of_day ' to give insight of sales in the Morning, Afternoon and Evening.

alter table sales_data add column time_of_day  varchar (13);

update sales_data  set time_of_day =
case
when purchase_time between '00:00:00' and '11:59:59' then 'morning'
when purchase_time between '12:00:00' and '17:59:59' then 'Afternoon'
else 'evening'
end;

alter table sales_data add column day_name varchar (14);
update sales_data set day_name = dayname(purchase_date);

alter table sales_data ADD column month_name varchar (20);
update  sales_data set month_name =monthname(purchase_date);

-- ----------------------- General Questions-----------------------------------------------------------
# 1. Show the all data of all the Walmart stores data.
select * from sales_data;

# 2. Count the number of records in the Walmart stores data.

select count(*) as 'total number of data ' from sales_data;

# 3 How many unique cities does the data have?

select distinct city from sales_data;

# 4. How many unique branch does the data have?

 select distinct branch from sales_data;

# 5. Show the city of each branch?

select  distinct branch ,city from sales_data;
select  branch ,city from sales_data  group by branch  , city;


-- ------------------- End of General Queries ------------------------------------------------------

-- ------------------------ Product Related Questions---------------------------------------------------

# 1. How many unique product lines does the data have?
 select distinct product_line from sales_data;
 select count(distinct product_line)  as 'total uniqe product ' from sales_data;
 # 2 How many unique payment methods does the data have?
 select  distinct count(payment_method) from sales_data;
 
 SELECT 
    payment_method,
    COUNT(payment_method) as 'Number of Payments'
FROM
    sales_data
group by payment_method
ORDER BY COUNT(payment_method) DESC;

select 
	*
from
	(
		SELECT 
			payment_method,
			COUNT(payment_method) AS 'Number of Payments',
            dense_rank() over(order by COUNT(payment_method) desc) as RankByPaymentMethod
		FROM
			sales_data
		GROUP BY payment_method
		ORDER BY COUNT(payment_method) DESC 
    ) as PaymentDataByRank
where RankByPaymentMethod = 1;

# 3 What are the most selling product line? 
SELECT 
			product_line,
			COUNT(product_line) AS 'Number of Product Line Count',
            dense_rank() over(order by COUNT(product_line) desc) as RankByProductLine
		FROM
			sales_data
		GROUP BY product_line
		ORDER BY COUNT(product_line) DESC;
        
        
        # 4. What is the total revenue by month?
        select 
	month_name as 'Month Name',
    round(sum(total_sales), 2) as 'Total Revenue'
from
	sales_data
group by month_name order by sum(total_sales) desc;

# 5. What is the total revenue by city?
select 
	city as 'City',
    round(sum(total_sales), 2) as 'Total Revenue'
from
	sales_data
group by city order by sum(total_sales) desc;

# 6. What is the average rating of each product line?
select 
	product_line as 'Product Line',
    round(avg(rating), 2) as 'Average Rating'
from
	sales_data
group by product_line order by avg(rating) desc;

# 7. Which top 2 months had the largest Cost Of Goods Sales?
SELECT 
    month_name AS 'Month Name',
    ROUND(SUM(cost_of_goods_sold), 2) AS 'Cost of Good Sold'
FROM
    sales_data
GROUP BY month_name
ORDER BY SUM(cost_of_goods_sold) DESC
LIMIT 3;

# 9. Which product line had the largest tax percent means VAT(Value Added Tax)?

SELECT 
    product_line AS 'Product Line',
    ROUND(SUM(tax_percentage), 2) AS 'Total VAT',
    dense_rank() over(order by SUM(tax_percentage) desc) as 'Rank By VAT'
FROM
    sales_data
GROUP BY product_line
ORDER BY SUM(tax_percentage) DESC;

select 
	*
from
(
	SELECT 
		product_line AS 'Product Line',
		ROUND(SUM(tax_percentage), 2) AS 'Total VAT',
		dense_rank() over(order by SUM(tax_percentage) desc) as RankByVAT
	FROM
		sales_data
	GROUP BY product_line
	ORDER BY SUM(tax_percentage) DESC
)as ProductLineVat
where RankByVAT = 1;

# 10. What are the most common product line by gender
select
product_line as 'Product Category',
gender,
count(product_line) as 'Liked By'
from 
sales_data 
group by gender, product_line order by count(product_line) desc;

# 11. Which branch average sales is greater than whole average sales?
select
branch,
round(avg(total_sales), 2) as 'Branch-wise Average Sales',
(select round(avg(total_sales), 2) from sales_data) as 'Whole Average Sales'
from
sales_data
group by branch order by avg(total_sales) desc;

select
branch,
round(avg(total_sales), 2) as 'Branch-wise Average Sales',
(select round(avg(total_sales), 2) from sales_data) as 'Whole Average Sales'
from
sales_data
group by branch 
having avg(total_sales) > (select round(avg(total_sales), 2) from sales_data)
order by avg(total_sales) desc;


# 12. Fetch each product line and add a column to those product line showing "Good", "Bad". 

select 
product_line as 'Product Line',
round(avg(total_sales), 2) as 'Average Sales By Product Line',
(select round(avg(total_sales), 2) from sales_data) as 'Whole Average Sales',
case
	when avg(total_sales) > (select avg(total_sales) from sales_data) then "Good"
    else "Bad"
end as 'Rating By Product Line'
from 
sales_data
group by product_line order by avg(total_sales) desc;

-- ----------------------------end  Product Related Questions-------------------------------------------


-- --------------------------- Sales Related Questions-----------------------------------------------
#1. Which of the customer types brought the most revenue?

select 
customer_type as 'Customer Type',
round(sum(total_sales), 2) as 'Total Revenue'
from sales_data
group by customer_type order by sum(total_sales) desc;

# 2. Which customer type pays the most in VAT?
select
*
from
(select 
customer_type as 'Customer Type',
round(sum(tax_percentage), 2) as 'Total VAT',
dense_rank() over(order by sum(tax_percentage) desc) as RankByVAT
from sales_data
group by customer_type) as CustomerRankByVAT
where RankByVAT = 1;

# 3. Which city paid the largest tax percent means VAT(Value Added Tax)?

select
*
from
(select 
city as 'City',
round(sum(tax_percentage), 2) as 'Total VAT',
dense_rank() over(order by sum(tax_percentage) desc) as RankByVAT
from sales_data
group by city) as CityRankByVAT
where RankByVAT = 1;

#4. What is the number of sales made in each time of the day per weekday

select
time_of_day as 'Time of Day',
count(time_of_day) as 'Numbers of Sales'
from sales_data
where is_weekday = true
group by time_of_day order by count(time_of_day) desc;

# 5. What is the number of sales made in each time of the day per weekend.

select
time_of_day as 'Time of Day',
count(time_of_day) as 'Numbers of Sales'
from sales_data
where is_weekday = false
group by time_of_day order by count(time_of_day) desc;

-- ---------------------------  end Sales Related Questions-----------------------------------------------

-- -----------------------Customer Related Questions-------------------------------------

#1. How many unique customer types does the data have?

select distinct customer_type from sales_data;

# 2. How many unique payment methods does the data have?

select distinct payment_method from sales_data;

# 3. What are the most common customer type?
select 
customer_type as 'Customer Type',
count(customer_type) as 'Number of Customers'
from
sales_data
group by customer_type order by count(customer_type) desc;

select
*
from
(
	select 
	customer_type as 'Customer Type',
	count(customer_type) as 'Number of Customers',
    dense_rank() over(order by count(customer_type) desc) as RankByNumberOfCustomers 
	from
	sales_data
	group by customer_type 
) as CustomersRankByCustomerType
where RankByNumberOfCustomers = 1;

# 4. What are top 2 customer types who brought the most products?

select
*
from
(
	select 
	customer_type as 'Customer Type',
	sum(quantity) as 'Number of Products Bought',
    dense_rank() over(order by sum(quantity) desc) as RankByNumberOfProductsBought 
	from
	sales_data
	group by customer_type 
) as CustomersRankByNumberOfProductsBought
where RankByNumberOfProductsBought = 1 or RankByNumberOfProductsBought = 2;

# 5. What is the gender distribution of the customers overall?

select 
gender as 'Customer Gender',
count(gender) as 'Number of Customers'
from sales_data
group by gender order by count(gender) desc;

# 6. What is the gender distribution per branch?

select 
branch as 'Branch',
gender as 'Customer Gender',
count(*) as 'Number of Customers'
from sales_data
group by gender, branch order by count(*) desc;

# 7. Which time of the day do customers give most ratings overall?

select 
time_of_day as 'Time of Day',
count(rating) as 'Number of Ratings'
from sales_data
group by time_of_day order by count(rating) desc;

SELECT 
    *
FROM
    (SELECT 
        time_of_day AS 'Time of Day',
		COUNT(rating) AS 'Number of Ratings',
        dense_rank() over(ORDER BY COUNT(rating) DESC) as RankByMostRatings
    FROM
        sales_data
    GROUP BY time_of_day) as RatingByTimeOfDay
where RankByMostRatings = 1;

# 8. Which time of the day do customers give most ratings per branch?

SELECT 
    *
FROM
    (SELECT 
		branch as 'Branch',
        time_of_day AS 'Time of Day',
		COUNT(rating) AS 'Number of Ratings',
        dense_rank() over(ORDER BY COUNT(rating) DESC) as RankByMostRatings
    FROM
        sales_data
    GROUP BY time_of_day, branch) as RatingByTimeOfDay
where RankByMostRatings = 1;

# 9. Which day of the week has the best avg ratings overall?

select 
day_name as 'Day Name',
round(avg(rating), 2) as 'Average Ratings'
from sales_data
group by day_name order by avg(rating) desc;

SELECT 
    *
FROM
    (SELECT 
        day_name AS 'Day Name',
		ROUND(AVG(rating), 2) AS 'Average Ratings',
        dense_rank() over(ORDER BY AVG(rating) DESC) as RankByDayName
    FROM
        sales_data
    GROUP BY day_name) as AverageRatingsByDayName
where RankByDayName = 1;


# 10. Which day of the week has the best average ratings per branch?

SELECT 
    *
FROM
    (SELECT 
		branch as 'Branch',
        day_name AS 'Day Name',
		ROUND(AVG(rating), 2) AS 'Average Ratings',
        dense_rank() over(ORDER BY AVG(rating) DESC) as RankByDayName
    FROM
        sales_data
    GROUP BY day_name, branch) as AverageRatingsByDayName
where RankByDayName = 1;






-- -------------------    End Customer Related Questions=--------------------===========





