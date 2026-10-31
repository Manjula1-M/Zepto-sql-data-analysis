create database ZeptoProject1
go
select * from dbo.Zepto_v2;

use ZeptoProject1
go
select * from dbo.Zepto_v2;


--Data Exploration

-- 1.Count total rows in Zepto table
select count(*) as TotalRows
from dbo.zepto_v2;


-- 2.Find the all unique product categories
select distinct Category
from dbo.zepto_v2;


-- 3.Count records in each product category
select
	Category,
	count(*) as TotalProducts
from dbo.zepto_v2
group by Category
order by TotalProducts desc;


-- 4.Count Products that are out of stock
select count(*) as OutOfStockCount
from dbo.zepto_v2
where outOfStock = 1;


--5.Count in-stock and out-of-stock records
select 
outOfStock,
count(*) as TotalRecords
from dbo.zepto_v2
group by outOfStock;


--6.Check null value in all columns 
select* from dbo.zepto_v2
where Category is null
   or name is null
   or mrp is null
   or discountedSellingPrice is null
   or discountPercent is null 
   or availableQuantity is null 
   or weightInGms is null
   or outOfStock is null 
   or quantity is null;

   
--7..Find the Product with discounts above 50%
select
name,
mrp,
discountPercent,
discountedSellingPrice 
from dbo.zepto_v2
where discountPercent > 50
order by discountPercent desc;


-- 8.find the products with the highest MRP
select top 10
	name,
	Category,
	mrp,
	discountedSellingPrice
from dbo.zepto_v2
order by mrp desc;


--9.Find the highest discount percentage available in each category
select 
	Category,
	max(discountPercent) as highest_discount
from dbo.zepto_v2
group by Category
order by highest_discount desc;


--Data cleaning

--10.Find the products with zero MRP
select * from dbo.zepto_v2
where mrp=0;

--11.Check Products with zero MRP and selling price
select
	name,
	mrp,
	discountedSellingPrice
from dbo.zepto_v2
where mrp=0 and discountedSellingPrice= 0;


--Inspect the complete record of the suspicious product
select * from dbo.zepto_v2
where name='Cherry Blossom Liquid Shoe Polish Neutral';

--12.Create a cleaned table by removing products with zero MRP
-- Create cleaned table only if it does not already exist

IF OBJECT_ID('dbo.zepto_cleaned', 'U') IS NOT NULL
    DROP TABLE dbo.zepto_cleaned;

SELECT *
INTO dbo.zepto_cleaned
FROM dbo.zepto_v2
WHERE mrp <> 0 OR mrp IS NULL;

---Compare average MRP and Selling price for each category
select
	Category,
	avg(cast(mrp as decimal(10,2))) as avg_mrp,
	avg(cast(discountedSellingPrice as decimal(10,2))) as avg_selling_price
 FROM dbo.zepto_cleaned
group by Category
order by avg_selling_price desc;

-- Check original table
SELECT COUNT(*) AS OriginalRows
FROM dbo.zepto_v2;

-- Check cleaned table
SELECT COUNT(*) AS CleanedRows
FROM dbo.zepto_cleaned;

-- Verify zero MRP records
SELECT *
FROM dbo.zepto_cleaned
WHERE mrp = 0;


--Business Insight Queries

--1.Find the top 10 best-value products based on discount percentage.
SELECT TOP 10
    name,
    Category,
    mrp,
    discountPercent,
    discountedSellingPrice
FROM dbo.zepto_cleaned
ORDER BY discountPercent DESC;


--2. High-MRP products that are out of stock
SELECT
    name,
    Category,
    mrp,
    outOfStock
FROM dbo.zepto_cleaned
WHERE mrp > 0
  AND outOfStock = 1
ORDER BY mrp DESC;


--3.Calculate estimated inventory value for each category
SELECT
    Category,
    SUM(
        CAST(discountedSellingPrice AS DECIMAL(10,2))
        * quantity
    ) AS estimated_inventory_value
FROM dbo.zepto_cleaned
WHERE outOfStock = 0
GROUP BY Category
ORDER BY estimated_inventory_value DESC;


--4.Products with MRP greater than ₹500 and discount below 10%
SELECT
    name,
    Category,
    mrp,
    discountPercent
 from dbo.zepto_cleaned
WHERE mrp > 500
  AND discountPercent < 10;


  --5.Top 5 categories with the highest average discount
  SELECT TOP 5
    Category,
    AVG(CAST(discountPercent AS DECIMAL(10,2)))
        AS average_discount
FROM dbo.zepto_cleaned
GROUP BY Category
ORDER BY average_discount DESC;


--6.Price per gram for products above 100g
SELECT
    name,
    Category,
    discountedSellingPrice,
    weightInGms,
    CAST(discountedSellingPrice AS DECIMAL(10,2))
        / NULLIF(weightInGms, 0) AS price_per_gram
FROM dbo.zepto_cleaned
WHERE weightInGms > 100
ORDER BY price_per_gram ASC;


--7. Group products into Low, Medium and Bulk categories
SELECT
    name,
    weightInGms,
    CASE
        WHEN weightInGms < 1000 THEN 'Low'
        WHEN weightInGms <= 5000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_category
FROM dbo.zepto_cleaned;


--8. Total inventory weight per category
SELECT
    Category,
    SUM(
        CAST(weightInGms AS BIGINT)
        * quantity
    ) AS total_inventory_weight
FROM dbo.zepto_cleaned
WHERE outOfStock = 0
GROUP BY Category
ORDER BY total_inventory_weight DESC;

