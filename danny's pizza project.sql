-- Create database and use it
CREATE DATABASE IF NOT EXISTS pizza_runner;
USE pizza_runner;

-- Drop and create runners table
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INT,
  registration_date DATE
);

INSERT INTO runners (runner_id, registration_date) VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

-- Drop and create customer_orders table
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time DATETIME
);

INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, 'null', '1', '2020-01-08 21:00:29'),
  (6, 101, 2, 'null', 'null', '2020-01-08 21:03:13'),
  (7, 105, 2, 'null', '1', '2020-01-08 21:20:29'),
  (8, 102, 1, 'null', 'null', '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, 'null', 'null', '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');

-- Drop and create runner_orders table
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');

-- Drop and create pizza_names table
DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name TEXT
);

INSERT INTO pizza_names (pizza_id, pizza_name) VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

-- Drop and create pizza_recipes table
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INT,
  toppings TEXT
);

INSERT INTO pizza_recipes (pizza_id, toppings) VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

-- Drop and create pizza_toppings table
DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name TEXT
);

INSERT INTO pizza_toppings (topping_id, topping_name) VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  -- join tables
  
create table pizza_menu as  
SELECT 
  co.order_id,
  co.customer_id,
  co.pizza_id,
  pn.pizza_name,
  co.exclusions,
  co.extras,
  co.order_time,
  ro.runner_id,
  ro.pickup_time,
  ro.distance,
  ro.duration,
  ro.cancellation,
  
  r.registration_date,
  
  pr.toppings AS recipe_toppings,
  
  GROUP_CONCAT(pt.topping_name ORDER BY pt.topping_id) AS topping_names

FROM customer_orders co

LEFT JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
LEFT JOIN runner_orders ro ON co.order_id = ro.order_id
LEFT JOIN runners r ON ro.runner_id = r.runner_id
LEFT JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
LEFT JOIN pizza_toppings pt 
  ON FIND_IN_SET(pt.topping_id, pr.toppings) > 0

GROUP BY 
  co.order_id,
  co.customer_id,
  co.pizza_id,
  pn.pizza_name,
  co.exclusions,
  co.extras,
  co.order_time,
  ro.runner_id,
  ro.pickup_time,
  ro.distance,
  ro.duration,
  ro.cancellation,
  r.registration_date,
  pr.toppings;


-- data cleaning --
select *
from pizza_menu;

select *
from pizza_menu
where pickup_time is null
;
delete 
from pizza_menu
where pickup_time is null
;

select *
from pizza_menu
where extras = ''
;

update pizza_menu
   set exclusions = null
where exclusions = ''
;

select t1.exclusions, t2.exclusions
from pizza_menu t1
join pizza_menu t2
    on t1.pizza_name = t2.pizza_name
where t1.exclusions  is null
and t2.exclusions is not null
;

update pizza_menu t1
join pizza_menu t2
      on t1.pizza_name = t2.pizza_name
set t1.exclusions = t2.exclusions
where t1.exclusions is null
and t2.exclusions is not null
;

delete
from pizza_menu
where extras is null;

update pizza_menu
   set extras = null
where extras = ''
;

select t1.extras, t2.extras
from pizza_menu t1
join pizza_menu t2
    on t1.pizza_name = t2.pizza_name
where t1.extras  is null
and t2.extras is not null
;
update pizza_menu t1
join pizza_menu t2
      on t1.pizza_name = t2.pizza_name
set t1.extras = t2.extras
where t1.extras is null
and t2.extras is not null
;

update pizza_menu
set distance = concat(trim(distance), 'km')
where distance is not null and distance not like '%km';

update pizza_menu
set duration = trim(replace(replace(duration, 'minutes', ''), 'minute',''))
where duration is not null;

update pizza_menu
set duration = concat(trim(duration), 'mins')
where duration is not null and duration not like '%mins%';

select *
from pizza_menu;

-- A. Pizza Metrics--

-- How many pizzas were ordered?
select 
    count(distinct order_time) as no_of_orders
from customer_orders;

-- How many unique customer orders were made?
select 
     count(distinct pizza_id) as unique_order 
from pizza_menu;

-- How many successful orders were delivered by each runner?
select 
      count(pickup_time) as successful_orders
from pizza_menu;

-- How many of each type of pizza was delivered?
select pizza_name ,
      count(pickup_time) as number_of_orders
from pizza_menu
group by pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id, pizza_name,
       count(distinct order_id) as total_orders
from pizza_menu
group by customer_id, pizza_name;


-- What was the maximum number of pizzas delivered in a single order?
select max(pizza_order)
from
	(select count(order_id) as pizza_order
	from pizza_menu
	group by order_id) as pizza
;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id,
  sum(
     case
        when (coalesce(nullif(exclusions, ''),
        'null') not in ('','null') 
or coalesce(nullif(extras, ''),
        'null') not in ('','null'))
        then 1 else 0
        end
) as pizza_with_changes,
sum(
case 
         when(coalesce(nullif(exclusions,''),
         'null') in ('','null')
         or coalesce(nullif(extras,''),
         'null') in ('','null'))
         then 1 else 0
         end
         ) as pizza_without_changes
