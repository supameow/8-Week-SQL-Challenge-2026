# 🍕 Case Study #2 - Pizza Runner
## A. Pizza Metrics
## Case Study Questions
1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?
## Solution
### Task 1. How many pizzas were ordered?
```sql
    select 
       count(*)
    from customer_orders;
```

| count |
| ----- |
| 14    |

---

### Task 2. How many unique customer orders were made?
```sql 
    select 
       count(distinct order_id)
    from customer_orders;
```

| count |
| ----- |
| 10    |

---

### Task 3. How many successful orders were delivered by each runner?
```sql
    select 
       runner_id,
       count(order_id) as successful_order
    from runner_orders
    where distance <> 'null'
    group by runner_id
    order by runner_id;
```

| runner_id | successful_order |
| --------- | ---------------- |
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |

---

### Task 4. How many of each type of pizza was delivered?
```
    select 
       p.pizza_name,
       count (c.pizza_id) as delivered_pizza
    from customer_orders c
    left join pizza_names p
    on p.pizza_id = c.pizza_id
    left join runner_orders r
    on c.order_id = r.order_id
    where r.distance <> 'null'
    group by p.pizza_name;
```

| pizza_name | delivered_pizza |
| ---------- | --------------- |
| Meatlovers | 9               |
| Vegetarian | 3               |

---

### Task 5. How many Vegetarian and Meatlovers were ordered by each customer?
```sql
    select 
       c.customer_id,
       p.pizza_name,
       count (c.pizza_id) as delivered_pizza
    from customer_orders c
    left join pizza_names p
    on p.pizza_id = c.pizza_id
    group by 
       c.customer_id,
       p.pizza_name
    order by c.customer_id;
```

| customer_id | pizza_name | delivered_pizza |
| ----------- | ---------- | --------------- |
| 101         | Meatlovers | 2               |
| 101         | Vegetarian | 1               |
| 102         | Meatlovers | 2               |
| 102         | Vegetarian | 1               |
| 103         | Meatlovers | 3               |
| 103         | Vegetarian | 1               |
| 104         | Meatlovers | 3               |
| 105         | Vegetarian | 1               |

---

### Task 6. What was the maximum number of pizzas delivered in a single order?
```sql
    with pizza_counts as
     (select
         c.order_id,
         count(c.pizza_id) as pizza_count
      from customer_orders c
      left join runner_orders r
      on c.order_id = r.order_id
      where r.distance <> 'null'
      group by c.order_id)
     select
        max(pizza_count)
     from pizza_counts;
```

| max |
| --- |
| 3   |

---

### Task 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
 ```sql   
    with pizza_remark as
    (select
       c.customer_id,
       c.pizza_id,
       case when exclusions=' ' and extras=' ' then 'no_change'
       else 'change'
       end as remark
     from customer_orders_temp c
     left join runner_orders_temp r
     on c.order_id = r.order_id
     where r.pickup_time <> ' ')
     select 
        customer_id,
        remark,
        count(remark)
     from pizza_remark
     group by customer_id, remark
     order by customer_id;
```

| customer_id | remark    | count |
| ----------- | --------- | ----- |
| 101         | no_change | 2     |
| 102         | no_change | 3     |
| 103         | change    | 3     |
| 104         | change    | 2     |
| 104         | no_change | 1     |
| 105         | change    | 1     |

---
### Task 8. How many pizzas were delivered that had both exclusions and extras?
```sql   
    select
       count(c.pizza_id) as pizza_excl_extra
    from customer_orders_temp c
    left join runner_orders_temp r
    on c.order_id = r.order_id
    where  
       r.cancellation=' ' and 
       c.exclusions<>' ' and
       c.extras<>' ';
```

| pizza_excl_extra |
| ---------------- |
| 1                |

---
### Task 9. What was the total volume of pizzas ordered for each hour of the day?
```sql   
    select 
       extract(hour from order_time) as hour_of_the_day,
       count(pizza_id) as total_pizza
    from customer_orders_temp
    group by extract(hour from order_time)
    order by extract(hour from order_time);
```

| hour_of_the_day | total_pizza |
| --------------- | ----------- |
| 11              | 1           |
| 13              | 3           |
| 18              | 3           |
| 19              | 1           |
| 21              | 3           |
| 23              | 3           |

---
### Task 10. What was the volume of orders for each day of the week?
```sql    
    select 
       to_char(order_time,'day') as day_of_week,
       count(order_id) as total_order
    from customer_orders_temp
    group by to_char(order_time,'day');
```

| day_of_week | total_order |
| ----------- | ----------- |
| wednesday   | 5           |
| thursday    | 3           |
| friday      | 1           |
| saturday    | 5           |

---
[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
