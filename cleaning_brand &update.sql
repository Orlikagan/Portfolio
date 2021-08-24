/******creating temporary table (products) to Identify products that have more than one category ID, category code or brand name (Null is counted as its own segment)  ******/
SELECT 
  [product_id] INTO #products
FROM 
  [Workorli].[dbo].[2019OctNov] 
WHERE 
  price > 0 
GROUP BY 
  product_id 
HAVING 
  COUNT(
    DISTINCT CASE WHEN [category_id] IS NULL THEN 'Other' ELSE category_id END
  ) > 1 
  or COUNT(
    DISTINCT CASE WHEN [category_code] IS NULL THEN 'Other' ELSE [category_code] END
  ) > 1 
  OR COUNT(
    DISTINCT CASE WHEN brand IS NULL THEN 'Other' ELSE brand END
  ) > 1


--View our products and their category/brand info
SELECT 
  d.product_id, 
  category_id, 
  category_code, 
  brand, 
  price, 
  count(*) as Occur 
FROM 
  dbo.[2019OctNov] d 
  JOIN #products p
  ON p.product_id = d.product_id 
WHERE 
  price > 0 
  --and event_type = 'purchase'
  --AND brand iS NOT NULL
GROUP BY 
  d.product_id, 
  category_id, 
  category_code, 
  brand, 
  price 
ORDER BY 
  d.product_id, 
  category_id, 
  category_code, 
  brand


--Check for product_id with two or more actual brand values and we will ignore updating them
 SELECT 
  d.product_id, 
  count(*) as Occur, 
  price, 
  month(event_datetime) date_M 
FROM 
  dbo.[2019OctNov] d 
  JOIN #products p
  ON p.product_id = d.product_id 
WHERE 
  price > 0 
  AND brand iS NOT NULL 
GROUP BY 
  d.product_id, 
  price, 
  month(event_datetime) 
HAVING 
  COUNT(DISTINCT Brand) > 1 
ORDER BY 
  d.product_id, 
  price

----Exploring the result of the specific product
SELECT 
  * 
FROM 
  dbo.[2019OctNov] 
WHERE 
  product_id = 7003278 
  and price > 0 
order by 
  1


--Exclude those that have more than one actual brand
SELECT 
  d.product_id INTO #excludeBrand
FROM 
  dbo.[2019OctNov] d 
  JOIN #products p
  ON p.product_id = d.product_id 
WHERE 
  price > 0 
  AND brand iS NOT NULL 
GROUP BY 
  d.product_id 
HAVING 
  COUNT(DISTINCT Brand) > 1 
ORDER BY 
  d.product_id

--Get the brand value for those products we want to update
SELECT 
  DISTINCT d.product_id, 
  d.brand INTO #updateVals
FROM 
  dbo.[2019OctNov] d 
  JOIN #products p
  ON p.product_id = d.product_id 
  LEFT JOIN #excludeBrand e
  ON e.product_id = d.product_id 
WHERE 
  brand IS NOT NULL 
  AND e.product_id IS NULL

--See the results
SELECT 
  * 
FROM 
  #updateVals


--Now we can update
UPDATE 
  d 
SET 
  brand = v.brand 
FROM 
  dbo.[2019OctNov] d 
  JOIN #updateVals v
  ON d.product_id = v.product_id 
WHERE 
  d.brand IS NULL


--Verification of right updating on a specific product id
SELECT 
  * 
FROM 
  dbo.[2019OctNov] 
WHERE 
  product_id = 28717595