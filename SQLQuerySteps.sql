-- 1. Retrieve the Patient_id and ages of all patients.
select [Patient_id], [age]
from [dbo].[Dataset$];

-- 2. Select all female patients who are older than 40.
select * from [dbo].[Dataset$]
where [gender] = 'Female' and [age] > 40
order by [age];

-- 3. Calculate the average BMI of patients.
select round(AVG([bmi]), 2) as Average_BMI 
from [dbo].[Dataset$];

-- 4. List patients in descending order of blood glucose levels.
select [Patient_id], [blood_glucose_level] from [dbo].[Dataset$]
order by [blood_glucose_level] desc;

-- 5. Find patients who have hypertension and diabetes.
select [Patient_id], [hypertension], [diabetes] from [dbo].[Dataset$]
where [hypertension] = 1 and [diabetes] = 1;

-- 6. Determine the number of patients with heart disease.
select count(*) as Heart_Disease_Count from [dbo].[Dataset$]
where [heart_disease] = 1;

-- 7. Group patients by smoking history and count how many smokers and non-smokers there are.
select [smoking_history], count(*) from [dbo].[Dataset$]
group by [smoking_history];

-- another way for grouping
select 
(case
	when [smoking_history] = 'current' then 'smoker'
	when [smoking_history] = 'not current' then 'not-smoker'
	when [smoking_history] = 'former' then 'smoker'
	when [smoking_history] = 'ever' then 'smoker'
	when [smoking_history] = 'No Info' then 'No Info'
	when [smoking_history] = 'never' then 'not-smoker'
	end )as smokers_rule , 
	count(*) as smokers_count

from [dbo].[Dataset$]
group by (case
	when [smoking_history] = 'current' then 'smoker'
	when [smoking_history] = 'not current' then 'not-smoker'
	when [smoking_history] = 'former' then 'smoker'
	when [smoking_history] = 'ever' then 'smoker'
	when [smoking_history] = 'No Info' then 'No Info'
	when [smoking_history] = 'never' then 'not-smoker'
	end )
order by smokers_rule desc;

-- 8. Retrieve the Patient_ids of patients who have a BMI greater than the average BMI.
select [Patient_id], [bmi] , (select round(avg([bmi]), 2) as Average_BMI from [dbo].[Dataset$]) as bmi_avergae 
from [dbo].[Dataset$]
where [bmi] > (select AVG([bmi]) from [dbo].[Dataset$]);

-- Another way using cte and cross join

WITH cte_avg_bmi AS (
    SELECT AVG([bmi]) AS bmi_average
    FROM [dbo].[Dataset$]
)
SELECT d.[Patient_id], d.[bmi], c.bmi_average
FROM [dbo].[Dataset$] AS d
CROSS JOIN cte_avg_bmi AS c
WHERE d.[bmi] > c.bmi_average;

-- 9. Find the patient with the highest HbA1c level and the patient with the lowest HbA1clevel.
with max_hba1c as(
	select max([HbA1c_level]) as hbaic_max
	from [dbo].[Dataset$]
)
select p.[Patient_id], m.hbaic_max
from [dbo].[Dataset$] p  inner join (select hbaic_max from max_hba1c) m
on p.[HbA1c_level] = m.hbaic_max;

-- Validation query for number of max HBA1C patirnts count
select count(*) from [dbo].[Dataset$]
where [HbA1c_level] = (select max([HbA1c_level]) from [dbo].[Dataset$]);

-- 10. Calculate the age of patients in years (assuming the current date as of now).
-- As I already have the age column , I will calculate the DOP of each patient 
select [Patient_id], [age], DATEADD(YEAR, -[age], GETDATE()) AS date_of_birth
from [dbo].[Dataset$];

-- Another query to retieve the year of birth 
select [Patient_id],[age], CAST(DATEPART(YEAR, DATEADD(YEAR, -[age], GETDATE())) AS VARCHAR(4)) AS date_of_birth
FROM [dbo].[Dataset$];

-- 11. Rank patients by blood glucose level within each gender group.
select Patient_id, gender, blood_glucose_level,
    rank() over (PARTITION BY gender ORDER BY blood_glucose_level DESC) AS glucose_rank
from [dbo].[Dataset$]
order by  gender, glucose_rank;

-- another way using dense_rank function.
select Patient_id, gender, blood_glucose_level,
    dense_rank() over (PARTITION BY gender ORDER BY blood_glucose_level DESC) AS glucose_rank
from [dbo].[Dataset$]
order by  gender, glucose_rank;

-- 12. Update the smoking history of patients who are older than 50 to "Ex-smoker."
update [dbo].[Dataset$]
	set [smoking_history] = 'Ex-smoker'
where [age] > 50;

-- validation step 
select [Patient_id],[smoking_history] from [dbo].[Dataset$]
where [age] > 50;

-- 13. Insert a new patient into the database with sample data.
insert into [dbo].[Dataset$]([Patient_id], [gender], [age], [bmi])
values ('PT301', 'Male', 68, 31.82);

-- 14. Delete all patients with heart disease from the database.
delete from [dbo].[Dataset$]
where [heart_disease] = 1


-- Validation step
select * from [dbo].[Dataset$] where [heart_disease] = 1;

-- 15. Find patients who have hypertension but not diabetes using the EXCEPT operator.
select * from [dbo].[Dataset$] where [hypertension] = 1
except
select * from [dbo].[Dataset$] where [diabetes] =1 ;

-- 16. Define a unique constraint on the "patient_id" column to ensure its values are unique.
alter table [dbo].[Dataset$]
add constraint unique_patirnt_id unique ([Patient_id]);

-- delete the dublicate 
with duplicates as(
	select [Patient_id],
	ROW_NUMBER() over(partition by [Patient_id] order by (select null))as row_num
	from [dbo].[Dataset$]
)
delete from duplicates where row_num >1;
-- after this step, you can deploy the constraint successfully 

-- 17. Create a view that displays the Patient_ids, ages, and BMI of patients.
create view age_bmi as
select [Patient_id], [age], [bmi] from [dbo].[Dataset$];

-- validation step 
select * from age_bmi;

-- 18. Suggest improvements in the database schema to reduce data redundancy and improve data integrity.
-------- 1. Create unique constaraint for patient ID (Prefrerred to be primary key constraint)
-------- 2. Create check 'input' constraint for these columns ([EmployeeName], [gender], [hypertension],[heart_disease], [smoking_history],[diabetes])

-- 19. Explain how you can optimize the performance of SQL queries on this dataset.
-------- 1.Indexing
-------- 2.Partitioning
-------- 3.Using CTE and Temptables instead of nested queries
-------- 4.Using selected dcolumns instead of * 
-------- 5.Using crossjoin instead of innerjoin if possible


-- Thank You 









