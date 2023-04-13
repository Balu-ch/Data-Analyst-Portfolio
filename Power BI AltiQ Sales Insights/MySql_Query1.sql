#sales data for year 2020
SELECT year(order_date) as year,count(*) as sales_count ,sum(sales_qty) as sales_qty,
		sum(sales_amount)   as revenue ,round(avg(sales_amount),2 )as revenue_avg
FROM sales.transactions
group by year(order_date);
-- having year(order_date)=2020;
#output 2019 sales:52422	336452114	6418.15
#output 2020 sales:21550	142235559	6600.26

#most orders from these markets codes
select distinct(markets_name), count(market_code) as orders_count
from sales.transactions T
join sales.markets M
on T.market_code =M.markets_code
where year(order_date)='2020'
group by markets_name
order by orders_count desc limit 10;




#the top 5 states in sales in 2020
select distinct(markets_name),count(markets_name), sum(sales_amount) as sales_revenue
from sales.transactions T
inner join sales.markets M
on T.market_code = M.markets_code
where year(order_date)='2020'
group by markets_name
order by sales_revenue desc limit 5;


#top 10 selling  product in year 2020
select product_code ,count(product_code) as product_count
from sales.transactions
where year(order_date)='2020'
group by product_code
order by product_count desc limit 10;


#top 10 products in Delhi year 2020 (since it is top in sales)
select product_code, count(product_code) as product_sales
from sales.transactions T
inner join sales.markets M
on T.market_code = M.markets_code
where markets_name like '%Delhi%' and year(order_date)='2020'
group by product_code
order by product_sales desc limit 10; 

# get sales-qnt, customers, revenue

# lets find out top 10 products ordered by top 10 states

select * 
from (select distinct(markets_name),count(markets_name), sum(sales_amount) as sales_revenue
from sales.transactions T
inner join sales.markets M
on T.market_code = M.markets_code
where year(order_date)='2020'
group by markets_name
)as S;

#first: remove garbage Values 
#second: remove Duplicates
#third: remove unnecessary details


# Create a cte wheres sales_amount >0 and sales-qty >0
with cte_newSales as (
select * from sales.transactions
where sales_amount>0 and sales_qty>0
)
# lets findout Duplicates from cte 

select customer_code,market_code,order_date,sales_qty,sales_amount, count(customer_code) as c_count 
from cte_newSales
group by customer_code,market_code,order_date,sales_qty,sales_amount
having count(*)>1 ;

select * from cte_newSales;

#lets find out the duplicate rows

select customer_code,market_code,order_date,sales_qty,sales_amount, count(customer_code) as c_count 
from sales.transactions where sales_amount >0 and sales_qty>0 
group by customer_code,market_code,order_date,sales_qty,sales_amount
having count(*)=1 ;
#normaly what i would do is remove the duplicates from the cte and create a temp table out from the cte_newSales and cleaned values
# The remaining is done in power bi.

#top 10 customers by revenue.
select custmer_name ,sum(cost_price) as revenue
from customers c  left join  transactions t 
on c.customer_code =t.customer_code
group by custmer_name
order by revenue desc limit 10;

# top 10 customer with sales Quantity
select custmer_name ,sum(sales_qty ) as sales_qnty
from customers c  join  transactions t 
on c.customer_code =t.customer_code
group by custmer_name
order by sales_qnty desc limit 10;
