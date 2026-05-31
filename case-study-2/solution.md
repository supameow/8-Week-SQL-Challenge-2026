# Case Study #2 - Pizza Runner
## A. Pizza Metrics
Task 1. How many pizzas were ordered?
```sql
    select 
       count(*)
    from customer_orders;
```

| count |
| ----- |
| 14    |

---

Task 2. How many unique customer orders were made?
```sql 
    select 
       count(distinct order_id)
    from customer_orders;
```

| count |
| ----- |
| 10    |

---

Task 3. How many successful orders were delivered by each runner?
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

Task 4. How many of each type of pizza was delivered?
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

Task 5. How many Vegetarian and Meatlovers were ordered by each customer?
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
**Query #10**

Task 6. What was the maximum number of pizzas delivered in a single order?
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
```sql

| max |
| --- |
| 3   |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/7VcQKQwsS3CTkGRFG7vu98/65)
