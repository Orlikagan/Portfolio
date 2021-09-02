---Finding the amount of purchased percentage
select 
  [date], 
  [product_id], 
  [category_id], 
  [category_code], 
  [brand], 
  [count_views], 
  [count_addcart], 
  [count_purchased], 
  [count_removecart], 
  case when [count_views] = 0 then 0.0 else [count_purchased] * 100.0 / [count_views] end as P_purchased, 
  100 - case when [count_views] = 0 then 0.0 else [count_purchased] * 100.0 / [count_views] end as P_abanden 
from 
  [dbo].[OctNovProducts] 
group by 
  [date], 
  [product_id], 
  [category_id], 
  [category_code], 
  [brand], 
  [count_views], 
  [count_addcart], 
  [count_purchased], 
  [count_removecart] 
order by 
  count_purchased desc

--Reviewing data anomaly/data integrity
select 
  * 
from 
  [dbo].[OctNovProducts] 
where 
  count_views = 0

---There is more than one seassion per user
select 
  count (
    distinct(user_id)
  ) D_User_ID, 
  count(
    distinct(user_session)
  ) User_S 
from 
  [dbo].[2019OctNov] 
where 
  brand is null

---People who purchased but we dont know the brand only the category code/name of product
select 
  * 
  --count ( distinct(user_id))
  --count(user_session)
from 
  [dbo].[OctNovProducts] 
where 
  brand is null 
  and count_purchased <> '0 '

-----Which category code(name) we had the most percentage of people abending the cart out of those who viewed
select 
  sum (count_views - count_purchased) as Abandoned, 
  sum(count_views) as Vieweded, 
  CAST(sum (count_views - count_purchased)* 1.0 / sum(count_views)  as decimal(4, 2)) as p_abandoned , 
  [category_code], 
  date 
  --,brand
from 
  [dbo].[OctNovProducts] 
GROUP BY 
  category_code, 
  date 
  --,brand
HAVING 
  sum(count_views) > 300 
order by 
  p_abandoned desc, 
  vieweded


----Creating new calculated columns, and order by percentage of abending/purchased
select 
  distinct [category_id], 
  [product_id], 
  [category_code], 
  [brand], 
  [count_views], 
  [count_addcart], 
  [count_purchased], 
  [count_removecart], 
  CAST(
    case when [count_views] = 0 then 0.0 else [count_purchased] * 100.0 / [count_views] end AS decimal(3, 0)
  ) as P_purchased, 
  CAST(
    100 - case when [count_views] = 0 then 0.0 else [count_purchased] * 100.0 / [count_views] end AS decimal(3, 0)
  ) as P_abanden 
from 
  [dbo].[OctNovProducts] 
where 
  [count_views] > 10 
group by 
  [date], 
  [product_id], 
  [category_id], 
  [category_code], 
  [brand], 
  [count_views], 
  [count_addcart], 
  [count_purchased], 
  [count_removecart] 
order by 
  P_abanden desc, 
  count_purchased desc


---Verification of data NULLS between 2 columns: category_code, category_id
select 
  * 
from 
  [dbo].[OctNovProducts] 
where 
  category_code is not null 
  and category_id IN (
    select 
      distinct category_id 
    from 
      [dbo].[OctNovProducts] 
    where 
      category_code is null
  )

---Top 1 ranking bestselling by category Id
select 
  * 
from 
  (
    select 
      *, 
      RANK() OVER (
        PARTITION BY Category_id, 
        date 
        ORDER BY 
          count_purchased desc
      ) as bestseller 
    from 
      DBO.OctNovProducts 
	  -- order by category_code, count_purchased DESC) 
      ) as mtable 
where 
  bestseller = 1 
order by 
  --category_code
  date, 
  count_purchased DESC

---Ranking the top 5 best product within a category using rank function
select 
  * 
from 
  (
    select 
      *, 
      RANK() OVER (
        PARTITION BY Category_code, 
        date 
        ORDER BY 
          count_purchased desc
      ) as bestseller 
    from 
      DBO.OctNovProducts -- order by category_code, count_purchased DESC) 
      ) as mtable 
where 
  bestseller < 5 
order by 
  --category_code
  date, 
  count_purchased DESC

----Top bestselling products
select 
  [date], 
  [product_id], 
  [category_id], 
  --[category_code],
  [brand], 
  max (count_purchased) as bestseller 
from 
  dbo.OctNovProducts 
group by 
  [date], 
  [product_id], 
  [category_id], 
  [category_code], 
  [brand] 
order by 
  [category_code], 
  max (count_purchased) desc

----Top bestselling products in October
select 
  [date], 
  [product_id], 
  [category_id], 
  --[category_code],
  [brand], 
  max (count_purchased) as bestseller 
from 
  dbo.OctNovProducts 
where date = '2019-10-01'
group by 
  [date], 
  [product_id], 
  [category_id], 
  [category_code], 
  [brand] 
order by 
  [category_code], 
  max (count_purchased) desc

 ----Top bestselling products in November
  select 
  [date], 
  [product_id], 
  [category_id], 
  --[category_code],
  [brand], 
  max (count_purchased) as bestseller 
from 
  dbo.OctNovProducts 
where date = '2019-11-01'
group by 
  [date], 
  [product_id], 
  [category_id], 
  [category_code], 
  [brand] 
order by 
  [category_code], 
  max (count_purchased) desc
  
---Proof that some users had more than 1 sessions
select 
  count (
    distinct(user_id)
  ) D_User_ID, 
  count(
    distinct(user_session)
  ) User_S 
from 
  [dbo].[2019OctNov] 
where 
  brand is null


