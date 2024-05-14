--1. Retrieve all columns for all records in the dataset.
select * from [dbo].[Pharma_data$];

--2. How many unique countries are represented in the dataset?
select  count(distinct [Country]) as Unique_Country_Count from [dbo].[Pharma_data$] ;
-- Validation
select country, count(country) as count_per_country from Pharma_data$ 
group by country order by Country;

--3. Select the names of all the customers on the 'Retail' channel.
select [Customer Name] from [dbo].[Pharma_data$] where [Channel] = 'Retail';

select [Channel], count([Channel]) from [dbo].[Pharma_data$]
group by Channel;

select count(channel) from [dbo].[Pharma_data$];

------ After validation, no 'Retail' in Channel and the query should be adjusted to be selected from Sub-channel

select  distinct [Customer Name] from [dbo].[Pharma_data$] where [Sub-channel] = 'Retail'
order by [Customer Name];

--4. Find the total quantity sold for the ' Antibiotics' product class.

select [Product Class] , ROUND((sum([Quantity]) / 1000000), 2) as total_quantity_per_Million from [dbo].[Pharma_data$] 
where [Product Class] = 'Antibiotics'
group by[Product Class] ;

------- This query shows antibiotics with Quantity float values for reference validations from DBO

select  [Product Name],[Product Class],[Quantity] from [dbo].[Pharma_data$] 
where [Product Class] = 'Antibiotics' and [Quantity] like '%.%';

--5. List all the distinct months present in the dataset.

select distinct [Month] from [dbo].[Pharma_data$];

select distinct [Month], count([Month]) as Month_count from [dbo].[Pharma_data$]
group by [Month] order by count([Month]) desc;

--6. Calculate the total sales for each year.
select [Year], cast(round((SUM([Sales]) / 1000000000) , 1) as varchar(max)) + ' B' as Total_sales_in_billion from [dbo].[Pharma_data$]
group by [Year] order by [Year] asc;

--7. Find the customer with the highest sales value.
select top 1 [Customer Name],sum([Quantity]) as total_quantity_purchased, cast((sum([Sales]) / 1000000) as varchar(max)) + ' M ' as Highest_total_sales_in_Million 
from [dbo].[Pharma_data$] group by [Customer Name] 
order by sum([Sales]) desc ;

--8. Get the names of all employees who are Sales Reps and are managed by 'James Goodwill'.
select distinct [Name of Sales Rep] from [dbo].[Pharma_data$]
where [Manager] = 'James Goodwill';

------ Count of sales rep per each manager
select [Manager] ,  count(distinct [Name of Sales Rep]) from [dbo].[Pharma_data$]
group by [Manager];

--9. Retrieve the top 5 cities with the highest sales.
select top 5 [City], cast((sum([Sales]) / 1000000) as varchar(max)) + ' M' as total_sales_in_Millions from [dbo].[Pharma_data$]
group by [City] order by sum([Sales]) desc;

--10. Calculate the average price of products in each sub-channel.
select [Sub-channel], ROUND(AVG([Price]), 2) as Average_price from [dbo].[Pharma_data$] 
group by [Sub-channel] order by AVG([Price]) desc;

--Join the 'Employees' table with the 'Sales' table to get the name of the Sales Rep and the corresponding sales records.
------ I've tried this query without using self join.
select [Name of Sales Rep], ROUND((sum([Sales]) / 1000000),2) as total_sales_in_Millions, [Manager]
from [dbo].[Pharma_data$] 
group by [Name of Sales Rep],[Manager] order by sum([Sales]) desc ;

--12. Retrieve all sales made by employees from ' Rendsburg ' in the year 2018.
select cast(ROUND((sum([Sales]) / 1000000),2) as varchar(max)) + ' M ' as Rendsburg_sales_in_millions from [dbo].[Pharma_data$] 
where [City] = 'Rendsburg';

--13. Calculate the total sales for each product class, for each month, and order the results by year, month, and product class.

-------1st step to make a date column 
ALTER TABLE [dbo].[Pharma_data$] 
ADD month_date date;

UPDATE [dbo].[Pharma_data$]
SET month_date = CONVERT(date, CONCAT([Month], [Year]));

------2nd step to execute the query
select  [Product Class], year([month_date]) as year_number , DATENAME(MONTH, month_date) AS month_name ,
		cast((round(sum([Sales] / 1000000),2)) as varchar(max)) + ' M' as sales_in_millions
from [dbo].[Pharma_data$]
group by [Product Class], year([month_date]), month( [month_date]) ,DATENAME(MONTH, month_date)
order by year([month_date]) asc,month( [month_date]) asc , [Product Class] asc ;

--14. Find the top 3 sales reps with the highest sales in 2019.
select top 3 [Name of Sales Rep] , cast(round(sum([Sales])/ 1000000 , 2) as varchar(max)) + ' M' as total_2019_sales
from [dbo].[Pharma_data$] where [Year] = 2019
group by [Name of Sales Rep] order by sum([Sales]) desc;

