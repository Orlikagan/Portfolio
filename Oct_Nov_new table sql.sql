--Creating one table for OCT_NOV together
USE [Workorli]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[2019OctNov](
    [event_datetime] [datetime] NULL,
	[event_type] [nvarchar](50) NOT NULL,
	[product_id] [int] NOT NULL,
	[category_id] [bigint] NOT NULL,
	[category_code] [nvarchar](50) NULL,
	[brand] [nvarchar](50) NULL,
	[price] [float] NOT NULL,
	[user_id] [int] NOT NULL,
	[user_session] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO

insert into [dbo].[2019OctNov] 
SELECT [event_datetime]
      ,[event_type]
      ,[product_id]
      ,[category_id]
      ,[category_code]
      ,[brand]
      ,[price]
      ,[user_id]
      ,[user_session]
  FROM [Workorli].[dbo].[2019Oct]


