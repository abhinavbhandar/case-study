create database CaseStudy;
use casestudy;
show databases;

select * from salaries;

/* 1- You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries
who give work fully remotely, for the title 'managers’ Paying salaries Exceeding $90,000 USD
*/
select distinct company_location
from salaries
where remote_ratio = 100 and job_title like '%Manager%' and salary_in_usd > 90000;

/* 2- AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms.
You're tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies.
*/
select company_location, count(company_location) as total_company
from salaries
where company_size = 'L' and experience_level = 'EN'
group by company_location
order by count(company_location) desc limit 5;

/* 3- Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate 
the percentage of employees. Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the
 attractiveness of high-paying remote positions IN today's job market.
*/
set @total = (select count(*) from salaries where salary_in_usd > 100000);
set @remote = (select count(*) from salaries where remote_ratio = 100 and salary_in_usd > 100000);

set @percentage = ((select @remote)/(select @total)*100);
select @percentage as percentage;

/* 4- Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations
 where entry-level average salaries exceed the average salary for that job title IN market for entry level, 
 helping your agency guide candidates towards lucrative opportunities.
*/
select a.company_location, a.job_title, t.average, a.entry_average
from
(select job_title, avg(salary_in_usd) as average from salaries group by job_title) t
inner join
(select company_location, job_title, avg(salary_in_usd) as entry_average from salaries where experience_level = 'EN' group by job_title, company_location) a
on t.job_title = a.job_title
where t.average < a.entry_average;

/* 5- You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. 
Your job is to Find out for each job title which. Country pays the maximum average salary. 
This helps you to place your candidates IN those countries.
*/
with avg_salary as(
select company_location, job_title, avg(salary_in_usd) as average_salary from salaries group by company_location, job_title
)

select company_location, job_title, average_salary
from avg_salary b
where average_salary like (select max(average_salary) from avg_salary a where a.job_title = b.job_title);

with avg_salary as(
select company_location, job_title, avg(salary_in_usd) as average_salary from salaries group by company_location, job_title
)

select company_location, job_title, average_salary from(
select *, Dense_Rank() over(partition by job_title order by average_salary desc) as highest
from avg_salary) t
where highest = 1;

/* 6- AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends
 across different company Locations. Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased
 over the Past few years (Countries WHERE data is available for 3 years Only(present year and past two years) providing 
 Insights into Locations experiencing Sustained salary growth.
*/
select * from
(
select company_location, 
max(case when work_year = year(current_date())-3 then averages end) as Avg_2022,
max(case when work_year = year(current_date())-2 then averages end) as Avg_2023,
max(case when work_year = year(current_date())-1 then averages end) as Avg_2024
from (
select company_location, work_year, avg(salary_in_usd) as averages from salaries
group by work_year, company_location
) t
group by company_location
) u where Avg_2024 > Avg_2023 and Avg_2023 > Avg_2022;

-- or

WITH t AS
(
 SELECT * FROM  salaries WHERE company_locatiON IN
		(
			SELECT company_locatiON FROM
			(
				SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 3
				GROUP BY  company_locatiON HAVING  num_years = 3 
			)m
		)
)  -- step 4
-- SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
SELECT 
    company_locatiON,
    MAX(CASE WHEN work_year = 2022 THEN  average END) AS AVG_salary_2022,
    MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
    MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM 
(
SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
)q GROUP BY company_locatiON  havINg AVG_salary_2024 > AVG_salary_2023 AND AVG_salary_2023 > AVG_salary_2022; -- step 3 and havINg step 4.



/* 7-  Picture yourself AS a workforce strategist employed by a global HR tech startup. Your Mission is to Determine the
 percentage of fully remote work for each experience level IN 2021 and compare it WITH the corresponding figures for 2024, 
 Highlighting any significant Increases or decreases IN remote work Adoption over the years.
*/
-- 2021
with past as(
select p.experience_level, p.work_year, round((remote_worker/total_worker)*100,2) as past_percentage
from
(SELECT experience_level, work_year, count(remote_ratio) as remote_worker from salaries where remote_ratio = 100 and work_year = 2021 group by experience_level) p
inner join
(select experience_level, work_year, count(remote_ratio) as total_worker from salaries where work_year = 2021 group by experience_level) q
on p.experience_level = q.experience_level
),
-- 2024
present as(
select a.experience_level, a.work_year, round((remote_worker/total_worker)*100,2) as present_percentage
from
(SELECT experience_level, work_year, count(remote_ratio) as remote_worker from salaries where remote_ratio = 100 and work_year = 2024 group by experience_level) a
inner join
(select experience_level, work_year, count(remote_ratio) as total_worker from salaries where work_year = 2024 group by experience_level) b
on a.experience_level = b.experience_level
)
-- comparision
select p1.experience_level,p1.past_percentage, p2.present_percentage
from past p1
inner join
present p2
on p1.experience_level = p2.experience_level;

/* 8- AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary trends over time. 
Your objective is to calculate the average salary increase percentage for each experience level and 
job title between the years 2023 and 2024, helping the company stay competitive IN the talent market.
*/

WITH t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY experience_level, job_title, work_year
)

SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
	SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
	FROM t GROUP BY experience_level , job_title
)a WHERE (((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100) IS NOT NULL;

/* 9- You're a database administrator tasked with role-based access control for a company's employee database. 
Your goal is to implement a security measure where employees in different experience level (e.g. Entry Level, Senior level etc.) 
can only access details relevant to their respective experience level, ensuring data confidentiality and minimizing the risk of unauthorized access.
*/
-- grant and revoke
show privileges

-- entry level
create user 'ENTRY_LEVEL'@'%' identified by 'first'
create view select_only as
(
	select * from salaries where experience_level = 'EN'
)
GRANT select, insert on casestudy.select_only to 'ENTRY_LEVEL'@'%'

-- senior level
create user 'SENIOR_LEVEL'@'%' identified by 'second'
create view select_only_senior as
(
	select * from salaries where experience_level = 'SE'
)
GRANT select, insert on casestudy.select_only_senior to 'SENIOR_LEVEL'@'%'


/* 10- You are working with a consultancy firm, your client comes to you with certain data and preferences such as 
(their year of experience , their employment type, company location and company size )  and want to make an transaction 
into different domain in data industry (like  a person is working as a data analyst and want to move to some other domain 
such as data science or data engineering etc.) your work is to  guide them to which domain they should switch to base on  
the input they provided, so that they can now update their knowledge as  per the suggestion/.. The Suggestion should be based on average salary.
*/

DELIMITER //
CREATE PROCEDURE domain(in exp_level varchar(2), in comp_location varchar(2), in comp_size varchar(1), in emp_type varchar(2))
begin
	select job_title, experience_level, company_location, company_size, employment_type, avg(salary_in_usd) as avg_salary
	from salaries
    where experience_level = exp_level and company_location = comp_location and company_size = comp_size and employment_type= emp_type
    group by job_title, experience_level, company_location, company_size, employment_type;
END //
DELIMITER ;

call domain('EN', 'AU', 'M', 'FT');


drop procedure domain;