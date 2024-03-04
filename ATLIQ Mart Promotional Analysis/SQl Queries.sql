-- This file contains the sql queries of Atliq Super Mart (retail_events_db)

SELECT * FROM retail_events_db.fact_events; -- 1500 rows 8 columns
SELECT * FROM retail_events_db.dim_campaigns;  -- 2 campaigns each for six days
SELECT * FROM retail_events_db.dim_products; -- 15 products for both campaigns
SELECT * FROM retail_events_db.dim_stores;  -- 50 stores

-- #B1CE34 green

-- Adding column named promo_price 
ALTER TABLE fact_events
ADD COLUMN promo_price DECIMAL(10,2);

-- Update the 'promo_price' column based on the 'promo_type' values
UPDATE fact_events
SET promo_price = 
    CASE 
        WHEN promo_type = '25% OFF' THEN base_price * (1-0.25)
        WHEN promo_type = '33% OFF' THEN base_price * (1-0.33)
        WHEN promo_type = '50% OFF' THEN base_price * 0.50
        WHEN promo_type = 'BOGOF' THEN base_price *0.5
        WHEN promo_type = '500 Cashback' THEN base_price - 500
        ELSE base_price
    END;


-- Adding new column named promo_quantity 
ALTER TABLE fact_events
ADD COLUMN promo_quantity int;

-- Update the promo_quantity column based on 'promo_type'

UPDATE fact_events 
SET promo_quantity =
	CASE
		WHEN promo_type = 'BOGOF' THEN `quantity_sold(after_promo)` * 2
        ELSE `quantity_sold(after_promo)`
    End;

select sum(promo_quantity) from fact_events;

-- Adding new columns to store before and after revenue
ALTER TABLE fact_events
ADD COLUMN before_revenue DECIMAL(10,2),
ADD COLUMN after_revenue DECIMAL(10,2);


-- Update the new columns with calculated values
UPDATE fact_events
SET before_revenue = base_price * `quantity_sold(before_promo)`,
    after_revenue = promo_price * promo_quantity;


-- select count(distinct(store_id)) from retail_events_db.fact_events;  -- 50 distinct stores

-- How many products were promoted by each promo_type by each campaign

SELECT campaign_id ,promo_type, COUNT(DISTINCT(product_code)) AS products 
FROM retail_events_db.fact_events 
GROUP BY campaign_id ,promo_type;



/* Distinct Products for each Campaign by PromoType

Promo type 		CAMP_DIW_01(Diwali)   CAMP_SAN_01(Sankranthi)
25% OFF			4						4
33% OFF			2						2
50% OFF 		4						2
500 Cashback	1						1
BOGOF 			4						6

*/


/* ---------------------------------  BUSINESS REQUESTS --------------------------------- */

-- 1) List of products with high base price greater than 500 in BOGOF

SELECT DISTINCT(E.product_code),product_name ,base_price
FROM retail_events_db.fact_events E
LEFT JOIN dim_products P ON p.product_code =E.product_code
WHERE base_price >500 AND promo_type ="BOGOF";

-- * P08	Atliq_Double_Bedsheet_set 1190  ,P14 	Atliq_waterproof_Immersion_Rod 1020 *


-- 2) Stores in each city 	
SELECT city, COUNT(store_id) AS stores 
FROM retail_events_db.dim_stores 
GROUP BY city 
ORDER BY stores DESC;

-- * All of the stores are located in Southern India Mostly in Bengaluru 10 ,Chennai 8 , Hyderabad 7*


-- 3) Calculating after and before promotion revenue for each campaign

WITH campaign_id_revenue AS(
SELECT campaign_name as Campaign , 
	round(sum(before_revenue)/1000000 ,2) AS total_revenue_before_promotion,
	round(sum(after_revenue)/1000000 ,2) AS total_revenue_after_promotion
FROM fact_events E
LEFT JOIN dim_campaigns C 
ON E.campaign_id = C.campaign_id
GROUP BY campaign_name

) 
SELECT 	*, 
		round((total_revenue_after_promotion-total_revenue_before_promotion),2) AS Incremental_revenue,
		round((total_revenue_after_promotion-total_revenue_before_promotion)/total_revenue_before_promotion *100,2) AS 'IR%'  
FROM campaign_id_revenue;
        
-- Diwali campaign has high after promotion revenue (171.46 million) compared to sankranthi campaign with (124.15 million)
select 	campaign_id ,
		sum(promo_quantity) , 
        sum(`quantity_sold(before_promo)`) ,
        sum(promo_quantity) -sum(`quantity_sold(before_promo)`)  as ISU
