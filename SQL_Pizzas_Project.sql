create database pizza;
use pizza;

# we are importing the table which is in csv form into the sql. go to the selected databse in this case it is pizza. click on the arrow beside it you will
-- find the option called tables right click on that and you find an option called " Table Data import wizard"

# as there are many rows like 10k and more its better to create table and than import the table into the existing one like we have done below
-- we need to have same schema as of csv file that we are importing
create table orders (
order_id int not null primary key,
order_date date not null,
order_time time not null);
-- as we have created the table now import the required csv file using the above method.

# creating the order_details table
create table order_details (
order_details_id int not null primary key,
order_id int not null,
pizza_id varchar(30) not null,
quantity int not null);

# seeing all data tables
select * from pizza_types;
select * from pizzas;
select * from orders;
select * from order_details;

-- Calculate the total revenue from the pizza sales 
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- Identify the highest-priced pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common size of pizza ordered
SELECT 
    pizzas.size, SUM(order_details.quantity) AS tot_qnt
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY tot_qnt DESC limit 1;

-- List top 5 most ordered pizza types along with their quantities
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS tot_qnt
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY tot_qnt DESC limit 5;

# Join the necessary tables to find the total quantity 
-- of each pizza category ordered?
SELECT 
    pizza_types.category, SUM(order_details.quantity) AS tot_qnt
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY tot_qnt DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(orders.order_time) AS Hour,
    COUNT(order_details.order_id) AS sales
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY Hour
order by Hour asc;

-- Join relevant tables to find the category-wise distribution of pizzas. 
SELECT 
    category, COUNT(name) AS tot_cnt
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    round(AVG(sum),0) as avg_order
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS sum
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS a;
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue. 
SELECT 
    category,
    ROUND(revenue / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS per_of_revenue
FROM
    (SELECT 
        pizza_types.category,
            ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue
    FROM
        pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category
    ORDER BY revenue DESC) AS a;
    
-- Analyze the cumulative revenue generated over time.
select order_date, round(sum(revenue) over (order by order_date),2) as cum_revenue from 
(SELECT 
    orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name from(
select category,name,quantity, rank() over (partition by category order by quantity desc) as rn
from(
SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name
) as a
) as b 
where rn <= 3;
