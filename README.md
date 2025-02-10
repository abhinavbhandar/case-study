# SQL Case Study - Salary Analysis

## Introduction
This SQL case study aims to analyze salary trends, remote work adoption, and workforce distribution based on different factors such as job title, experience level, company location, and employment type. The queries address real-world scenarios faced by HR consultants, workforce strategists, and business analysts in understanding salary distributions and job market trends.

## Database Setup
```sql
CREATE DATABASE CaseStudy;
USE CaseStudy;
SHOW DATABASES;
```

## Dataset Used
The dataset `salaries` contains details such as:
- `company_location`
- `remote_ratio`
- `job_title`
- `salary_in_usd`
- `company_size`
- `experience_level`
- `work_year`
- `employment_type`

---

## SQL Queries and Business Use Cases

### 1. Finding Top 5 Countries with the Highest Number of Large Tech Firms Hiring Freshers
**Objective:** Assist an HR startup in identifying top markets for entry-level hiring in large companies.
```sql
SELECT company_location, COUNT(company_location) AS total_company
FROM salaries
WHERE company_size = 'L' AND experience_level = 'EN'
GROUP BY company_location
ORDER BY total_company DESC
LIMIT 5;
```
| company_location | total_company |
|:----------:|:----------:|
|US|	53|
|DE|	10|
|CA|	10|
|GB|	8|
|IN|	6|


### 2. Identifying Fully Remote Managerial Roles with High Salaries
**Objective:** Identify countries offering fully remote managerial roles with salaries exceeding $90,000.
```sql
SELECT DISTINCT company_location
FROM salaries
WHERE remote_ratio = 100 AND job_title LIKE '%Manager%' AND salary_in_usd > 90000;
```
| company_location |
|:----------:|
|US|
|MX|
|AU|
|FR|


### 3. Calculating Percentage of High-Paying Remote Roles
**Objective:** Determine what percentage of employees earn more than $100,000 in fully remote roles.
```sql
SELECT ROUND((COUNT(CASE WHEN remote_ratio = 100 AND salary_in_usd > 100000 THEN 1 END) * 100.0) / COUNT(*), 2) AS percentage
FROM salaries;
```

### 4. Identifying Countries with High Entry-Level Salaries
**Objective:** Guide job seekers by identifying locations where entry-level salaries exceed market averages.
```sql
SELECT a.company_location, a.job_title, t.average, a.entry_average
FROM
(SELECT job_title, AVG(salary_in_usd) AS average FROM salaries GROUP BY job_title) t
INNER JOIN
(SELECT company_location, job_title, AVG(salary_in_usd) AS entry_average FROM salaries WHERE experience_level = 'EN' GROUP BY job_title, company_location) a
ON t.job_title = a.job_title
WHERE t.average < a.entry_average;
```

### 5. Finding Countries That Pay the Highest Salaries for Each Job Title
**Objective:** Identify the country offering the highest average salary for each job title.
```sql
WITH avg_salary AS (
  SELECT company_location, job_title, AVG(salary_in_usd) AS average_salary 
  FROM salaries 
  GROUP BY company_location, job_title
)
SELECT company_location, job_title, average_salary
FROM avg_salary b
WHERE average_salary = (SELECT MAX(average_salary) FROM avg_salary a WHERE a.job_title = b.job_title);
```

### 6. Identifying Countries with Sustained Salary Growth Over Three Years
**Objective:** Find locations experiencing consistent salary growth over the past three years.
```sql
SELECT company_location
FROM (
  SELECT company_location, 
    MAX(CASE WHEN work_year = 2022 THEN avg_salary END) AS Avg_2022,
    MAX(CASE WHEN work_year = 2023 THEN avg_salary END) AS Avg_2023,
    MAX(CASE WHEN work_year = 2024 THEN avg_salary END) AS Avg_2024
  FROM (
    SELECT company_location, work_year, AVG(salary_in_usd) AS avg_salary FROM salaries GROUP BY work_year, company_location
  ) t
  GROUP BY company_location
) u 
WHERE Avg_2024 > Avg_2023 AND Avg_2023 > Avg_2022;
```

### 7. Analyzing Salary Growth for Job Titles by Experience Level
**Objective:** Determine the percentage increase in average salary between 2023 and 2024.
```sql
WITH salary_growth AS (
  SELECT experience_level, job_title, work_year, ROUND(AVG(salary_in_usd), 2) AS avg_salary
  FROM salaries 
  WHERE work_year IN (2023, 2024) 
  GROUP BY experience_level, job_title, work_year
)
SELECT experience_level, job_title, 
  MAX(CASE WHEN work_year = 2023 THEN avg_salary END) AS AVG_salary_2023,
  MAX(CASE WHEN work_year = 2024 THEN avg_salary END) AS AVG_salary_2024,
  ROUND(((AVG_salary_2024 - AVG_salary_2023) / AVG_salary_2023) * 100, 2) AS percentage_change
FROM salary_growth
GROUP BY experience_level, job_title;
```

### 8. Analyzing Remote Work Trends Over Time
**Objective:** Compare the percentage of remote work by experience level in 2021 and 2024.
```sql
WITH remote_trend AS (
  SELECT experience_level, work_year, 
    ROUND((COUNT(CASE WHEN remote_ratio = 100 THEN 1 END) * 100.0) / COUNT(*), 2) AS remote_percentage
  FROM salaries 
  WHERE work_year IN (2021, 2024)
  GROUP BY experience_level, work_year
)
SELECT * FROM remote_trend;
```

### 9. Implementing Role-Based Access Control for Employee Data
**Objective:** Ensure employees can access only relevant salary data based on experience level.
```sql
CREATE USER 'ENTRY_LEVEL'@'%' IDENTIFIED BY 'first';
CREATE VIEW select_only AS 
  SELECT * FROM salaries WHERE experience_level = 'EN';
GRANT SELECT, INSERT ON CaseStudy.select_only TO 'ENTRY_LEVEL'@'%';
```

### 10. Career Transition Recommendations Based on Salary Trends
**Objective:** Help professionals transition to higher-paying roles based on provided criteria.
```sql
DELIMITER //
CREATE PROCEDURE domain(IN exp_level VARCHAR(2), IN comp_location VARCHAR(2), IN comp_size VARCHAR(1), IN emp_type VARCHAR(2))
BEGIN
  SELECT job_title, experience_level, company_location, company_size, employment_type, AVG(salary_in_usd) AS avg_salary
  FROM salaries
  WHERE experience_level = exp_level AND company_location = comp_location AND company_size = comp_size AND employment_type = emp_type
  GROUP BY job_title, experience_level, company_location, company_size, employment_type;
END //
DELIMITER ;

CALL domain('EN', 'AU', 'M', 'FT');
```

---

## Conclusion
This case study demonstrates the power of SQL in workforce and salary analytics. The queries provide actionable insights for HR professionals, data analysts, and workforce strategists in making informed business decisions.

