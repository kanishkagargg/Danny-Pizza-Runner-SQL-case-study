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
-- THEN 1 ELSE 0 END AS isempty_exclusions, 
-- CASE WHEN extras IS NULL 
-- or extras = '' 
-- or extras = 'null'
-- THEN 1 ELSE 0 END AS isempty_extra
-- FROM customer_orders

--1
select DATE_PART('week', registration_date) as RegistrationWeek, count(runner_id) as RunnerRegistrated
from runners
group by RegistrationWeek;

-- 2
SELECT runner_id,avg(extract(epoch from
		(cast(ro.pickup_time as timestamptz)) - (cast(co.order_time as timestamptz))) /60) as difference
from customer_orders co
natural join runner_orders_tempo ro
where ro.pickup_time != 'null'
group by runner_id;

-- 3
SELECT order_id, count(order_id) ,sum(extract(epoch from
		(cast(ro.pickup_time as timestamptz)) - (cast(co.order_time as timestamptz))) /60) as difference
from customer_orders co
natural join runner_orders_tempo ro
where ro.pickup_time != 'null'
group by order_id
order by order_id;

--4 
select customer_id, avg(cast(new_distance as float)) as avg_distance
from customer_orders co
natural join runner_orders_tempo ro
where new_duration != 'null'
group by customer_id;

-- 5
select max(cast(new_duration as float) + diff) - min(cast(new_duration as float) + diff) as diff_time from (select *, extract(epoch from
		(cast(ro.pickup_time as timestamptz)) - (cast(co.order_time as timestamptz))) /60 as diff
from runner_orders_tempo ro
natural join customer_orders co
where new_duration != 'null') t ;

-- 6
select runner_id, avg(speed) from (select runner_id, order_id, sum(cast(new_distance as float))/(cast(new_duration as float)/60) as speed
from runner_orders_tempo ro
natural join customer_orders co
where new_distance != 'null'
group by runner_id, order_id, new_duration
order by runner_id, order_id) t
group by runner_id;

-- 7 
select runner_id, sum(isempty_cancellation)*100/count(order_id) as per_of_succesful_orders
from runner_orders_tempo
group by runner_id
order by runner_id
