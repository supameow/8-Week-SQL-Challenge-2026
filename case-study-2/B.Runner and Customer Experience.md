# 🍕 Case Study #2 - Pizza Runner
## B. Runner and Customer Experience
## Case study questions
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

## Solution
Task 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
```sql
    select
       floor((registration_date - date '2021-01-01')/7)+1 as week_number,
       count(*) as runner_count
    from runners
    group by floor((registration_date - date '2021-01-01')/7)+1
    order by floor((registration_date - date '2021-01-01')/7)+1;
```
| week_number | runner_count |
| ----------- | ------------ |
| 1           | 2            |
| 2           | 1            |
| 3           | 1            |

---

Task 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql    
    select 
       r.runner_id,
       avg(r.pickup_time::timestamp - c.order_time::timestamp) as avg_time
    from runner_orders_temp r
    left join customer_orders_temp c
    on r.order_id = c.order_id
    where r.pickup_time is not null
    group by r.runner_id
    order by r.runner_id;
```
| runner_id | avg_time        |
| --------- | --------------- |
| 1         | 00:15:40.666667 |
| 2         | 00:23:43.2      |
| 3         | 00:10:28        |

---

Task 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql    
    select
       c.order_id,
       count(c.pizza_id) as pizza_count,
       (r.pickup_time::timestamp - c.order_time::timestamp) as prep_time
    from runner_orders_temp r
    left join customer_orders_temp c
    on r.order_id = c.order_id
    where r.pickup_time is not null
    group by c.order_id, r.pickup_time, c.order_time
    order by pizza_count;
```
| order_id | pizza_count | prep_time |
| -------- | ----------- | --------- |
| 1        | 1           | 00:10:32  |
| 5        | 1           | 00:10:28  |
| 7        | 1           | 00:10:16  |
| 8        | 1           | 00:20:29  |
| 2        | 1           | 00:10:02  |
| 10       | 2           | 00:15:31  |
| 3        | 2           | 00:21:14  |
| 4        | 3           | 00:29:17  |

---

Task 4. What was the average distance travelled for each customer?
```sql    
    select 
       c.customer_id,
       round(avg(r.distance),2) as avg_distance
    from customer_orders_temp c
    left join runner_orders_temp r
    on c.order_id = r.order_id
    where r.distance is not null
    group by c.customer_id
    order by c.customer_id;
```
| customer_id | avg_distance |
| ----------- | ------------ |
| 101         | 20.00        |
| 102         | 16.73        |
| 103         | 23.40        |
| 104         | 10.00        |
| 105         | 25.00        |

---

Task 5. What was the difference between the longest and shortest delivery times for all orders?
```sql    
    select 
       max(duration) - min(duration) as duration_gap
    from runner_orders_temp
    where duration is not null;
```
| duration_gap |
| ------------ |
| 30           |

---

Task 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
```sql    
    select 
       r.order_id,
       count(c.pizza_id),
       r.runner_id,
       r.distance,
       r.duration,
       round((r.distance/(r.duration/60)),2) as speed
    from runner_orders_temp r
    left join customer_orders_temp c
    on r.order_id = c.order_id
    where r.duration is not null
    group by 
       r.order_id,
       r.runner_id,
       r.distance,
       r.duration
    order by r.runner_id;
```
| order_id | count | runner_id | distance | duration | speed |
| -------- | ----- | --------- | -------- | -------- | ----- |
| 1        | 1     | 1         | 20       | 32       | 37.50 |
| 3        | 2     | 1         | 13.4     | 20       | 40.20 |
| 2        | 1     | 1         | 20       | 27       | 44.44 |
| 10       | 2     | 1         | 10       | 10       | 60.00 |
| 8        | 1     | 2         | 23.4     | 15       | 93.60 |
| 7        | 1     | 2         | 25       | 25       | 60.00 |
| 4        | 3     | 2         | 23.4     | 40       | 35.10 |
| 5        | 1     | 3         | 10       | 15       | 40.00 |

---
Task 7. What is the successful delivery percentage for each runner?
```sql    
    with successful_remark as 
    (select
        runner_id,
        case
        when duration is not null then 1
        else 0
        end as remark
     from runner_orders_temp)
     select
        runner_id,
        round(avg(remark),2) as successful_rate
     from successful_remark
     group by runner_id
     order by runner_id;
```
| runner_id | successful_rate |
| --------- | --------------- |
| 1         | 1.00            |
| 2         | 0.75            |
| 3         | 0.50            |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
