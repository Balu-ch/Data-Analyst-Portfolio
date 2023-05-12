SQL Consumer Goods Challenge

This repository contains a report on the analysis of sales by customers and products for Atliq Hardwares. The report is based on various categories and segments to provide a comprehensive understanding of the business.

Dashboard: https://www.novypro.com/project/consumer-goods-analysis-atliq-hardware-

Process
	The analysis was carried out by leveraging SQL for efficient ETL operations and queries. Power BI was then used to create visually appealing dashboards to analyze sales data. The sales data was utilized to perform an in-depth analysis of consumer sales performance, identifying key trends and opportunities to optimize revenue. Detailed reports and visualizations using data analysis tools were developed, providing actionable insights to improve sales strategy and drive business growth.

Database :https://codebasics.io/challenge/codebasics-resume-project-challenge  #challenge-4

Files 
	Sql Queries :SQLQueries.sql 
	Presentation: Consumer Goods Report.pptx ,
	Query Visualizations: Consumer Goods Analysis - Queries.pbix,
	Dashboard: Consumer Goods Analysis -Report.pbix


Insights

Country
	Most of the markets are located in the APAC and EU regions, but 55% of revenue contribution comes from the APAC region.
	Region - Contribution%: APAC - 55%, EU - 23%, NA - 21.5%, LATAM - 0.5%.
	Top 5 countries: India, USA, Canada, South Korea, Philippines.
	Bottom 5 Countries: Brazil, Chile, Sweden, Columbia, Mexico.

Revenue
	The top 5 countries, India, USA, Canada, South Korea, and Philippines, remain the same for both years (2020, 2021).
	The Growth % helps us to find out the improvement in revenue from 2020-2021.
	In the bottom 5 countries, we can see rapid growth in Growth % except for Brazil, which had negative growth percentage.
	The mean growth rate of Top 5 Countries is 190.8%, and the total mean growth rate is 378.8%. This difference is due to some outliers like Austria, Columbia, Sweden which had a higher growth percentage and lower share % (<0.5%).
	We need to reconsider the sales strategy in lower growth percentage, which has a share% less than 1 [Austria, Sweden, Brazil, Mexico, Chile, Columbia].

Profit
	Products:
		4 out of the top 10 products belong to Notebooks, and 3 of them are in the top 5. 3 out of the top 10 products belong to accessories.
		9 out of 10 bottom products belong to P&A division (Peripherals(5) and accessories (4)).

	Customers:
		The highest number of sales and profit comes from E-commerce. 3 out of the top 5 belong to E-commerce.
		The bottom 10 customers are from Brick & motors platform. But Brick and motors play an important role in Profit%, almost (70%).
		For Profit % in segments, Notebooks (32.3%) are the highest, followed by Accessories (28.5%).
		The profit % of top 10 customers contributes to 51% (30% is from E-Commerce, and 21% is from Brick&Motors).

Top 5 Vs Bottom 5 countries
	The pie charts show revenue by Top 5, bottom 5 countries with top 5, bottom 5 categories.
	Top 5 Categories (Keyboard, Business Laptops, Personal Laptops, Processors, Mouse)
	Bottom 5 Categories (USB Flash Drives, Batteries, Personal Desktop, Internal HDD, Motherboard)
	The top 5 countries contribute to almost 62% of revenue, and the top 5 categories contribute 41.6%.
	The bottom 5 categories contribute at least 3.6% from the top 5 countries. The total contribution of bottom




