-- Altering Table names for better understanding
Alter table parental_leave rename column Company to company,
						   rename column Industry to industry,
                           rename column `Sub Industry` to sub_industry,
                           rename column `Paid Maternity Leave` to paid_maternity_leave,
                           rename column `Unpaid Maternity Leave` to unpaid_maternity_leave,
						   rename column `Paid Paternity Leave` to paid_paternity_leave,
                           rename column `Unpaid Paternity Leave` to unpaid_Paternity_leave;


# Paid Maternity Leave
SELECT industry,avg(paid_maternity_leave) as avgpml, avg(paid_paternity_leave) as avgppl,count(company) as cnt
FROM maven.parental_leave
where industry <>"N/A"
group by industry
order by avgpml desc,cnt ;


# Unpaid Materninty Leave
SELECT industry,unpaid_maternity_leave,
count(industry) over(partition by industry) as cnt_upml
FROM maven.parental_leave
where industry <>"N/A"
group by industry
order by cnt_upml desc,avg_upml desc,industry ;


# Least 'Natural Resources: Agrochemical', '0.0000'  count 1
# Highest 'Transportation: Bus', '52.0000' count 1  (outliers)

# Highest PML Companies in the data set are Technology:Software with count 160 with 89 days = 12weeks 5days
# Highest UPML Companies in the data set are Technology:Software with 40 days

-- companies which offer both PPL PML
select count(distinct company) from maven.parental_leave
where paid_maternity_leave>0 and paid_paternity_leave>0;

-- companies with 0 PPL PML
select count(distinct company) from maven.parental_leave
where paid_maternity_leave=0 and paid_paternity_leave=0;

select count(distinct company) from maven.parental_leave
where paid_maternity_leave >=24;

-- companies which offer paid_paternity Leave and count
select paid_paternity_leave ,count(distinct company) as cnt from maven.parental_leave
group by paid_paternity_leave
having paid_paternity_leave>0
order by cnt desc;

-- companies which offer paid_paternity Leave >= 6 and  paid_maternity >= 12

select distinct company, paid_maternity_leave,paid_paternity_leave from maven.parental_leave
where paid_paternity_leave>=6 and paid_maternity_leave>=24 
order by paid_maternity_leave desc,paid_paternity_leave desc;



-- Industries
select count(distinct industry) from maven.parental_leave
where paid_maternity_leave>0 and paid_paternity_leave>0  and industry <>"N/A";

select industry , count(industry)  as cnt,avg(paid_maternity_leave) as avgPML, avg(paid_paternity_leave) as avgPPL from maven.parental_leave
where paid_maternity_leave>0 and paid_paternity_leave>0  and industry <>"N/A"
group by industry order by  avgPML desc,avgPPL desc,cnt desc;

-- Philanthropy , Conglomerate , Publishing , Maritime , Law Firm 
select industry , count(industry)  as cnt,avg(paid_maternity_leave) as avgPML, avg(paid_paternity_leave) as avgPPL from maven.parental_leave
where industry <>"N/A"
group by industry order by  avgPML desc,avgPPL desc,cnt desc;

-- Philanthropy , Accounting Services , Leisure - Travel & Tourism , Public Relations , Law Firm

select industry,avg(paid_maternity_leave) as avgpml from maven.parental_leave group by Industry ;
