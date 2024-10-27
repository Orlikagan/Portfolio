

USE [Workorli]
GO
---Run it, to modify existing tables to new columns in the table, then to run it again (to prevent duplicate)

DROP TABLE [dbo].[OctNovProducts]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OctNovProducts](
	[date] [date] NULL,
	[product_id] [int] NULL,
	[category_id] [bigint] NULL,
	[category_code] [nvarchar](50) NULL,
	[brand] [nvarchar](50) NULL,
	[count_views] [int] NULL,
	[count_addcart] [int] NULL,
	[count_purchased] [int] NULL,
	[count_removecart] [int] NULL,
	[max_p] [float] NOT NULL,
	[min_p] [float] NOT NULL,
	[Sales] [float] NOT NULL,
	[P_purchased] [decimal](4,2)  NULL,
	[P_abandoned] [decimal](4,2)  NULL
	
) ON [PRIMARY]
GO

---Insert data to new created table by using select statement from other table
insert into [dbo].[OctNovProducts]
 select
	CAST (event_datetime AS date) as 'date'
	,[product_id]
	,[category_id]
	,[category_code]
	,[brand]
	,sum (CASE WHEN [event_type] ='view' THEN 1 ELSE 0 END) 
	,sum ( CASE WHEN [event_type] ='cart' THEN 1 ELSE 0 END) 
	,sum ( CASE WHEN [event_type] ='purchase' THEN 1 ELSE 0 END)
	,sum ( CASE WHEN [event_type] ='remove_from_cart' THEN 1 ELSE 0 END)
	,max(price) Max_price
	,min(price) Min_price
	,sum ( CASE WHEN [event_type] ='purchase' THEN price else 0 end) AS Sales
	---inserting null values that later will be updated into real values---
	,NULL
	,NULL
from [dbo].[2019OctNov]
group by CAST (event_datetime AS date)
	,[product_id]
	,[category_id]
	,[category_code]
	,[brand]
ORDER BY sales desc

	update [dbo].[OctNovProducts]
	 set [P_purchased] = case when count_views =0 then 0.0 else count_purchased *1.0 / count_views end
	,[P_abandoned] = 1.0 - case when count_views =0 then 0.0 else count_purchased*1.0 / count_views end
	from [dbo].[OctNovProducts]
	