from fact_events group by campaign_id;

-- 4) Incremental Sold Quantity by Category during Diwali

WITH Topcategory_ISU AS(
SELECT 	category,
		Sum(promo_quantity) AS after_quantity,
		Sum(`quantity_sold(before_promo)`) AS before_quantity
FROM fact_events E
LEFT JOIN dim_products P
ON E.product_code= P.product_code
WHERE campaign_id ="CAMP_DIW_01"   -- "CAMP_SAN_01" -- for Sankranthi Campaign
GROUP BY category
)
SELECT  category,
		(after_quantity - before_quantity) AS Incremental_sales_quantity,
		round(((after_quantity /before_quantity)-1)*100,2) AS `ISU%`,
		RANK() OVER( ORDER BY ((after_quantity /before_quantity)-1) Desc)  AS `ISU%_rank`
From Topcategory_ISU ;

/* Top 3 categories During Diwali
	
    By ISU% (Icremental sales revenue %)
    1) Home Appliances	2) Home Care 	3) Combo1
    
    BY ISU (Incremental sales Quantity)
    1) Combo1 	2) Home Appliances 		3)Home Care
*/


/* Top 3 categories During Sankranthi  (Groceries ,Home Appliances ,Home Care)
	
    By ISU% (Icremental sales revenue %)
    1) Home Appliances	2) Home Care	3)Grocery & Staples
    
    BY ISU (Incremental sales Quantity)
    1) Grocery & Staples 	2) Home Appliances 		3)Home Care
*/


-- EXTRA  Top 5 Quantity sold by each product with ISU rank (Incremental sales Quantity) 

WITH Top5products_ISU AS(
SELECT 	E.product_code,product_name , category ,
		Sum(promo_quantity) AS after_quantity,
		Sum(`quantity_sold(before_promo)`) AS before_quantity
FROM fact_events E
LEFT JOIN dim_products P
ON E.product_code= P.product_code
-- WHERE campaign_id ="CAMP_DIW_01"   -- "CAMP_SAN_01" -- Use this for filtering
GROUP BY product_code
)
SELECT  *,
		(after_quantity - before_quantity) AS Incremental_sales_quantity,
		round(((after_quantity /before_quantity)-1)*100,2) AS `ISU%`,
		RANK() OVER( ORDER BY ((after_quantity /before_quantity)-1) Desc)  AS `ISU%_rank`
From Top5products_ISU ;


/*	DIWALI CAMPAIGN BEST PERFORMING PRODUCTS 

Top 5 products  by ISU rank (each product has more than 200 ISU% ) 
	1) Atliq_waterproof_Immersion_Rod
	2) Atliq_Curtains
	3) Atliq_High_Glo_15W_LED_Bulb
	4) Atliq_Double_Bedsheet_set 
	5) Atliq_Home_Essential_8_Product_Combo

Top 5 products by Incremental Sales Quantity (with atlest 6000 units Increase)
	1) Atliq_Home_Essential_8_Product_Combo
	2) Atliq_High_Glo_15W_LED_Bulb
	3) Atliq_Sonamasuri_Rice (10KG)
	4) Atliq_Curtains
	5) Atliq_Masoor_Dal (1KG)

*/

/*	SANKRANTHI CAMPAIGN BEST PERFORMING PRODUCTS

Top 5 products  by ISU rank (top 6 product have more than 270 ISU% ) 
	1) Atliq_Suflower_Oil (1L)
	2) Atliq_waterproof_Immersion_Rod
	3) Atliq_High_Glo_15W_LED_Bulb
	4) Atliq_Farm_Chakki_Atta (1KG) 
	5) Atliq_Double_Bedsheet_set

Top 5 products by Incremental Sales Quantity
	1) Atliq_Farm_Chakki_Atta (1KG)
	2) Atliq_Suflower_Oil (1L) 
	3) Atliq_High_Glo_15W_LED_Bulb
	4) Atliq_waterproof_Immersion_Rod
	5) Atliq_Sonamasuri_Rice (10KG)

*/


-- 5) TOP 5 Products by Incremental Revenue across all campaigns

WITH Top5products_IR AS(
SELECT E.product_code,product_name ,category ,
	round(sum(before_revenue)/1000000 ,2) AS product_revenue_before_promotion_in_millions,
	round(sum(after_revenue)/1000000 ,2) AS product_revenue_after_promotion_in_millions
FROM fact_events E
LEFT JOIN dim_products P 
ON E.product_code=P.product_code
GROUP BY product_code
) 

