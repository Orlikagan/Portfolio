--Total oct rev by product IN OCT
select 
  sum (price) as total_rev, 
  month (event_datetime) as Month, 
  category_id, 
  product_id, 
  category_code, 
  brand 
from 
  [dbo].[2019OctNov] 
where 
  event_type = 'purchase' 
  and month(event_datetime)= 10 
group by 
  event_type, 
  category_id, 
  product_id, 
  category_code, 
  brand, 
  month (event_datetime) 
order by 
  total_rev desc


--Total nov rev by product in NOV
select 
  sum (price) as total_rev, 
  month (event_datetime) as Month, 
  category_id, 
  product_id, 
  category_code, 
  brand 
from 
  [dbo].[2019OctNov] 
where 
  event_type = 'purchase' 
  and month(event_datetime)= 11 
group by 
  event_type, 
  category_id, 
  product_id, 
  category_code, 
  brand, 
  month (event_datetime) 
order by 
  total_rev desc



--Total sum by month
select 
  sum (price) as total_rev, 
  month (event_datetime) as Month 
from 
  [dbo].[2019OctNov] 
where 
  event_type = 'purchase' 
group by 
  event_type, 
  month (event_datetime) 
order by 
  total_rev desc



--Calculation of increase over time(amount of change between 2 months)
select 
  total_revNov - total_revOCT as revchange, 
  (
    (total_revNov - total_revOCT)/ RevOct.total_revOCT
  )* 100 as '%_change' 
FROM 
  (
    select 
      sum (price) total_revOCT 
    from 
      dbo.[2019Oct] 
    where 
      event_type = 'purchase' 
    group by 
      event_type, 
      month (event_datetime)
  ) RevOct 
  JOIN (
    select 
      sum (price) total_revNov 
    from 
      dbo.[2019Nov] 
    where 
      event_type = 'purchase' 
    group by 
      event_type, 
      month (event_datetime)
  ) RevNov ON 1 = 1

 
--Top selling product by rev 
select 
  distinct(category_code), 
  sum (price) total_rev, 
  month (event_datetime) month, 
  product_id, 
  brand 
from 
  dbo.[2019OctNov] 
where 
  event_type = 'purchase' 
group by 
  event_type, 
  month (event_datetime), 
  product_id, 
  brand, 
  category_code 
order by 
  total_rev desc


---Top selling category and brand by month----
select 
  * 
FROM 
  (
    select 
      top 1 sum (price) total_revOCT, 
      category_code, 
      brand, 
      count (*) as P 
    from 
      dbo.[2019Oct] 
    where 
      event_type = 'purchase' 
    group by 
      event_type, 
      month (event_datetime), 
      category_code, 
      brand 
    order by 
      1 desc
  ) RevOct 
  JOIN (
    select 
      top 1 sum (price) total_revNov, 
      category_code, 
      brand, 
      count (*) as P 
    from 
      dbo.[2019Nov] 
    where 
      event_type = 'purchase' 
    group by 
      event_type, 
      month (event_datetime), 
      category_code, 
      brand 
    order by 
      1 desc
  ) RevNov ON 1 = 1

--The percentage of category out of total month revenue:  step 1
select 
  * 
FROM 
  (
    SELECT 
      sum (price) total_revOCT, 
      case when category_code is null then 'other' else category_code end as category_code, 
      brand 
    from 
      dbo.[2019Oct] 
    where 
      event_type = 'purchase' 
    group by 
      event_type, 
      month (event_datetime), 
      case when category_code is null then 'other' else category_code end, 
      brand
  ) RevOct FULL 
  OUTER JOIN (
    select 
      sum (price) total_revNov, 
      case when category_code is null then 'other' else category_code end as category_code, 
      brand 
    from 
      dbo.[2019Nov] 
    where 
      event_type = 'purchase' 
    group by 
      event_type, 
      month (event_datetime), 
      case when category_code is null then 'other' else category_code end, 
      brand
  ) RevNov ON RevNov.category_code = RevOct.category_code 
  and RevNov.brand = RevOct.brand 
order by 
  1 desc

----step 2
select 
  top 10 (total_revNov / NovT)* 100 as Category_Nov, 
  (total_revOCT / OctT)* 100 as Category_Oct, 
  isnull (
    RevNov.category_code, RevOct.category_code
  ) category_code 
FROM 
  (
    SELECT 
      sum (price) total_revOCT, 
      case when category_code is null then 'other' else category_code end as category_code, 
      10 as Month 
    from 
      dbo.[2019Oct] 
    where 
      event_type = 'purchase' 
    group by 
      event_type, 
      month (event_datetime), 
      case when category_code is null then 'other' else category_code end
  ) RevOct FULL 
  OUTER JOIN (
    select 
      sum (price) total_revNov, 
      case when category_code is null then 'other' else category_code end as category_code, 
      11 as Month 
    from 
      dbo.[2019Nov] 
    where 
      event_type = 'purchase' 
    group by 
      event_type, 
      month (event_datetime), 
      case when category_code is null then 'other' else category_code end
  ) RevNov ON RevNov.category_code = RevOct.category_code 
  JOIN (
    SELECT 
      sum (
        CASE WHEN month (event_datetime)= 10 then price end
      ) OctT, 
      sum (
        CASE WHEN month (event_datetime)= 11 then price end
      ) NovT 
    FROM 
      [dbo].[2019OctNov] 
    WHERE 
      event_type = 'purchase'
  ) as Trev ON 1 = 1 
order by 
  1 desc


--Top brand by category in each month ---
select 
  distinct (total_revNov / NovT)* 100 as '%Category_Nov', 
  (total_revOCT / OctT)* 100 as '%Category_Oct', 
  isnull (
    RevNov.category_code, RevOct.category_code
  ) category_code, 
  isnull (RevNov.brand, RevOct.brand) brand, 
  RANK () OVER (
    PaRTITION BY isnull(
      RevNov.category_code, RevOct.category_code
    ) 
    order by 
      total_revNov DESC
  ) RN --,sum (total_revNov) over ( partition by isnull(RevNov.category_code, RevOct.category_code ) 
FROM 
  (
    SELECT 
      sum (price) total_revOCT, 
      case when brand is null then 'other' else brand end as brand, 
      case when category_code is null then 'other' else category_code end as category_code, 
      10 as Month 
    from 
      dbo.[2019Oct] 
    where 
      event_type = 'purchase' 
    group by 
      event_type, 
      month (event_datetime), 
      case when category_code is null then 'other' else category_code end, 
      case when brand is null then 'other' else brand end
  ) RevOct FULL 
  OUTER JOIN (
    select 
      sum (price) total_revNov, 
      case when brand is null then 'other' else brand end as brand, 
      case when category_code is null then 'other' else category_code end as category_code, 
      11 as Month 
    from 
      dbo.[2019Nov] 
    where 
      event_type = 'purchase' 
    group by 
      event_type, 
      month (event_datetime), 
      case when category_code is null then 'other' else category_code end, 
      case when brand is null then 'other' else brand end
  ) RevNov ON RevNov.category_code = RevOct.category_code 
  AND RevNov.brand = RevOct.brand 
  JOIN (
    SELECT 
      sum (
        CASE WHEN month (event_datetime)= 10 then price end
      ) OctT, 
      sum (
        CASE WHEN month (event_datetime)= 11 then price end
      ) NovT 
    FROM 
      [dbo].[2019OctNov] 
    WHERE 
      event_type = 'purchase'
  ) as Trev ON 1 = 1 
order by 
  3, 
  5
