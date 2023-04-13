-- Query 1

-- Top 10 districts domestic
Select district,sum(visitors) as visitors  
from visitors_new.domestic_visitors_new 
group by district order by visitors desc limit 10;

-- Top 5 districts foreign
Select district,sum(visitors) as visitors  
from visitors_new.foreign_visitors_new 
group by district order by visitors desc limit 5;


 # ----------------------------------------------------------------------------------------------------------------------------#



-- Query 2

-- CAGR from 2016-2019 (3 years)
#CAGR formula is (FV/IV)^(1/n) -1   n= 2019 -2016 =3

-- For Domestic
with cte as(
Select district,
sum(case when year = 2016 Then visitors else 0 End) as IV,   #all the visitors from 2016 district wise
sum(case when year = 2019 Then visitors else 0 End) as FV	 #all the visitors from 2019 district wise
from visitors_new.domestic_visitors_new
group by district
)
select district,IV,FV, round((power((FV/IV),1/3)-1)*100,2) as CAGR
from cte
order by CAGR desc limit 5;

 # ----------------------------------------------------------------------------------------------------------------------------#
-- For Foreign
with cte as(
Select district,
sum(case when year = 2016 Then visitors else 0 End) as IV,   #all the visitors from 2016 district wise
sum(case when year = 2019 Then visitors else 0 End) as FV	 #all the visitors from 2019 district wise
from visitors_new.foreign_visitors_new
group by district
)
select district,IV,FV, round((power((FV/IV),1/3)-1)*100,2) as CAGR
from cte
order by CAGR desc limit 5;

# ----------------------------------------------------------------------------------------------------------------------------#
-- Query 3
-- Domestic
with cte as(
Select district,
sum(case when year = 2016 Then visitors else 0 End) as IV,
sum(case when year = 2019 Then visitors else 0 End) as FV
from visitors_new.domestic_visitors_new
group by district
),
cte2 as (
select district,IV,FV, round((power((FV/IV),1/3)-1)*100,2) as CAGR
from cte
)
select * from cte2 
where CAGR is not null   -- if IV is zero we get Infinity to remove that we use cagr is not null
order by cagr limit 3;
# ----------------------------------------------------------------------------------------------------------------------------#
-- Foreign
with cte as(
Select district,
sum(case when year = 2016 Then visitors else 0 End) as IV,
sum(case when year = 2019 Then visitors else 0 End) as FV
from visitors_new.foreign_visitors_new
group by district
),
cte2 as (
select district,IV,FV, round((power((FV/IV),1/3)-1)*100,2) as CAGR
from cte
)
select * from cte2 
where CAGR is not null   -- if IV is zero we get Infinity to remove that we use cagr is not null
order by cagr limit 3;

# ----------------------------------------------------------------------------------------------------------------------------#
-- Query 4

-- Domestic 
-- Top 3 months
select month as peak_season, sum(visitors) as visitors
from visitors.domestic_visitors
where district ="Hyderabad"
group by month
order by visitors desc limit 3;

-- Last 3 months
select month as low_season, sum(visitors) as visitors
from visitors.domestic_visitors
where district ="Hyderabad"
group by month
order by visitors limit 3;

-- Top 5 districts 
select district, sum(visitors) as visitors
from visitors.domestic_visitors
where month ="February"
group by district
order by visitors desc limit 5;
 # ----------------------------------------------------------------------------------------------------------------------------#
-- Foreign

-- Top 5 months
select month as peak_season , sum(visitors) as visitors
from visitors.foreign_visitors
where district ="Hyderabad"
group by month
order by visitors desc limit 3;

-- Last 3 months
select month as low_season, sum(visitors) as visitors
from visitors.foreign_visitors
where district ="Hyderabad"
group by month
order by visitors limit 3;

# ----------------------------------------------------------------------------------------------------------------------------#
-- Query 5

with cte as (
select D.district ,
 sum(D.visitors) as Dvisitor,sum(F.visitors) as Fvisitor
from visitors_new.domestic_visitors_new D
join visitors_new.foreign_visitors_new F
on D.district =F.district and D.month = F.month and D.year =F.year
group by D.district
)

select district,Dvisitor,Fvisitor,DtoFratio,top 
from(select  * ,rank() over(order by DtoFratio) as top ,rank() over(order by DtoFratio desc) as least
		from (select * ,round(Dvisitor/Fvisitor) as DtoFratio
				from cte) subquery
where DtoFratio is not null)subquery2   -- excluding foreign null values since foreignVisitors are zero
where top<4 or least<4
order by top;


 # ----------------------------------------------------------------------------------------------------------------------------#
