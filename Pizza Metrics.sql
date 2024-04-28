--A) Pizza metrics
-- create temporary table customer_orders_tempo as 
-- SELECT *,
-- CASE WHEN exclusions IS NULL 
-- or exclusions = '' 
-- or exclusions = 'null'
-- THEN 1 ELSE 0 END AS isempty_exclusions, 
-- CASE WHEN extras IS NULL 
-- or extras = '' 
-- or extras = 'null'
-- THEN 1 ELSE 0 END AS isempty_extra
-- FROM customer_orders;

-- create temporary table runner_orders_tempo as 
-- SELECT *,
-- CASE WHEN cancellation IS NULL 
-- or cancellation = '' 
-- or cancellation = 'null'
-- THEN 1 ELSE 0 END AS isempty_cancellation 
-- FROM runner_orders;

--1
select count(order_id) as total_pizza_ordered from customer_orders;
--2
select  count(distinct(order_id)) as unique_cust_orders from customer_orders;

--3
select runner_id, count(order_id) from runner_orders_tempo
where isempty_cancellation = 1
group by runner_id;

--4
select pn.pizza_name, count(pn.pizza_name) from customer_orders cs
natural join pizza_names pn
group by pn.pizza_name;

--5
select cs.customer_id, pn.pizza_name, count(pn.pizza_name) as pizza_count from customer_orders cs
natural join pizza_names pn
group by cs.customer_id, pn.pizza_name
order by pn.pizza_name, pizza_count desc;

--6
select order_id, count(order_id) from customer_orders
group by order_id
order by count(order_id) desc 
limit 1;

--7
select customer_id, sum(Any_Changes) as Any_Changes, sum(No_Changes) as No_Changes from 
(select * ,case when isempty_exclusions = 0 or isempty_extra = 0
then 1 else 0 end as Any_Changes,
case when isempty_exclusions = 1 and isempty_extra = 1
then 1 else 0 end as No_Changes
from customer_orders_tempo
natural join runner_orders_tempo rot
where isempty_cancellation = 1) t
group by customer_id;

--8
select count(pizza_id) as pizzas_with_exlusions_and_extras from customer_orders_tempo
natural join runner_orders_tempo rot
where (isempty_exclusions = 0 and isempty_extra = 0) and isempty_cancellation = 1;

--9
select date_part('hour', order_time) as hourly_order, count(pizza_id) as count_of_pizzas 
from customer_orders_tempo
group by date_part('hour', order_time)
order by date_part('hour', order_time) asc;

--10
select extract(dow from order_time) as week_order, count(order_id) as count_of_orders
from customer_orders_tempo
group by extract(dow from order_time)
order by extract(dow from order_time) asc;
--(0-6; Sunday is 0)