--15. Calculate the monthly total sales for each sub-channel,
--and then calculate the average monthly sales for each sub-channel over the years.

-------1st step : sales for each sub-channel
select [Sub-channel], cast(round(sum([Sales])/ 1000000000 , 2) as varchar(max)) + ' B' as sales_in_billions
from [dbo].[Pharma_data$]
group by [Sub-channel] order by sales_in_billions desc;

-------2nd step : average monthly sales for each sub-channel
select [Sub-channel], cast(round(avg([Sales])/ 1000 , 2) as varchar(max)) + ' K' as sales_in_thousands
from [dbo].[Pharma_data$]
group by [Sub-channel] order by sales_in_thousands desc;

--16. Create a summary report that includes the total sales, average price, and total quantity sold for each product class.
select [Product Class], cast((round((sum([Sales])/ 1000000000), 2)) as varchar (max)) + ' B' as total_sales_in_Billions,
round(AVG([Price]), 2) as Average_price,
cast(round((sum([Quantity]) / 1000000),2) as varchar(max)) + ' M'as Units_in_millions
from [dbo].[Pharma_data$]
group by [Product Class] order by total_sales_in_Billions desc;

------Validation
select  count(distinct [Product Class]) from [dbo].[Pharma_data$];

--17. Find the top 5 customers with the highest sales for each year.
WITH CTE_Sales AS (
   SELECT  [Customer Name], [Year], cast(round(SUM([Sales]/1000000),2) as varchar(max)) + ' M' AS TotalSales_in_Millions,
      ROW_NUMBER() OVER (PARTITION BY [Year] ORDER BY SUM([Sales]) DESC) AS rn
   FROM [dbo].[Pharma_data$]
   GROUP BY [Year], [Customer Name]
)
SELECT [Customer Name], [Year], TotalSales_in_Millions, rn
FROM CTE_Sales
WHERE rn <= 5
ORDER BY [Year], TotalSales_in_Millions DESC;

--18. Calculate the year-over-year growth in sales for each country.
WITH CTE AS
(SELECT [Year], SUM([Sales]) AS TotalSales,
    LAG(SUM([Sales])) OVER (ORDER BY [Year]) AS PrevYearTotalSales
  FROM [dbo].[Pharma_data$] GROUP BY [Year])
SELECT [Year], TotalSales,
  CONCAT(ROUND(((TotalSales - PrevYearTotalSales) / PrevYearTotalSales) * 100 , 2),'%') AS YoYGrowth
FROM CTE;

--19. List the months with the lowest sales for each year
WITH CTE_Month_Sales AS
(SELECT [Month], [Year], CAST(ROUND(SUM([Sales])/1000000, 2) AS VARCHAR(MAX)) + ' M' AS TotalSales_in_M,
    ROW_NUMBER() OVER (PARTITION BY [Year] ORDER BY SUM([Sales]) asc) AS rn
  FROM [dbo].[Pharma_data$] GROUP BY [Year],[Month])
SELECT [Year], [Month], TotalSales_in_M  FROM CTE_Month_Sales WHERE rn = 1
ORDER BY [Year] ASC, TotalSales_in_M ASC;

-------Validation :
select YEAR([month_date]), month([month_date]), SUM([Sales]) from [dbo].[Pharma_data$]
group by  YEAR([month_date]), month([month_date])
order by YEAR([month_date]) , month([month_date])

--20. Calculate the total sales for each sub-channel in each country, 
--and then find the country with the highest total sales for each sub-channel.

----------- 1st step :
SELECT c.[Country], sc.[Sub-channel], 
  cast(round(SUM(CASE WHEN p.[Country] = c.[Country] AND p.[Sub-channel] = sc.[Sub-channel] 
           THEN p.[Sales] ELSE 0 END) / 1000000000 , 3) as varchar(max)) + ' B' AS TotalSalesInBillions
FROM (SELECT DISTINCT [Country] FROM [dbo].[Pharma_data$]) c,
     (SELECT DISTINCT [Sub-channel] FROM [dbo].[Pharma_data$]) sc,
	 [dbo].[Pharma_data$] p
GROUP BY c.[Country], sc.[Sub-channel]  order by c.[Country];

------------ 2nd step :
WITH CTE AS
(SELECT [Sub-Channel],[Country],cast(round(SUM([Sales])/1000000000, 2) as varchar(max)) + ' B' AS TotalSalesInBillions, 
     ROW_NUMBER() OVER (PARTITION BY [Sub-Channel] ORDER BY SUM([Sales]) DESC) AS RN
   FROM [dbo].[Pharma_data$] GROUP BY [Sub-Channel], [Country])
SELECT [Sub-Channel], [Country],TotalSalesInBillions FROM CTE WHERE RN = 1;