from pizza_menu
where cancellation is null or cancellation in ('','null')
group by customer_id
;


--  How many pizzas were delivered that had both exclusions and extras?

select
count(*) as pizza_with_both_changes
from pizza_menu
where cancellation is null or cancellation in ('','null')
and (coalesce(nullif(exclusions, ''),
        'null') not in ('','null') 
and coalesce(nullif(extras, ''),
        'null') not in ('','null'))
;

select *
from pizza_menu;

-- What was the total volume of pizzas ordered for each hour of the day?
select 
date_format(order_time, '%Y-%m-%d %H:00:00') as order_hour,
count(*) as total_pizzas
from pizza_menu
group by order_hour
order by order_hour
;

-- What was the volume of orders for each day of the week?
select 
date_format(order_time, '%Y-%m-%d ') as order_day,
count(*) as total_pizzas
from pizza_menu
group by order_day
order by order_day
;



-- B. Runner and Customer Experience-- 
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select *
from pizza_menu;

select 
yearweek(registration_date,1) AS registration_week, -- 1 = week starts on monday
count(distinct runner_id) as number_of_runners_registered
from pizza_menu
group by registration_week
order by registration_week
;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select *
from pizza_menu;

select runner_id,
round(avg(timestampdiff(minute, order_time,pickup_time)),2) as avg_pickup_time
from pizza_menu
where order_time is not null 
and pickup_time is not null
group by runner_id
order by runner_id; 


-- Is there any relationship between the number of pizzas and how long the order takes to prepare
create table pizza_prep_time as 
select 
order_id, 
order_time,
pickup_time,
timestampdiff(minute,order_time, pickup_time) as prep_time
from pizza_menu
;

select *
from pizza_prep_time;

-- What was the average distance travelled for each customer?
select customer_id, avg(distance)
from pizza_menu
group by customer_id
order by customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
select 
max(duration) - min(duration) as time_diff
from pizza_menu;
 
-- What was the average speed for each runner for each delivery and do you notice any trend for these values?

select distinct order_id, runner_id, 
(distance/duration) as runner_speed
from pizza_menu
;
-- I noticed runne 2 seems to be very fastwith 1 trailing behind.


-- What is the successful delivery percentage for each runner?

select runner_id,
count(*) * 100.0 / (select count(*) from pizza_menu) as percent_success_delivery
from pizza_menu
group by runner_id;


-- C. Ingredient Optimisation--
-- What are the standard ingredients for each pizza?
select *
from pizza_menu;

select distinct pizza_id,pizza_name,topping_names,
count(*) as standard_ingredient
from pizza_menu
group by pizza_id, pizza_name, topping_names
order by pizza_id, standard_ingredient desc
limit 1 -- return only top ingredient for each pizza
;

-- What was the most commonly added extra?

select  distinct extras,
count( order_time) as no_of_times_ordered
from pizza_menu
group by extras;

-- What was the most common exclusion?
select  distinct exclusions,
count( order_time) as no_of_times_ordered
from pizza_menu
group by exclusions;

-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
select order_id
from pizza_menu
where pizza_id = 1
group by order_id;


-- Meat Lovers - Exclude Beef
select order_id
from pizza_menu
where pizza_id = 1 and exclusions = 3 or exclusions like '%3%'
group by order_id;

-- Meat Lovers - Extra Bacon
select order_id
from pizza_menu
where pizza_id = 1  and extras = 1 or extras like '%1%'
group by order_id;

-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
with exc_ext_counter as (
select 
order_id,
     case
        when  exclusions in (1,4) or exclusions like '%1%' or exclusions like '%4%'
         then 1
         when extras in (6,9) or extras like '%6%' or extras like '%9%'
         then 1
	end
from customer_orders
where pizza_id = 1
)
select order_id
from  exc_ext_counter
where  exc_ext_count = 1
group by order_id;


-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients


SELECT 
  co.order_id,
  CONCAT(
    pn.pizza_name, ': ',
    GROUP_CONCAT(
      CASE 
        WHEN base.topping_id IS NOT NULL AND extra.topping_id IS NOT NULL THEN CONCAT('2x', pt.topping_name)
        WHEN base.topping_id IS NULL AND extra.topping_id IS NOT NULL THEN pt.topping_name
        WHEN base.topping_id IS NOT NULL AND extra.topping_id IS NULL THEN pt.topping_name
        ELSE NULL
      END
      ORDER BY pt.topping_name
      SEPARATOR ', '
    )
  ) AS order_ingredients
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id

-- Split pizza recipe into base toppings
LEFT JOIN (
  SELECT pr.pizza_id, pt.topping_id
  FROM pizza_recipes pr
  JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
) base ON co.pizza_id = base.pizza_id

-- Join all possible toppings (needed for name)
JOIN pizza_toppings pt ON pt.topping_id = base.topping_id 
    OR FIND_IN_SET(pt.topping_id, co.extras)