SELECT product_name,category,
	product_revenue_after_promotion_in_millions - product_revenue_before_promotion_in_millions AS Incremental_revenue_in_millions,
    ROUND(((product_revenue_after_promotion_in_millions/product_revenue_before_promotion_in_millions) -1 )*100 ,2) AS `IR%`,
    RANK() OVER(
		ORDER BY ((product_revenue_after_promotion_in_millions/product_revenue_before_promotion_in_millions) -1) DESC) AS `IR%_rank`
FROM Top5products_IR LIMIT 5;


/* Top 5 Products based on IR% (Incremental Revenue %)

1) Atliq_waterproof_Immersion_Rod
2) Atliq_High_Glo_15W_LED_Bulb
3) Atliq_Double_Bedsheet_set
4) Atliq_Curtains
5) Atliq_Farm_Chakki_Atta (1KG)

*/

/*	Bottom 5 products based on IR (Incremental Revenue)

1) Atliq_Fusion_Container_Set_of_3
2) Atliq_Body_Milk_Nourishing_Lotion (120ML)
3) Atliq_Scrub_Sponge_For_Dishwash
4) Atliq_Cream_Beauty_Bathing_Soap (125GM)
5) Atliq_Lime_Cool_Bathing_Bar (125GM) 
    
*/
    


									/* RECOMMENDED INSIGHTS */

/* --------------------------------- STORE PERFORMANCE ANALYSIS --------------------------------- */


-- Creating stores cte for pre and post revenues and quantities


WITH TOP10Stores_IR AS(
 Select E.store_id,city, 
		Round(sum(before_revenue)/1000000,2) AS revenue_before, 
		Round(sum(after_revenue)/1000000,2) AS revenue_after
 From retail_events_db.fact_events E
 Left Join retail_events_db.dim_stores S
 ON E.store_id =S.store_id
 group by store_id
)
-- Top 10 stores Based on  Incremental Revenue 
Select 	store_id, city,
		ROUND((revenue_after - revenue_before),2) AS Incremental_revenue_in_millions ,
        Round(((revenue_after / revenue_before) -1)*100,2) AS  `IR%`,
        RANK() over (order by (revenue_after - revenue_before)  Desc) as `IR_rank`
FROM TOP10Stores_IR  Limit 10;

WITH BOTTOM10Stores_ISU AS(
 Select E.store_id,city, 
		sum(promo_quantity) AS after_quantity ,
        sum(`quantity_sold(before_promo)`) AS before_quantity
 From retail_events_db.fact_events E
 Left Join retail_events_db.dim_stores S
 ON E.store_id =S.store_id
 group by store_id
)
-- Top 10 stores Based on  Incremental Sales Quantity
Select 	store_id, city, 
		(after_quantity - before_quantity) AS Incremental_sold_units ,
        Round(((after_quantity / before_quantity) -1)*100,2) AS  `ISU%`,
        RANK() over(order by (after_quantity - before_quantity)  ASC) as `ISU_rank`
FROM BOTTOM10Stores_ISU LIMIT 10;

-- Performances of city -- Considering Average Incremental Revenue per store for the city

WITH Cities_CTE AS(
 Select City, Count(Distinct(S.store_id)) as Stores,
		sum(promo_quantity) AS after_quantity ,
        sum(`quantity_sold(before_promo)`) AS before_quantity,
        Round(sum(before_revenue)/1000000,2) AS revenue_before, 
		Round(sum(after_revenue)/1000000,2) AS revenue_after
 From retail_events_db.fact_events E
 Left Join retail_events_db.dim_stores S
 ON E.store_id =S.store_id
 group by City
)
select 	City, Stores,
		(sum(after_quantity)- sum(before_quantity)) AS ISU ,
        ROUND((sum(revenue_after) - sum(revenue_before)),2) AS IR_Millions ,
        ROUND((sum(revenue_after) - sum(revenue_before))/Stores,2) AS Avg_IR,
        (sum(after_quantity)- sum(before_quantity))/Stores AS Avg_ISU ,
		RANK() over(order by ((sum(revenue_after) - sum(revenue_before))/Stores)  Desc) as `Avg_IR_rank`,
        RANK() over(order by ((sum(after_quantity)- sum(before_quantity))/stores)  Desc) as `Avg_ISU_rank`
From Cities_CTE group by city;



/* --------------------------------- PROMOTION TYPE ANALYSIS --------------------------------- */

-- Creating CTE for pre and Post revenues and Quantities


