SELECT * FROM coffee_shop.city;
-- q1 City wise customer count
select city_name,round(0.25*population,0) as coffee_cons_count from city;
-- q2 Total Revenue from Coffee Sales

select sum(total) from sales ;

-- q3
select p.product_id, p.product_name, (p.product_id) as qty_sold from products as p inner join sales as s on s.product_id = p.product_id group by p.product_id,p.product_name;

-- q4
select c.customer_name,ct.city_name, avg(s.total) as avg_sales from customers as c inner join city as ct on ct.city_id = c.city_id 
inner join sales as s on s.customer_id = c.customer_id group by c.customer_name, ct.city_name;

-- q5 done in q1

-- q6 Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

select ct.city_name,p.product_name,count(p.product_name) as qty_sold from city as ct inner join customers as c on ct.city_id = c.city_id
inner join sales as s on s.customer_id = c.customer_id
inner join products as p on p.product_id = s.product_id
group by ct.city_name,p.product_name; 

-- right query
WITH RankedProducts AS (
    SELECT 
        ct.city_name, 
        p.product_name, 
        COUNT(p.product_name) AS qty_sold,
        ROW_NUMBER() OVER (PARTITION BY ct.city_name ORDER BY COUNT(p.product_name) DESC) AS rank_p
    FROM 
        city AS ct
    INNER JOIN 
        customers AS c ON ct.city_id = c.city_id
    INNER JOIN 
        sales AS s ON s.customer_id = c.customer_id
    INNER JOIN 
        products AS p ON p.product_id = s.product_id
    GROUP BY 
        ct.city_name, 
        p.product_name
)
SELECT 
    city_name, 
    product_name, 
    qty_sold
FROM 
    RankedProducts
WHERE 
    rank_p <= 3
ORDER BY 
    city_name, 
    rank_p;

-- q7.Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select ct.city_name, count(DISTINCT s.customer_id) as no_of_cust from city as ct inner join customers as c on ct.city_id = c.city_id
inner join sales as s on s.customer_id = c.customer_id
group by ct.city_name order by no_of_cust desc;

-- q8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

select city_name, avg(ct.estimated_rent) as avg_rent, avg(s.total) as avg_sales from city as ct inner join customers as c on c.city_id = ct.city_id
inner join sales as s on s.customer_id = c.customer_id
group by city_name order by avg_rent desc;

-- q9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

SELECT 
    DATE_FORMAT(sale_date, '%Y-%m') AS month, 
    SUM(total) AS total_sales,
    LAG(SUM(total), 1) OVER (ORDER BY DATE_FORMAT(sale_date, '%Y-%m')) AS previous_month_sales,
    ((SUM(total) - LAG(SUM(total), 1) OVER (ORDER BY DATE_FORMAT(sale_date, '%Y-%m'))) / LAG(SUM(total), 1) OVER (ORDER BY DATE_FORMAT(sale_date, '%Y-%m'))) * 100 AS sales_growth_percentage
FROM 
    coffee_shop.sales
GROUP BY 
    DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY 
    month;

-- q10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

SELECT 
    ct.city_name,
    SUM(s.total) AS total_sales,
    SUM(ct.estimated_rent) AS total_rent,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    avg(ct.population*.25) AS estimated_coffee_consumers  -- assuming 80% of customers are coffee consumers
FROM 
    city AS ct
INNER JOIN 
    customers AS c ON ct.city_id = c.city_id
INNER JOIN 
    sales AS s ON s.customer_id = c.customer_id
GROUP BY 
    ct.city_name
ORDER BY 
    total_sales DESC
LIMIT 3;