-- Mark which toppings are extras
LEFT JOIN (
  SELECT co.order_id, pt.topping_id
  FROM customer_orders co
  JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.extras)
  WHERE co.extras IS NOT NULL AND co.extras NOT IN ('null', '')
) extra ON extra.order_id = co.order_id AND extra.topping_id = pt.topping_id

-- Exclude removed toppings
WHERE NOT FIND_IN_SET(pt.topping_id, co.exclusions) 
   OR co.exclusions IS NULL 
   OR co.exclusions = '' 
   OR co.exclusions = 'null'

GROUP BY co.order_id, pn.pizza_name
ORDER BY co.order_id;


-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
SELECT 
  pt.topping_name,
  COUNT(*) AS total_quantity
FROM (
  -- Base toppings from recipes
  SELECT 
    co.order_id,
    pt.topping_id
  FROM customer_orders co
  JOIN runner_orders ro ON co.order_id = ro.order_id
  JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
  JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
  WHERE ro.cancellation IS NULL OR ro.cancellation NOT IN ('null', '', 'Restaurant Cancellation', 'Customer Cancellation')
    AND (co.exclusions IS NULL OR NOT FIND_IN_SET(pt.topping_id, co.exclusions))
    
  UNION ALL
  
  -- Extra toppings from orders
  SELECT 
    co.order_id,
    pt.topping_id
  FROM customer_orders co
  JOIN runner_orders ro ON co.order_id = ro.order_id
  JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.extras)
  WHERE ro.cancellation IS NULL OR ro.cancellation NOT IN ('null', '', 'Restaurant Cancellation', 'Customer Cancellation')
    AND co.extras IS NOT NULL AND co.extras NOT IN ('null', '')
) AS used_toppings
JOIN pizza_toppings pt ON used_toppings.topping_id = pt.topping_id
GROUP BY pt.topping_name
ORDER BY total_quantity DESC;


-- D. Pricing and Ratings--
select *
from pizza_menu;

-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
select 
sum(
   case 
     when pizza_name = 'meatlovers' then 12
     when pizza_name = 'vegetarian' then 10
     else 0
     end ) as total_income 
from pizza_menu;

-- What if there was an additional $1 charge for any pizza extras?
select 
sum(
   case 
     when pizza_name = 'meatlovers' then 12
     when pizza_name = 'vegetarian' then 10
     else 0
     end ) as total_income 
from pizza_menu;

-- What if there was an additional $1 charge for any pizza extras?
select 
sum(
   case 
     when pizza_name = 'meatlovers' then 12
     when pizza_name = 'vegetarian' then 10
     else 0
     end ) as total_income 
from pizza_menu;

-- What if there was an additional $1 charge for any pizza extras?
with cte as (select(
   case 
     when pizza_name = 'meatlovers' then 12
     when pizza_name = 'vegetarian' then 10
     else 0
     end ) as total_income,
     exclusions,
     extras
     from pizza_menu
     where cancellation is null)
     select 
     sum(case when extras is null then total_income
     when length(extras) = 1 then total_income + 1
     else total_income +2
     end) as new_total
     from cte;
     
     
-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5
-- table is in a new schema

-- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
alter table dannys_pizza.pizza_menu 
add column customer_rating  int;

update dannys_pizza.pizza_menu  as dca
join ratings.pizza_customer_rating as cas
on dca.order_id = cas.order_id
set dca.customer_rating = cas.customer_rating;

alter table dannys_pizza.pizza_menu 
add column avg_speed_kph decimal(5,2);

update dannys_pizza.pizza_menu  
set avg_speed_kph = (
cast(replace(distance, 'km', '') as decimal(5,2))/
 (cast(replace(duration, 'mins', '') as decimal(5,2))/ 60)
)
where distance is not null and duration is not null
;


alter table dannys_pizza.pizza_menu 
add column time_diff time;

update dannys_pizza.pizza_menu  
set time_diff = timestampdiff( minute,order_time,pickup_time)
;

alter table dannys_pizza.pizza_menu 
add column total_delivered_pizza int;

update dannys_pizza.pizza_menu  
set total_delivered_pizza = (select count(*) 
from customer_orders
where cancellation is null or cancellation in ('null','')
)
;

select *
from pizza_menu;

create table successful_deliveries  as
select customer_id,
order_id,
runner_id,
customer_rating,
order_time,
pickup_time,
avg_speed_kph,
time_diff,
duration,
total_delivered_pizza
from pizza_menu;

select *
from successful_deliveries;


-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
select 
sum(
   case 
     when pizza_name = 'meatlovers' then 12 - 0.30
     when pizza_name = 'vegetarian' then 10 - 0.30
     else 0
     end ) as total_income 
from pizza_menu;

-- Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
insert into pizza_menu (pizza_id,pizza_name, recipe_toppings)
values (3,'supreme', '1,2,3,4,5,6,7,8,9,10,11,12');


select *
from pizza_menu;
