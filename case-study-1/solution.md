
# 🍜 Case Study #1 - Danny's Diner 

## Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
    
## Solution
### Task 1: What is the total amount each customer spent at the restaurant?

```sql
    select
      s.customer_id,
      sum (m.price)
    from sales s
    left join menu m
    on s.product_id = m.product_id
    group by s.customer_id
    order by s.customer_id;
```

| customer_id | sum |
| ----------- | --- |
| A           | 76  |
| B           | 74  |
| C           | 36  |

---


### Task 2: How many days has each customer visited the restaurant?
```sql  
    select 
       customer_id,
       count(distinct order_date)
    from sales
    group by customer_id
    order by customer_id;
```

| customer_id | count |
| ----------- | ----- |
| A           | 4     |
| B           | 6     |
| C           | 2     |

---


### Task 3: What was the first item from the menu purchased by each customer?
```sql
    select
       distinct s.customer_id,
       m.product_name
    from sales s
    left join menu m
    on s.product_id=m.product_id
    where s.order_date = 
    (select 
     min(s2.order_date) 
     from sales s2
     where s.customer_id = s2.customer_id);
```

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---


### Task 4 What is the most purchased item on the menu and how many times was it purchased by all customers?
```sql
     with product_count as
     (
     select
        m.product_name,
        count (s.product_id) as times,
        dense_rank() 
        over (
              order by count (s.product_id) desc)
        as product_rank
     from menu m
     left join sales s
     on m.product_id = s.product_id
     group by 
       m.product_name,
       m.product_id
     )
     select 
     product_name,
     times
     from product_count
     where product_rank=1;
```

| product_name | times |
| ------------ | ----- |
| ramen        | 8     |

---


### Task 5: Which item was the most popular for each customer?
```sql
    with item as
    (
    select 
       s.customer_id,
       m.product_name,
       count(s.product_id)as id_count
     from sales s
     left join menu m
     on s.product_id = m.product_id
     group by 
      s.customer_id,
      m.product_name
     )
     select
     i.customer_id,
     i.product_name,
     i.id_count
     from item i
     where id_count= 
       (select max(i1.id_count)
        from item i1
        where i1.customer_id = i.customer_id)   
     order by customer_id;
```

| customer_id | product_name | id_count |
| ----------- | ------------ | -------- |
| A           | ramen        | 3        |
| B           | sushi        | 2        |
| B           | curry        | 2        |
| B           | ramen        | 2        |
| C           | ramen        | 3        |

---


### Task 6: Which item was purchased first by the customer after they became a member?
```sql
     with after_join as 
     (
       select 
       s.customer_id,
       m1.product_name,
       s.order_date
       from sales s
       left join menu m1
       on s.product_id = m1.product_id
       left join members m2
       on s.customer_id = m2.customer_id
       where s.order_date > m2.join_date
       )
       select * from after_join a
       where a.order_date =
       (select min(a1.order_date)
        from after_join a1
        where a.customer_id=a1.customer_id)
       order by customer_id;
```

| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | ramen        | 2021-01-10 |
| B           | sushi        | 2021-01-11 |

---


### Task 7: Which item was purchased just before the customer became a member?
```sql
     with after_join as 
     (
       select 
       s.customer_id,
       m1.product_name,
       s.order_date
       from sales s
       left join menu m1
       on s.product_id = m1.product_id
       left join members m2
       on s.customer_id = m2.customer_id
       where s.order_date <m2.join_date
       )
       select * from after_join a
       where a.order_date =
       (select max(a1.order_date)
        from after_join a1
        where a.customer_id=a1.customer_id)
       order by customer_id;
```

|1 customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | sushi        | 2021-01-01 |
| A           | curry        | 2021-01-01 |
| B           | sushi        | 2021-01-04 |

---


### Task 8: What is the total items and amount spent for each member before they became a member?
```sql
    select 
       s.customer_id,
       count(s.product_id) as total_items,
       sum(m.price) as total_amount
       from sales s
       left join menu m
       on s.product_id = m.product_id
       left join members me
       on s.customer_id=me.customer_id
       where s.order_date < me.join_date
       group by s.customer_id
       order by s.customer_id;
```

| customer_id | total_items | total_amount |
| ----------- | ----------- | ------------ |
| A           | 2           | 25           |
| B           | 3           | 40           |

---


### Task 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```sql
    with total_spend as
    (
    select 
      s.customer_id,
      m.product_name,
      case
      when m.product_name='sushi' then m.price*20
      else m.price*10
      end as total_point
    from sales s
    left join menu m
    on s.product_id = m.product_id
    )
    select 
      customer_id,
      sum(total_point)
    from total_spend
    group by customer_id
    order by customer_id;
```

| customer_id | sum |
| ----------- | --- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

---


### Task 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January
```sql
    select 
    s.customer_id,
    sum(
      case
      when (s.order_date between me.join_date and (me.join_date+6))     or m.product_name = 'sushi' 
      then m.price*20
      else m.price*10
      end) as total_point
    from sales s
    left join menu m
    on s.product_id=m.product_id
    left join members me
    on s.customer_id = me.customer_id
    where 
    s.order_date<= '2021-01-31' and
    s.order_date>= me.join_date
    and s.customer_id IN ('A', 'B')
    group by s.customer_id
    order by s.customer_id;
```

| customer_id | total_point |
| ----------- | ----------- |
| A           | 1020        |
| B           | 320         |

---
### Bonus question
```sql
with order_list as
(select 
   s.customer_id,
   s.order_date,
   m.product_name,
   m.price,
 case
 when s.order_date >= me.join_date then 'Y'
 else 'N'
 end as member_status
 from sales s
 left join menu m
 on s.product_id = m.product_id
 left join members me
 on s.customer_id = me.customer_id)

select
   customer_id,
   order_date,
   product_name,
   price,
   case
   when member_status ='Y'
   then dense_rank() 
   over (partition by customer_id,member_status order by order_date)
   else NULL
   end as ranking
from order_list
order by customer_id;
```

| customer_id | order_date | product_name | price | ranking |
| ----------- | ---------- | ------------ | ----- | ------- |
| A           | 2021-01-01 | sushi        | 10    |  NULL   |
| A           | 2021-01-01 | curry        | 15    |  NULL   |
| A           | 2021-01-07 | curry        | 15    | 1       |
| A           | 2021-01-10 | ramen        | 12    | 2       |
| A           | 2021-01-11 | ramen        | 12    | 3       |
| A           | 2021-01-11 | ramen        | 12    | 3       |
| B           | 2021-01-01 | curry        | 15    |  NULL   |
| B           | 2021-01-02 | curry        | 15    |  NULL   |
| B           | 2021-01-04 | sushi        | 10    |  NULL   |
| B           | 2021-01-11 | sushi        | 10    | 1       |
| B           | 2021-01-16 | ramen        | 12    | 2       |
| B           | 2021-02-01 | ramen        | 12    | 3       |
| C           | 2021-01-01 | ramen        | 12    |  NULL   |
| C           | 2021-01-01 | ramen        | 12    |  NULL   |
| C           | 2021-01-07 | ramen        | 12    |  NULL   |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/138)
