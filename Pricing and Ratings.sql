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

-- 1
select sum(price) from (select *,
case when pizza_name = 'Meatlovers' then 12
else 10 end as price
from customer_orders_tempo_2 co
left join pizza_names pn
on co.pizza_id = pn.pizza_id) t
left join runner_orders_tempo ro
on t.order_id = ro.order_id
where isempty_cancellation = 1;

-- 2
select sum(price) + sum(xtra_price) from (select *,
case when pizza_name = 'Meatlovers' then 12
else 10 end as price,
case when isempty_extra = '0' then 0
else 1 end as xtra_price
from customer_orders_tempo_2 co
left join pizza_names pn
on co.pizza_id = pn.pizza_id) t
left join runner_orders_tempo ro
on t.order_id = ro.order_id
where isempty_cancellation = 1;

--3
select sum(price) - 0.3*(sum(cast(new_distance as float))) as profit from (select *,
case when pizza_name = 'Meatlovers' then 12
else 10 end as price
from customer_orders_tempo_2 co
left join pizza_names pn
on co.pizza_id = pn.pizza_id) t
left join runner_orders_tempo ro
on t.order_id = ro.order_id
where new_distance != 'null'















