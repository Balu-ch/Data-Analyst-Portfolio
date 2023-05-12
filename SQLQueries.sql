/*-----------------------------------------------------------------------------------------*/
-- Basic Details for better understanding the organisation / company

-- Number of Customers	-> 74 customers
select customer,row_number() over() as id from gdb023.dim_customer group by customer;

-- Markets and Regions  -> 4 regions,7 sub_zones 27 markets(countries)  ,EU has highest markets 11 , APAC with 10 ,ROA, NE subzones with highest number of markets 7

select market,
sub_zone,row_number() over(partition by sub_zone) as subzones,
region , row_number() over(partition by region) as regional_markets
from gdb023.dim_customer
group by market,sub_zone,region ;


-- Revenue details '3711715930'|  2021, '2628033152' |2020, '1083682779'

select monthlysales.fiscal_year, round(sum(sold_quantity * gross_price)) as revenue   
from gdb023.fact_sales_monthly monthlysales
left join gdb023.fact_gross_price grossprice
on monthlysales.product_code =grossprice.product_code
group by fiscal_year;

-- Revenue by Market

select market, monthlysales.fiscal_year,round(sum(sold_quantity * gross_price)) as revenue
from gdb023.dim_customer customers
join (gdb023.fact_sales_monthly monthlysales
join gdb023.fact_gross_price grossprice
on monthlysales.product_code =grossprice.product_code) 
on customers.customer_code =monthlysales.customer_code
group by market,monthlysales.fiscal_year;


-- performance of each market 

with cte as(
--  I want to know the revenue of each market by each year. which helps me to see the top markets and growth percentages.
select market, 
round(sum(case when monthlysales.fiscal_year =2020 then sold_quantity * gross_price else 0 end)) as revenue2020,
round(sum(case when monthlysales.fiscal_year =2021 then sold_quantity * gross_price else 0 end)) as revenue2021
from gdb023.dim_customer customers
join (gdb023.fact_sales_monthly monthlysales
join gdb023.fact_gross_price grossprice
on monthlysales.product_code =grossprice.product_code) 
on customers.customer_code =monthlysales.customer_code
group by market
) 
select market,revenue2020,row_number() over(order by revenue2020 desc) rank2020,
revenue2021, row_number() over(order by revenue2021 desc) rank2021,
(revenue2021-revenue2020)/revenue2020  as growth 
from cte;



/*-----------------------------------------------------------------------------------------*/
-- Requested Queries.


-- Query 1
SELECT distinct(market)
FROM gdb023.dim_customer 
where customer ='Atliq Exclusive' and region ='APAC';

-- market size
SELECT market, sum(sold_quantity) sales
FROM gdb023.dim_customer c
join gdb023.fact_sales_monthly s 
on c.customer_code =s.customer_code
where customer ='Atliq Exclusive' and region ='APAC'
group by market ;

-- Query 2

with cte1 as(
SELECT count(distinct(product_code)) as unique_products_2020
FROM gdb023.fact_gross_price 
where fiscal_year ='2020'
),
cte2 as(
SELECT count(distinct(product_code)) as unique_products_2021
FROM gdb023.fact_gross_price 
where fiscal_year ='2021'
)
select *, round((((unique_products_2021-unique_products_2020)/unique_products_2020)*100)) as per_change 
from cte1,cte2;

-- Query 3

SELECT distinct(segment), count(segment) as product_count 
FROM gdb023.dim_product 
group by segment order by product_count desc ;

-- Gross sales for each division.

with cte1 as(
SELECT distinct(segment),count(segment) as product_count,
	round(avg(gross_price),1) as avg_price,
    round(sum(gross_price),1) as gross_price
FROM gdb023.dim_product p
inner join gdb023.fact_gross_price g
on p.product_code =g.product_code
group by segment order by product_count desc
)
select segment ,product_count, round(avg(avg_price),1) as segment_avg_price ,
sum(gross_price) as segment_gross_price
from cte1 group by segment order by segment_avg_price;


-- Query 4

SELECT * FROM gdb023.fact_sales_monthly;
SELECT * FROM gdb023.dim_product;

with cte1 as(
SELECT segment ,count(distinct(p.product_code)) as qnty,fiscal_year
FROM gdb023.dim_product p
join gdb023.fact_sales_monthly s
on p.product_code =s.product_code
group by fiscal_year,segment
),
cte2 as(
select segment,qnty as product_count_2020 
from cte1 where fiscal_year =2020 
group by segment,fiscal_year
),
 cte3 as (
select segment,qnty as product_count_2021 
from cte1 where fiscal_year =2021 
group by segment,fiscal_year
)
select distinct(cte3.segment), product_count_2020 , product_count_2021 
,(product_count_2021 -product_count_2020) as difference
from cte2 join cte3  on cte2.segment =cte3.segment
order by difference desc;


-- Query 5.

SELECT * FROM gdb023.fact_manufacturing_cost;
SELECT * FROM gdb023.dim_product;


select product_code,product ,manufacturing_cost
from(
select p.product_code,product ,manufacturing_cost ,
Rank() over(order by manufacturing_cost) as lowest,
Rank() over(order by manufacturing_cost desc) as highest
from gdb023.dim_product p
join gdb023.fact_manufacturing_cost m
on p.product_code =m.product_code
group by product,manufacturing_cost,product_code
) subquery
where lowest =1 or highest =1;

# Top 3 products 
select product_code,product ,manufacturing_cost ,segment,variant ,2021 as year
from(
select p.product_code,product ,manufacturing_cost ,segment,variant,
Rank() over(order by manufacturing_cost) as lowest,
Rank() over(order by manufacturing_cost desc) as highest
from gdb023.dim_product p
join gdb023.fact_manufacturing_cost m
on p.product_code =m.product_code
where cost_year =2021
group by product,manufacturing_cost,product_code,segment,variant
) subquery
where lowest <4 or highest <4;



