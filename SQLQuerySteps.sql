-- 1. Define a SQL table to store information about space missions.
USE [space_missions]
GO

/****** Object:  Table [dbo].[space_missions]    Script Date: 5/15/2024 9:44:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[space_missions](
	[Company] [varchar](50) NULL,
	[Location] [varchar](1000) NULL,
	[Date] [varchar](50) NULL,
	[Time] [varchar](50) NULL,
	[Rocket] [varchar](50) NULL,
	[Mission] [varchar](1000) NULL,
	[RocketStatus] [varchar](50) NULL,
	[Price] [varchar](50) NULL,
	[MissionStatus] [varchar](50) NULL
) ON [PRIMARY]
GO

Alter table [dbo].[space_missions]
alter column [Location] varchar(max);

alter table [dbo].[space_missions]
alter column [Mission] varchar(max);

-- The new script for the table is 

USE [space_missions]
GO

/****** Object:  Table [dbo].[space_missions]    Script Date: 5/15/2024 9:53:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[space_missions](
	[Company] [varchar](50) NULL,
	[Location] [varchar](max) NULL,
	[Date] [varchar](50) NULL,
	[Time] [varchar](50) NULL,
	[Rocket] [varchar](50) NULL,
	[Mission] [varchar](max) NULL,
	[RocketStatus] [varchar](50) NULL,
	[Price] [varchar](50) NULL,
	[MissionStatus] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


-- 2. Add records for at least three space missions conducted by different companies.

insert into [dbo].[space_missions] ([Company], [Date], [Rocket], [Mission], [RocketStatus], [Price], [MissionStatus])
values ('Kassam', '12-10-2022', 'Yassin 105', 'Gaza North', 'Active', 120000,  'Success'),
	   ('Hamas', '07-10-2023', 'Yassin 105', 'Tel aviv', 'Active', 70000, 'Success'),
	   ('Abo Ali', ' 01-01-2024', 'Shawaz', 'Gebalia', 'Active', 70000, 'Success');

-- Validation step
select * from [dbo].[space_missions] where Rocket = 'Yassin 105' or  Rocket = 'Shawaz';


-- 3. Retrieve the names of all rockets used in space missions.
select distinct [Rocket] from [dbo].[space_missions]
order by [Rocket] ;


-- 4. Display the details of space missions launched by a specific company.
select * from [dbo].[space_missions]
order by [Company];

-- aonther logic 
select [Company], count(*) as company_missions from [dbo].[space_missions]
group by [Company] order by company_missions desc ;


-- 5. Retrieve the top 5 most expensive rockets based on their cost.
select top 5 [Rocket], [Price] as cost from [dbo].[space_missions]
order by cost desc;

-- since the cost is same, ther is a probapility to have more equal rockets price
select top 5 with ties [Rocket], [Price] as cost from [dbo].[space_missions]
order by cost desc;


--6. Calculate the average cost of all rockets.
SELECT AVG(TRY_CONVERT(DECIMAL(10,2), [Price])) AS average_price
FROM [dbo].[space_missions]
WHERE TRY_CONVERT(DECIMAL(10,2), [Price]) IS NOT NULL;


-- 7. Group the missions by launch location and display the total count of missions for each location.
select [Location], count([Mission]) as missions_count from [dbo].[space_missions]
group by [Location] order by missions_count desc;



-- 8. Create a new table for rocket details and join it with the main table to display mission names and their corresponding rocket names.
create table Rocket_details (
	Rocket varchar(50) null,
	RocketStatus varchar(50) null
);

INSERT INTO [dbo].[Rocket_details] (Rocket, RocketStatus)
SELECT distinct [Rocket], [RocketStatus]
FROM [dbo].[space_missions];

select   m.[Mission], r.[Rocket] 
from [dbo].[space_missions] m  join [dbo].[Rocket_details] r on r.Rocket = m.Rocket;


-- 9. Find the company that conducted the most expensive mission.
select top 1 [Company],[Price] from [dbo].[space_missions]
order by [Price] desc;

-- With ties 
select distinct top 1 with ties [Company],[Price] from [dbo].[space_missions]
order by [Price] desc;


-- 10. Calculate the total cost of successful missions.
SELECT sum(TRY_CONVERT(DECIMAL(10,2), [Price])) AS Successful_missions_cost
FROM [dbo].[space_missions]
WHERE TRY_CONVERT(DECIMAL(10,2), [Price]) IS NOT NULL and [MissionStatus] = 'Success';


-- 11. Change the status of rockets to 'Inactive' for those whose mission status is 'Prelaunch Failure'.
update [dbo].[space_missions]
	set [RocketStatus] = 'Inactive'
where  [MissionStatus] = 'Prelaunch Failure';

-- Validation step 

select * from [dbo].[space_missions] where [MissionStatus] = 'Prelaunch Failure';


-- 12. Add a new record for a space mission with necessary details.
insert into [dbo].[space_missions] ([Company],[Rocket],[Price], [MissionStatus])
values ('ALkassam', 'Yassin 105', '5', 'Success');

-- Validation step
select * from [dbo].[space_missions] where price = '5';


-- 13. Remove all records where the mission status is 'Failure'.
delete from [dbo].[space_missions] where [MissionStatus] = 'Failure';


-- 14. Create a new column 'Mission_Result' that categorizes missions as
--    'Successful', 'Partial Success', or 'Failed' based on their mission status.

select distinct  [MissionStatus] from [dbo].[space_missions]

select [Company], [Rocket], [Mission], [MissionStatus], 
case 
	when [MissionStatus] = 'Success' then 'Successful'
	when [MissionStatus] = 'Partial Failure' then 'Partial Success'
	when [MissionStatus] = 'Prelaunch Failure' then 'Failed'
	end as Uodated_mission_status
from [dbo].[space_missions];


-- 15. Rank the missions based on their launch date within each company.
select [Mission],[Date], [Company],
rank() over(partition by [Company] order by[Date] ) as Mission_rank
from [dbo].[space_missions];

-- anither query using densrank()
select [Mission],[Date], [Company],
dense_rank() over(partition by [Company] order by[Date] ) as Mission_rank
from [dbo].[space_missions];


-- 16. Calculate the running total of the number of missions conducted by each company.
select [Company], count([Mission]) as missions_count from [dbo].[space_missions]
group by [Company] order by missions_count desc;


-- 17. Create a CTE that lists companies along with the count of their successful missions.
with Successful_companies as (
	select [Company], count([MissionStatus]) as success_count from [dbo].[space_missions]
	where [MissionStatus] = 'Success'   group by [Company] 
)
select * from Successful_companies order by success_count desc;


-- 18. Pivot the data to show the total count of missions for each company and their mission statuses.
select [Company], [MissionStatus], count([Mission]) as Mission_count from [dbo].[space_missions]
group by [Company],[MissionStatus] order by[Company] ;


-- using pivot function
select * from(
	select [Company], [MissionStatus], count(*) AS mission_count, sum(count(*)) OVER (PARTITION BY [Company]) AS total_missions
	from [dbo].[space_missions]
    group by [Company], [MissionStatus]
) as source_data
pivot(
    sum(mission_count)
    for [MissionStatus] IN (Success, Failure, "Partial Failure")
) AS pivot_table order by total_missions desc;


-- 19. Unpivot the table to transform the 'Mission_Result' column into a single column named 'Result'.

select [Company], Result FROM (
    select [Company], [MissionStatus] from [dbo].[space_missions]
) as source_data
unpivot(
    Result
    for num in ([MissionStatus])
) as unpivot_table order by[Company]  ;


-- 20. Create a stored procedure that accepts a location as input and returns the total count of missions launched from that location
create procedure GetLocationCount
	@location varchar(max)
as
begin
	select @location as location_, count([Location]) as location_count from [dbo].[space_missions]
	where [Location] = @location
end;

-- To execute the stored procedure

exec GetLocationCount @location = 'LC-18A, Cape Canaveral AFS, Florida, USA';

----Thank  you ---