WITH TOP2Promo_IR AS(
 Select E.promo_type, 
		Round(sum(before_revenue)/1000000,2) AS revenue_before, 
		Round(sum(after_revenue)/1000000,2) AS revenue_after
 From retail_events_db.fact_events E
 Left Join retail_events_db.dim_stores S
 ON E.store_id =S.store_id
 group by promo_type
)
 -- Top 2 promotion types with Incremental revenue
select 
	promo_type ,
    ROUND((revenue_after - revenue_before),2) AS Incremental_revenue ,
	Round(((revenue_after / revenue_before) -1)*100,2) AS  `IR%`,
	RANK() over( order by (revenue_after - revenue_before)  Desc) as `IR_rank`
From TOP2Promo_IR  limit 2;

-- 500 Cashback Incremental_revenenue 91 million , Next is BOGOF(Buy One Get One Free) 21.69


WITH Bottom2Promo_IR AS(
 Select E.promo_type, 
		sum(promo_quantity) AS after_quantity ,
        sum(`quantity_sold(before_promo)`) AS before_quantity
 From retail_events_db.fact_events E
 Left Join retail_events_db.dim_stores S
 ON E.store_id =S.store_id
 group by promo_type
)
-- Bottom 2 promotion types based on Incremental Sold Quantity
select 
	promo_type ,
    (after_quantity - before_quantity) AS Incremental_sold_units ,
	Round(((after_quantity / before_quantity) -1)*100,2) AS  `ISU%`,
	RANK() over(order by (after_quantity - before_quantity)  ASC) as `IS_rank`
From Bottom2Promo_IR  limit 2 ;


-- Difference in Promotion type (Discount vs BOGOF vs Cashback)
SELECT
 CASE
	 WHEN promo_type IN ('25% OFF', '50% OFF', '33% OFF') THEN 'Discount'
	 WHEN promo_type = '500 Cashback' THEN 'Cashback'
	 WHEN promo_type = 'BOGOF' THEN 'BOGOF'
 END AS promotion,
	sum(promo_quantity) - sum(`quantity_sold(before_promo)`) AS ISU,
    Round((Sum(after_revenue) -Sum(before_revenue))/1000000,2) AS IR
FROM retail_events_db.fact_events
GROUP BY promotion ORDER BY IR DESC;



/* --------------------------------- PRODUCT AND CATEGORY ANALYSIS --------------------------------- */

-- Categories that saw significant lift from the promotions

With Category_Performance_CTE As(
select 	P.category,
		sum(before_revenue)/1000000 as before_revenue,
        sum(after_revenue)/1000000 as after_revenue,
        sum(promo_quantity) as after_quantity,
        sum(`quantity_sold(before_promo)`) as before_quantity
from fact_events E
left join dim_products P 
On E.product_code =P.product_code
group by Category
)
-- Rank based on IR and ISU
Select 	Category,
		(after_revenue-before_revenue) as IR,
		rank() over(order by (after_revenue - before_revenue) Desc) as IR_Rank,
        (after_quantity- before_quantity) as ISU,
        rank() over(order by (after_quantity- before_quantity) Desc) as ISU_Rank
from Category_Performance_CTE ORDER BY IR_Rank;


-- Products that responded exponentional during promotions

With Product_Performance_CTE As(
select 	product_name, category,
		sum(before_revenue)/1000000 as before_revenue,
        sum(after_revenue)/1000000 as after_revenue,
        sum(promo_quantity) as after_quantity,
        sum(`quantity_sold(before_promo)`) as before_quantity
from fact_events E
left join dim_products P 
On E.product_code =P.product_code
group by product_name, category
)
-- Rank based on IR and ISU
Select 	product_name , category,
		(after_revenue-before_revenue) as IR,
		rank() over(order by (after_revenue - before_revenue) Desc) as IR_Rank,
        (after_quantity- before_quantity) as ISU,
        rank() over(order by (after_quantity- before_quantity) Desc) as ISU_Rank
FROM Product_Performance_CTE
ORDER BY IR_Rank ;


-- correlation between product category and promotion type effectiveness

/* Incremental Sold Quantity */
SELECT 
    category,
    SUM(CASE WHEN promo_type = '25% OFF' THEN promo_quantity - `quantity_sold(before_promo)` ELSE 0 END) AS '25% OFF',
    SUM(CASE WHEN promo_type = '33% OFF' THEN promo_quantity - `quantity_sold(before_promo)` ELSE 0 END) AS '33% OFF',
    SUM(CASE WHEN promo_type = '50% OFF' THEN promo_quantity - `quantity_sold(before_promo)` ELSE 0 END) AS '50% OFF',
    SUM(CASE WHEN promo_type = 'BOGOF' THEN promo_quantity - `quantity_sold(before_promo)` ELSE 0 END) AS 'BOGOF',
    SUM(CASE WHEN promo_type = '500 Cashback' THEN promo_quantity - `quantity_sold(before_promo)` ELSE 0 END) AS '500 Cashback'
