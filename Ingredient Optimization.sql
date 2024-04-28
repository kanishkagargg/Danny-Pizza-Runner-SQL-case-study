-- create temporary table runner_orders_tempo as 
-- SELECT *,
-- CASE WHEN cancellation IS NULL 
-- or cancellation = '' 
-- or cancellation = 'null'
-- THEN 1 ELSE 0 END AS isempty_cancellation,
-- case when distance like '%km' then trim('km' from distance)
-- else distance end as new_distance,
-- case when duration like '%minutes' then trim('minutes' from duration)
-- when duration like '%mins' then trim('mins' from duration)
-- when duration like '%minute' then trim('minute' from duration)
-- else duration end as new_duration
-- FROM runner_orders

-- create temporary table customer_orders_tempo as 
-- SELECT *,
-- CASE WHEN exclusions IS NULL 
-- or exclusions = '' 
-- or exclusions = 'null'
-- THEN 'no_exclusion' ELSE exclusions END AS isempty_exclusions, 
-- CASE WHEN extras IS NULL 
-- or extras = '' 
-- or extras = 'null'
-- THEN 'no_extra' ELSE extras END AS isempty_extra
-- FROM customer_orders

-- 1
with cte as (SELECT pizza_id, toppings_separated
FROM pizza_recipes
CROSS JOIN LATERAL unnest(string_to_array(toppings, ',')) as p(toppings_separated))

select pizza_id, string_agg(topping_name, ', ') as ingredients from cte
inner join pizza_toppings pt
on cast(cte.toppings_separated as int) = pt.topping_id
group by pizza_id;

-- 2
with cte as (SELECT *
FROM customer_orders_tempo
CROSS JOIN LATERAL unnest(string_to_array(isempty_extra, ',')) as p(isempty_extra_separated))
 
select topping_name, count(topping_name) from cte
left join pizza_toppings pt
on cast(cte.isempty_extra_separated as int) = pt.topping_id
where isempty_extra_separated != 'no_extra' 
group by topping_name;

-- 3 
with cte as (SELECT *
FROM customer_orders_tempo
CROSS JOIN LATERAL unnest(string_to_array(isempty_exclusions, ',')) as p(isempty_exclusions_separated))
 
select topping_name, count(topping_name) from cte
left join pizza_toppings pt
on cast(cte.isempty_exclusions_separated as float) = pt.topping_id
where isempty_exclusions_separated != 'no_exclusion' 
group by topping_name;

-- 4
-- create temporary table customer_orders_tempo_2 as 
-- SELECT *,
-- CASE WHEN exclusions IS NULL 
-- or exclusions = '' 
-- or exclusions = 'null'
-- THEN '0' ELSE exclusions END AS isempty_exclusions, 
-- CASE WHEN extras IS NULL 
-- or extras = '' 
-- or extras = 'null'
-- THEN '0' ELSE extras END AS isempty_extra
-- FROM customer_orders

with cte as (select *,
CASE WHEN exclusion_2 = ''
THEN '0' ELSE exclusion_2 END AS exclusion_2_new, 
CASE WHEN extra_2 = ''
THEN '0' ELSE extra_2 END AS extra_2_new
from 
(select co.order_id, co.customer_id, pn.pizza_id, pn.pizza_name,
row_number() over (partition by order_id order by order_id) as row_id, 
split_part(isempty_exclusions, ',', 1) as exclusion_1,
split_part(isempty_exclusions, ',', 2) as exclusion_2,
split_part(isempty_extra, ',', 1) as extra_1,
split_part(isempty_extra, ',', 2) as extra_2
from customer_orders_tempo_2 co
inner join pizza_names pn
on co.pizza_id = pn.pizza_id) 
			 t)

select order_id, concat(pizza_name , ' - Exclude ', string_agg(distinct(exclusions), ', ') , ' - Extra ', string_agg(distinct(extras), ', ')) as order_name
from 
(select *, pt.topping_name as exclusions, pt2.topping_name as extras from cte
left join pizza_toppings pt
on cast(exclusion_1 as int) = pt.topping_id
or
cast(exclusion_2_new as int) = pt.topping_id
left join pizza_toppings pt2
on cast(extra_1 as int) = pt2.topping_id
or
cast(extra_2_new as int) = pt2.topping_id) t
group by order_id, pizza_name, row_id
order by order_id, pizza_name, row_id

-- 6 