-- Query 6
# The data is taken from https://www.indiagrowing.com/Telangana
# 2023 population - 2011 population =inc_popuation => 38472769   -   35286757=31,86,012
# inc_population/2011 population =growth => 3186012   ÷   35286757 =0.0902891699568765
#Growth*100/years = yearly growth percentage => 0.09 *100  ÷   11 =0.8181818181818182 =(0.8) percentage
# (2011 population) *0.008 =yearly growth => 282294
#lets assume its growing by 0.008 (0.8%) for 2025   35286757+14*(yearly growth)  => 35286757+3952116    =>39238873

-- Domestic 
with cte as (
 select p.district,year,Est_population_2019,sum(visitors) as visitors
 from visitors_new.population_new P
 join visitors_new.domestic_visitors_new D
 on P.district =D.district
 where year =2019 
 group by p.district,Est_population_2019,year)
 
 select district,footfall_ratio,top from
	 (select district,(visitors/Est_population_2019) as footfall_ratio ,
     row_number() over(order by (visitors/Est_population_2019) desc) as top, 
     row_number() over(order by (visitors/Est_population_2019) ) as low 
     from cte where visitors>0) subquery     
     where top<6 or low <6
 order by footfall_ratio desc;

 # ----------------------------------------------------------------------------------------------------------------------------#
-- Foreign
with cte as (
 select p.district,year,Est_population_2019,sum(visitors) as visitors
 from visitors_new.population_new P
 join visitors_new.foreign_visitors_new F
 on P.district =F.district
 where year =2019
 group by p.district,Est_population_2019,year)
select district,footfall_ratio,top from
	 (select district,(visitors/Est_population_2019) as footfall_ratio ,
     row_number() over(order by (visitors/Est_population_2019) desc) as top, 
     row_number() over(order by (visitors/Est_population_2019) ) as low 
     from cte ) subquery
where top<4					-- we only have 2 states with good footfall_ratio 
order by footfall_ratio desc;
 # ----------------------------------------------------------------------------------------------------------------------------#

-- Query 7  and Query 8
 # ----------------------------------------------------------------------------------------------------------------------------#
 -- Estimated Domestic visitors 2025
 #creating cte for Hyderabad visitors for calculation
 with cte as(
  Select district,
sum(case when year = 2016 Then visitors else 0 End) as visitors_2016 ,   #all the visitors from 2016 district wise
sum(case when year = 2019 Then visitors else 0 End) as visitors_2019	 #all the visitors from 2019 district wise
from visitors_new.domestic_visitors_new
group by district 
having district ="Hyderabad"
),
cte2 as(
 select visitors_2019 as dom_visitors_2019,(power((visitors_2019/visitors_2016),(1/3))-1)  as AGR from cte   #AGR -0.16
)

 #result
select dom_visitors_2019 ,
		dom_visitors_2019 *1200 as rev_dom_visitors_2019 ,
		round(dom_visitors_2019*power((1-0.16),6)) as dom_visitors_2025 ,
        round(dom_visitors_2019*power((1-0.16),6))*1200 as rev_dom_visitors_2025
from cte2;   

 # ----------------------------------------------------------------------------------------------------------------------------#
 -- Foreign Vistors by 2025
 
-- Projected visitors = Current visitors x (1 + Annual Growth Rate)^(Number of Years)
-- Annual Growth Rate = [(Ending Value / Beginning Value)^(1 / Number of Years)] - 1

#Calculation part
with cte as(
  Select district,
sum(case when year = 2016 Then visitors else 0 End) as visitors_2016 ,   #all the visitors from 2016 district wise
sum(case when year = 2019 Then visitors else 0 End) as visitors_2019	 #all the visitors from 2019 district wise
from visitors_new.foreign_visitors_new
group by district 
having district ="Hyderabad"
),
cte2 as(
 select visitors_2019 as for_visitors_2019 ,(power((visitors_2019/visitors_2016),(1/3))-1)  as AGR from cte   #AGR =0.25
 )
 
 #result
select for_visitors_2019 ,
		for_visitors_2019 *5600 as rev_for_visitors_2019, 
		round(for_visitors_2019*power((1+0.25),6)) as for_visitors_2025 ,
        round(for_visitors_2019*power((1+0.25),6))*5600 as rev_for_visitors_2025
from cte2;   

 # ----------------------------------------------------------------------------------------------------------------------------#
  
  
  