FROM fact_events E
LEFT JOIN dim_products P ON E.product_code = P.product_code
GROUP BY category;


/* Incremental Revenue */

Select 	
		Category,
		round(sum(case when promo_type="25% OFF" then after_revenue-before_revenue else 0 end)/1000000,2)  as '25% OFF',
        round(sum(case when promo_type="33% OFF" then after_revenue-before_revenue else 0 end)/1000000,2)  as '33% OFF',
        round(sum(case when promo_type="50% OFF" then after_revenue-before_revenue else 0 end)/1000000,2)  as '50% OFF',
        round(sum(case when promo_type="BOGOF" then after_revenue-before_revenue else 0 end)/1000000,2)  as 'BOGOF',
        round(sum(case when promo_type="500 Cashback" then after_revenue-before_revenue else 0 end)/1000000,2)  as '500 Cashback'
From fact_events E
left join dim_products P on E.product_code =p.product_code
group by category;


/*  INSIGHTS

-- 	Every Product Category with ‘25%OFF’ Promotion Type has negative ISU Values
-- 	All product categories in BOGOF are Positive
-- 	Different categories when offered in BOGOF has positive Quantity over Discounted Prices
--  Personal Care Items when sold at 50 % discount has more sales than 25 % 
-- 	Grocery & Staples improved based on discount price
-- 	Personal Care has the negative IR values in both the promotion types.
*/

/* --------------------------------- EXTRA --------------------------------- */

-- Product Incremental sales Quantity and Incremental Revenue Based on Promotype and Campaign

Select 	product_name,
		round(sum(case when promo_type="25% OFF" then after_revenue-before_revenue else 0 end)/1000000,2)  as '25% OFF',
        round(sum(case when promo_type="33% OFF" then after_revenue-before_revenue else 0 end)/1000000,2)  as '33% OFF',
        round(sum(case when promo_type="50% OFF" then after_revenue-before_revenue else 0 end)/1000000,2)  as '50% OFF',
        round(sum(case when promo_type="BOGOF" then after_revenue-before_revenue else 0 end)/1000000,2)  as 'BOGOF',
        round(sum(case when promo_type="500 Cashback" then after_revenue-before_revenue else 0 end)/1000000,2)  as '500 Cashback'
From fact_events E
left join dim_products P on E.product_code =p.product_code
group by product_name;

With Promotion_vs_productCTE AS(

select 	Promo_type, E.product_code,product_name,category,campaign_id,
		round(sum(after_revenue)/1000000,2) as after_revenue_in_millions ,
        round(sum(before_revenue)/1000000,2) as before_revenue_in_millions,
        sum(promo_quantity) as after_quantity,
        sum(`quantity_sold(before_promo)`) as before_quantity
from retail_events_db.fact_events E
join retail_events_db.dim_products P 
ON E.product_code =P.product_code
Group by Promo_type	,product_name,product_code,category,campaign_id

)
select 	Promo_type,product_name,category,campaign_id,
		(after_quantity - before_quantity) as Incremental_sold_quantity ,
		(after_revenue_in_millions - before_revenue_in_millions) as Incremental_revenue_in_millions
from Promotion_vs_productCTE;

-- Best selling category in each city 

WITH Cities_CTE AS (
    SELECT 
        City, 
        product_name,
        SUM(promo_quantity) AS after_quantity,
        SUM(`quantity_sold(before_promo)`) AS before_quantity,
        SUM(promo_quantity) - SUM(`quantity_sold(before_promo)`) AS ISU
    FROM retail_events_db.fact_events E
    LEFT JOIN retail_events_db.dim_products P ON E.product_code = P.product_code
    LEFT JOIN retail_events_db.dim_stores S ON E.store_id =S.store_id
    GROUP BY City, product_name
),
Cities_CTE2 AS(
SELECT 
    City, 
    product_name AS Top_Product,
    ISU,
    ROUND(ISU*100/before_quantity,1) AS `ISU%`,
    RANK() OVER (PARTITION BY City ORDER BY ISU DESC) AS product_rank
FROM Cities_CTE 
)
Select City, Top_product,ISU,`ISU%` FROM Cities_CTE2 WHERE product_rank =1;

