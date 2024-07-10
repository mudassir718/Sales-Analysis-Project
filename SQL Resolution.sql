-- Retrieve the total number of orders place --

SELECT 
    COUNT(order_id) orders
FROM
    pizza.order_details;

-- Calculate the total revenue generated from pizza sales.--

SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS 'Total Sales'
FROM
    pizza.order_details od
        JOIN
    pizza.pizzas p ON p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.--

SELECT 
    pi.price, pi.size, pt.name, pt.category
FROM
    pizza.pizzas AS pi
        JOIN
    pizza_types AS pt ON pi.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.--

SELECT 
    COUNT(od.quantity) Total_Orders, pi.size
FROM
    pizzas AS pi
        JOIN
    order_details AS od ON od.pizza_id = pi.pizza_id
GROUP BY pi.size
ORDER BY Total_Orders DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.-
   
   SELECT 
    pt.name, COUNT(od.quantity) AS Quantity
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id
        JOIN
    Pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY Quantity DESC
LIMIT 5;
    
    
-- Find the total quantity of each pizza category ordered -- 

SELECT 
    pt.category, COUNT(od.quantity) total_count
FROM
    pizzas AS P
        JOIN
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY total_count DESC;

-- Determine the distribution of orders by hour of the day-- 

SELECT 
    HOUR(time) Timing, COUNT(order_id) Total_Order
FROM
    orders
GROUP BY Timing;

-- Find the category-wise distribution of pizzas -- 

SELECT 
    category, COUNT(name) Category_count
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.--

SELECT 
    ROUND(AVG(orders), 2) AS AVG_ORDER
FROM
    (SELECT 
        o.date, SUM(od.quantity) AS Orders
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY o.date) AS Quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue --
SELECT 
    pt.name,
    pt.category,
    ROUND(SUM(od.quantity * p.price),2) AS Revenue
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name , pt.category
ORDER BY pt.name , pt.category DESC LIMIT 3;
use pizza;

-- Calculate the percentage contribution of each pizza type to total revenue --

SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (SELECT 
                    SUM(od.quantity * p.price)
                FROM
                    order_details AS od
                        JOIN
                    pizzas AS p ON p.pizza_id = od.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category;


-- Analyze the cumulative revenue generated over time -- 

SELECT date,
round(sum(sales) over(order by date),2) as Cum_rev FROM
(SELECT o.date, sum(od.quantity*p.price) as Sales
FROM orders AS o
JOIN order_details AS od ON o.order_id=od.order_id
JOIN pizzas AS p ON p.pizza_id=od.pizza_id
GROUP BY o.date) AS revenue;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category-- 

SELECT name,category, revenue FROM
(SELECT name,category,revenue,
rank() over(partition by category order by revenue desc) AS sales FROM
(SELECT pt.name,pt.category,
round(sum(od.quantity*p.price),2) AS revenue
FROM order_details AS od JOIN pizzas AS p ON p.pizza_id = od.pizza_id
JOIN pizza_types AS pt ON p.pizza_type_id=pt.pizza_type_id
GROUP BY pt.name,pt.category) AS a) AS b
WHERE sales<=3;

   