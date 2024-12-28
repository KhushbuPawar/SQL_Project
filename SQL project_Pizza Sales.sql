-- 1} Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- 2} Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(od.quantity * p.price) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- 3} Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price desc
LIMIT 1;

-- 4} Identify the most common pizza size ordered.
SELECT 
    size, COUNT(order_id) AS ordercount
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY ordercount DESC
LIMIT 1;

-- 5} List the top 5 most ordered pizza types along with their quantities. 
SELECT 
    pt.name, sum(quantity) as quantity
    FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name 
ORDER BY quantity DESC
LIMIT 5;

-- 6} Find the total quantity of each pizza category ordered.
SELECT 
    category, SUM(quantity) as quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY category
ORDER BY quantity desc;

-- 7} Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS Order_Count
FROM
    orders
GROUP BY HOUR(order_time);

-- 8} Find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- 9} Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_quantity
FROM
    (SELECT 
        order_date, SUM(quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY order_date) AS order_quantity;

-- 10} Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    name, ROUND(SUM(quantity * price), 0) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;

-- 11} Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    category,
    ROUND(SUM(quantity * price) / (SELECT 
                    SUM(quantity * price)
                FROM
                    pizzas p
                        JOIN
                    order_details od ON od.pizza_id = p.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY category
ORDER BY revenue DESC;

-- 12} Analyze the cumulative revenue generated over time.
select 
order_date,sum(revenue) over (order by order_date) as cum_revenue 
from 
(select 
order_date,
sum(quantity*price) as revenue 	
FROM order_details od 
join pizzas p on od.pizza_id = p.pizza_id 
JOIN orders o ON o.order_id=od.order_id
group by order_date) as sales;


-- 13} Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from (SELECT 
    category,name,revenue,
    rank () over (partition by category order by revenue desc) as rn 
from 
(SELECT 
    category,name,ROUND(SUM(quantity * price), 0) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY category,name) as a) as b
where rn<=3;