-- Query 6
SELECT * FROM gdb023.fact_pre_invoice_deductions;
SELECT * FROM gdb023.dim_customer;

SELECT c.customer_code,customer,avg(pre_invoice_discount_pct)*100 as avg_disc
FROM gdb023.dim_customer c 
join gdb023.fact_pre_invoice_deductions i 
on c.customer_code =i.customer_code 
where market ='India' and fiscal_year =2021
group by customer_code,customer
order by avg_disc desc limit 5;

-- Query 7
SELECT * FROM gdb023.fact_sales_monthly;
SELECT * FROM gdb023.fact_gross_price;

select monthname(s.date) as _month, year(s.date) _year, sum(gross_price) as Gross_sales_Amount
from  gdb023.fact_sales_monthly s
join gdb023.fact_gross_price g
on s.product_code =g.product_code
group by _month ,_year
order by _year;

-- Query 8

-- Queterly sales in 2020 
with cte1 as(
select monthname(s.date) as _month, year(s.date) _year,fiscal_year, sum(sold_quantity) as sales,
case 
	when month(s.date) between 9 and 11 then 'Q1'
    when month(s.date) in (12 ,1, 2) then 'Q2'
    when month(s.date) between 3 and 5 then 'Q3'
    Else 'Q4'
    end as fiscal_Quarter
from  gdb023.fact_sales_monthly s
group by _month ,_year,fiscal_Quarter,fiscal_year
order by _year
)
select fiscal_Quarter ,sum(sales) sales from cte1
where fiscal_year =2020
group by fiscal_Quarter;


-- Queterly sales in 2021
with cte1 as(
select monthname(s.date) as _month, year(s.date) _year,fiscal_year, sum(sold_quantity) as sales,
case 
	when month(s.date) between 9 and 11 then 'Q1'
    when month(s.date) in (12 ,1, 2) then 'Q2'
    when month(s.date) between 3 and 5 then 'Q3'
    Else 'Q4'
    end as fiscal_Quarter
from  gdb023.fact_sales_monthly s
group by _month ,_year,fiscal_Quarter,fiscal_year
order by _year
)
select fiscal_Quarter ,sum(sales) sales from cte1
where fiscal_year =2021
group by fiscal_Quarter;

-- monthly sales in fiscal_year 2020
with cte1 as(
select monthname(s.date) as _month, year(s.date) _year,fiscal_year, sum(sold_quantity) as sales,
case 
	when month(s.date) between 9 and 11 then 'Q1'
    when month(s.date) in (12 ,1, 2) then 'Q2'
    when month(s.date) between 3 and 5 then 'Q3'
    Else 'Q4'
    end as fiscal_Quarter
from  gdb023.fact_sales_monthly s
group by _month ,_year,fiscal_Quarter,fiscal_year
order by _year
)
select _month ,sales from cte1
where fiscal_year =2020;


-- Query 9
SELECT * FROM gdb023.dim_customer;
SELECT * FROM gdb023.fact_sales_monthly;
SELECT * FROM gdb023.fact_gross_price;

-- 2021 results
select channel,round(sum(amount)/1000000,1) as gross_sales_mln,
round(sum(amount)/(select sum(gross_price*sold_quantity)
				from gdb023.fact_sales_monthly s
                join gdb023.fact_gross_price g
                on g.product_code =s.product_code
                where s.fiscal_year =2021 )*100 ,2)as percentage
from(
	select channel, gross_price*sold_quantity as amount ,s.fiscal_year
	from(( gdb023.fact_sales_monthly s
		join gdb023.dim_customer c
			on c.customer_code =s.customer_code)
		join gdb023.fact_gross_price g
			on g.product_code =s.product_code)
	Where s.fiscal_year =2021) subquery
group by subquery.channel order by percentage desc;

-- 2020 results
select channel,round(sum(amount)/1000000,1) as gross_sales_mln,
round(sum(amount)/(select sum(gross_price*sold_quantity)
				from gdb023.fact_sales_monthly s
                join gdb023.fact_gross_price g
                on g.product_code =s.product_code
                where s.fiscal_year =2020 )*100 ,2)as percentage
from(
	select channel, gross_price*sold_quantity as amount ,s.fiscal_year
	from(( gdb023.fact_sales_monthly s
		join gdb023.dim_customer c
			on c.customer_code =s.customer_code)
		join gdb023.fact_gross_price g
			on g.product_code =s.product_code)
	Where s.fiscal_year =2020) subquery
group by subquery.channel order by percentage desc;



-- Query 10

SELECT * FROM gdb023.fact_sales_monthly;
SELECT * FROM gdb023.dim_product;

select division,product,product_code,total_sold_quantity,rank_num from (
select division,s.product_code,product,
sum(sold_quantity) as total_sold_quantity, 
rank() over(partition by division order by sum(sold_quantity) desc) as rank_num,
fiscal_year
from gdb023.fact_sales_monthly s 
join gdb023.dim_product p 
on s.product_code = p.product_code
group by division, product_code,product, fiscal_year
) subquery
where rank_num <=3 and fiscal_year =2021;

select division,product,product_code,total_sold_quantity,rank_num ,variant from (
select division,s.product_code,product,
sum(sold_quantity) as total_sold_quantity, 
rank() over(partition by division order by sum(sold_quantity) desc) as rank_num,
fiscal_year,variant
from gdb023.fact_sales_monthly s 
join gdb023.dim_product p 
on s.product_code = p.product_code
group by division, product_code,product, fiscal_year,variant
) subquery
where rank_num <=3 and fiscal_year =2021