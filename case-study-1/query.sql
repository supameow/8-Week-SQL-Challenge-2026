-- Task 1: What is the total amount each customer spent at the restaurant?

select
  s.customer_id,
  sum (m.price)
from sales s
left join menu m
on s.product_id = m.product_id
group by s.customer_id
order by customer_id;

-- Task 2: How many days has each customer visited the restaurant?

select 
   customer_id,
   count(distinct order_date)
from sales
group by customer_id
order by customer_id;

-- Task 3: What was the first item from the menu purchased by each customer?

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
 
 -- Task 4 What is the most purchased item on the menu and how many times was it purchased by all customers?
 
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

-- Task 5: Which item was the most popular for each customer?

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
 
 -- Task 6: Which item was purchased first by the customer after they became a member?
 
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
   
   -- Task 7: Which item was purchased just before the customer became a member?

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
   
-- Task 8: What is the total items and amount spent for each member before they became a member?

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
   
 -- Task 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
 
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

-- Task 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January

select 
s.customer_id,
sum(
  case
  when (s.order_date between me.join_date and (me.join_date+6)) or m.product_name = 'sushi' 
  then m.price*20
  else m.price*10
  end) as total_point
from sales s
left join menu m
on s.product_id=m.product_id
left join members me
on s.customer_id = me.customer_id
where 
s.order_date<= '2021-01-31' 
and s.order_date>= me.join_date
and s.customer_id IN ('A', 'B')
group by s.customer_id
order by s.customer_id;;
