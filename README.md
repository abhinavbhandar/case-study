# SQL Case Study: Compensation and Workforce Analysis

## Introduction
This SQL case study involves analyzing salary trends and workforce dynamics using a multinational corporation's employee salary dataset. The study focuses on key business scenarios relevant to compensation analysts, HR professionals, data scientists, and workforce strategists.

## Dataset Description
The dataset contains information on:
- **Work Year**: The year of the salary record
- **Experience Level**: Entry (EN), Mid-Level (MI), Senior (SE), Executive (EX)
- **Employment Type**: Full-time (FT), Contract (CT), Freelance (FL), Part-time (PT)
- **Job Title**: Title of the job role
- **Salary in USD**: Annual salary in USD
- **Remote Ratio**: 0% (On-site), 50% (Hybrid), 100% (Fully Remote)
- **Company Location**: Country where the company is based
- **Company Size**: Small (S), Medium (M), Large (L)

## Objectives
1. Identify countries offering fully remote work for high-salary managers.
2. Find the top 5 countries with large companies hiring freshers.
3. Calculate the percentage of fully remote employees earning above $100,000.
4. Identify locations where entry-level salaries exceed market averages.
5. Determine the country with the highest average salary for each job title.
6. Analyze salary growth trends over the last 3 years.
7. Measure the change in remote work adoption from 2021 to 2024.
8. Compute the average salary increase percentage from 2023 to 2024.
9. Implement role-based access control for employee salary data.
10. Recommend career transitions based on salary trends.

## SQL Queries and Implementation

### 1. Fully Remote Work for High-Salary Managers
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

### 2. Top 5 Countries with Large Companies Hiring Freshers
```sql
SELECT company_location, COUNT(*) AS total_company
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

### 3. Percentage of Fully Remote Employees Earning Above $100,000
```sql
SET @total = (SELECT COUNT(*) FROM salaries WHERE salary_in_usd > 100000);
SET @remote = (SELECT COUNT(*) FROM salaries WHERE remote_ratio = 100 AND salary_in_usd > 100000);
SELECT round((@remote / @total) * 100,2) AS percentage;
```

|percentage|
|:-----:|
|32.23|

### 4. Locations Where Entry-Level Salaries Exceed Market Averages
```sql
SELECT a.company_location, a.job_title, t.average, a.entry_average
FROM (
  SELECT job_title, AVG(salary_in_usd) AS average FROM salaries GROUP BY job_title
) t
INNER JOIN (
  SELECT company_location, job_title, AVG(salary_in_usd) AS entry_average
  FROM salaries
  WHERE experience_level = 'EN'
  GROUP BY job_title, company_location
) a ON t.job_title = a.job_title
WHERE t.average < a.entry_average;
```

| Company Location | Job Title                               | Average Salary | Entry Average Salary |
|-----------------|-------------------------------------|----------------|---------------------|
| AU              | Computer Vision Software Engineer  | 77,760.60      | 150,000.00         |
| CA              | Machine Learning Research Engineer | 66,157.00      | 80,769.00          |
| CA              | AI Programmer                      | 62,042.00      | 74,087.00          |
| CA              | AI Scientist                       | 120,578.88     | 200,000.00         |
| CA              | Data Integration Specialist       | 85,268.87      | 100,000.00         |
| DE              | Machine Learning Research Engineer | 66,157.00      | 66,192.00          |
| DE              | AI Developer                       | 135,466.79     | 140,358.50         |
| GB              | Applied Data Scientist            | 102,587.92     | 110,037.00         |
| GB              | Cloud Data Engineer               | 131,617.75     | 177,177.00         |
| IQ              | Machine Learning Developer        | 72,703.50      | 100,000.00         |
| MX              | Data Analyst                      | 108,641.91     | 429,950.00         |
| SE              | Big Data Engineer                 | 69,764.18      | 130,000.00         |
| US              | Data Specialist                   | 91,327.03      | 105,000.00         |
| US              | Big Data Engineer                 | 69,764.18      | 70,000.00          |
| US              | Data Operations Associate         | 61,399.00      | 61,687.50          |
| US              | Data Integration Specialist       | 85,268.87      | 94,341.67          |
| US              | Business Data Analyst             | 73,567.76      | 74,000.00          |
| US              | Business Intelligence Data Analyst | 83,209.50      | 99,000.00          |
| US              | Compliance Data Analyst           | 45,000.00      | 60,000.00          |
| US              | Product Data Analyst              | 69,436.17      | 91,600.00          |
| US              | Machine Learning Developer        | 72,703.50      | 180,000.00         |

### 5. Country with Maximum Average Salary for Each Job Title
```sql
WITH avg_salary AS (
  SELECT company_location, job_title, AVG(salary_in_usd) AS avg_salary
  FROM salaries
  GROUP BY company_location, job_title
)
SELECT company_location, job_title, avg_salary
FROM avg_salary b
WHERE avg_salary = (
  SELECT MAX(avg_salary) FROM avg_salary a WHERE a.job_title = b.job_title
);
```

| Company Location | Job Title                              | Average Salary |
|-----------------|--------------------------------------|---------------|
| IN             | Admin & Data Analyst                 | 60000.0000    |
| CA             | AI Architect                         | 800000.0000   |
| CA             | AI Developer                         | 275000.0000   |
| QA             | AI Engineer                          | 300000.0000   |
| US             | AI Product Manager                   | 152650.0000   |
| FR             | AI Programmer                        | 120000.0000   |
| US             | AI Research Engineer                 | 175000.0000   |
| DE             | AI Research Scientist                | 88888.0000    |
| IL             | AI Scientist                         | 417937.0000   |
| EG             | AI Software Engineer                 | 174100.0000   |
| FR             | Analytics Engineer                   | 188000.0000   |
| GB             | Analytics Engineering Manager        | 399880.0000   |
| US             | Applied Data Scientist               | 238000.0000   |
| US             | Applied Machine Learning Engineer    | 177500.0000   |
| US             | Applied Machine Learning Scientist   | 141550.0000   |
| US             | Applied Scientist                    | 191002.3525   |
| GB             | Autonomous Vehicle Technician        | 120000.0000   |
| US             | AWS Data Architect                   | 258000.0000   |
| MU             | Azure Data Engineer                  | 100000.0000   |
| NL             | Azure Data Engineer                  | 100000.0000   |
| NG             | BI Analyst                           | 200000.0000   |
| FR             | BI Data Analyst                      | 105066.0000   |
| US             | BI Data Engineer                     | 60000.0000    |
| JP             | BI Developer                         | 160000.0000   |
| GB             | Big Data Architect                   | 153799.0000   |
| US             | Big Data Developer                   | 117000.0000   |
| CA             | Big Data Engineer                    | 161311.0000   |
| US             | Business Data Analyst                | 98000.0000    |
| US             | Business Intelligence                | 141002.3750   |
| US             | Business Intelligence Analyst        | 119235.9043   |
| US             | Business Intelligence Data Analyst   | 99000.0000    |
| CA             | Business Intelligence Developer      | 108250.0000   |
| US             | Business Intelligence Engineer       | 145774.8641   |
| US             | Business Intelligence Lead           | 143525.0000   |
| US             | Business Intelligence Manager        | 143925.0000   |
| US             | Business Intelligence Specialist     | 144153.0000   |
| US             | Cloud Data Architect                 | 250000.0000   |
| GB             | Cloud Data Engineer                  | 177177.0000   |
| US             | Cloud Database Engineer              | 149696.4286   |
| US             | Compliance Data Analyst              | 60000.0000    |
| US             | Computer Vision Engineer             | 205278.2609   |
| AU             | Computer Vision Software Engineer    | 150000.0000   |
| CA             | Consultant Data Engineer             | 118539.0000   |
| MX             | Data Analyst                         | 429950.0000   |
| NZ             | Data Analyst Lead                    | 125000.0000   |
| US             | Data Analytics Consultant            | 86690.6250    |
| US             | Data Analytics Engineer              | 122500.0000   |
| US             | Data Analytics Lead                  | 221548.0000   |
| US             | Data Analytics Manager               | 139460.3469   |
| US             | Data Analytics Specialist            | 111647.2500   |
| US             | Data Architect                       | 166972.9709   |
| US             | Data Developer                       | 101371.4500   |
| DE             | Data DevOps Engineer                 | 95012.0000    |
| PR             | Data Engineer                        | 167500.0000   |
| US             | Data Infrastructure Engineer         | 207332.8125   |
| US             | Data Integration Developer           | 140580.7500   |
| US             | Data Integration Engineer            | 131246.2857   |
| CA             | Data Integration Specialist          | 100000.0000   |
| US             | Data Lead                            | 165752.4000   |
| US             | Data Management Analyst              | 91747.5000    |
| US             | Data Management Consultant           | 92500.0000    |
| US             | Data Management Specialist           | 130498.8333   |
| CA             | Data Manager                         | 125976.0000   |
| US             | Data Modeler                         | 135258.3333   |
| GB             | Data Modeller                        | 83052.0000    |
| GB             | Data Operations Analyst              | 110500.0000   |
| US             | Data Operations Associate            | 61687.5000    |
| US             | Data Operations Engineer             | 133431.2500   |
| US             | Data Operations Manager              | 136000.0000   |
| US             | Data Operations Specialist           | 87634.0000    |
| US             | Data Pipeline Engineer               | 172500.0000   |
| GB             | Data Product Manager                 | 178750.0000   |
| GB             | Data Product Owner                   | 80115.5000    |
| US             | Data Quality Analyst                 | 89898.8889    |
| US             | Data Quality Engineer                | 131500.0000   |
| GB             | Data Quality Manager                 | 59059.0000    |

### 6. Countries with Consistent Salary Growth Over 3 Years
```sql
SELECT company_location,
  MAX(CASE WHEN work_year = 2022 THEN avg_salary END) AS salary_2022,
  MAX(CASE WHEN work_year = 2023 THEN avg_salary END) AS salary_2023,
  MAX(CASE WHEN work_year = 2024 THEN avg_salary END) AS salary_2024
FROM (
  SELECT company_location, work_year, AVG(salary_in_usd) AS avg_salary
  FROM salaries
  WHERE work_year >= 2022
  GROUP BY company_location, work_year
) q
GROUP BY company_location
HAVING salary_2024 > salary_2023 AND salary_2023 > salary_2022;
```

|company_locatiON| AVG_salary_2022| AVG_salary_2023| AVG_salary_2024|
|----------------|----------------|----------------|----------------|
|	CA|	126009.5526	|150724.1414	|153611.8077|
|	ES|	47997.3415	|60327.9857	|72184.6667|
|	FI|	63040.0000	|71259.0000	|77777.0000|
|	FR|	72684.4667	|100411.1905	|101370.1667|
|	PT|	48921.3750	|51521.0000	|53054.7500|
|	AR|	50000.0000	|65000.0000	|88500.0000|
|	IN|	37328.3333	|47777.5217	|71538.3333|
|	HU|	17684.0000	|43000.0000	|63333.0000|

### 7. Change in Remote Work Adoption (2021 vs 2024)
```sql
WITH past AS (
  SELECT experience_level, ROUND((remote_worker/total_worker)*100,2) AS past_percentage
  FROM (
    SELECT experience_level, COUNT(*) AS remote_worker
    FROM salaries
    WHERE remote_ratio = 100 AND work_year = 2021
    GROUP BY experience_level
  ) p
  JOIN (
    SELECT experience_level, COUNT(*) AS total_worker
    FROM salaries
    WHERE work_year = 2021
    GROUP BY experience_level
  ) q ON p.experience_level = q.experience_level
),
present AS (
  SELECT experience_level, ROUND((remote_worker/total_worker)*100,2) AS present_percentage
  FROM (
    SELECT experience_level, COUNT(*) AS remote_worker
    FROM salaries
    WHERE remote_ratio = 100 AND work_year = 2024
    GROUP BY experience_level
  ) a
  JOIN (
    SELECT experience_level, COUNT(*) AS total_worker
    FROM salaries
    WHERE work_year = 2024
    GROUP BY experience_level
  ) b ON a.experience_level = b.experience_level
)
SELECT past.experience_level, past.past_percentage, present.present_percentage
FROM past
JOIN present ON past.experience_level = present.experience_level;
```
|experience_level| past_percentage| present_percentage|
|----------------|----------------|-------------------|
|SE	|58.67	|25.16|
|MI	|51.72	|20.60|
|EN	|47.83	|22.83|
|EX	|50.00	|33.02|

### 8. Average Salary Increase Percentage (2023-2024)
```sql
WITH salary_avg AS (
  SELECT experience_level, job_title, work_year, AVG(salary_in_usd) AS avg_salary
  FROM salaries
  WHERE work_year IN (2023,2024)
  GROUP BY experience_level, job_title, work_year
)
SELECT experience_level, job_title,
  MAX(CASE WHEN work_year = 2023 THEN avg_salary END) AS salary_2023,
  MAX(CASE WHEN work_year = 2024 THEN avg_salary END) AS salary_2024,
  ROUND(((salary_2024 - salary_2023) / salary_2023) * 100, 2) AS percentage_increase
FROM salary_avg
GROUP BY experience_level, job_title
HAVING percentage_increase IS NOT NULL;
```

| Company Location | Job Title                               | Average Salary | Entry Average Salary |
|-----------------|-------------------------------------|----------------|---------------------|
| AU              | Computer Vision Software Engineer  | 77,760.60      | 150,000.00         |
| CA              | Machine Learning Research Engineer | 66,157.00      | 80,769.00          |
| CA              | AI Programmer                      | 62,042.00      | 74,087.00          |
| CA              | AI Scientist                       | 120,578.88     | 200,000.00         |
| CA              | Data Integration Specialist       | 85,268.87      | 100,000.00         |
| DE              | Machine Learning Research Engineer | 66,157.00      | 66,192.00          |
| DE              | AI Developer                       | 135,466.79     | 140,358.50         |
| GB              | Applied Data Scientist            | 102,587.92     | 110,037.00         |
| GB              | Cloud Data Engineer               | 131,617.75     | 177,177.00         |
| IQ              | Machine Learning Developer        | 72,703.50      | 100,000.00         |
| MX              | Data Analyst                      | 108,641.91     | 429,950.00         |
| SE              | Big Data Engineer                 | 69,764.18      | 130,000.00         |
| US              | Data Specialist                   | 91,327.03      | 105,000.00         |
| US              | Big Data Engineer                 | 69,764.18      | 70,000.00          |
| US              | Data Operations Associate         | 61,399.00      | 61,687.50          |
| US              | Data Integration Specialist       | 85,268.87      | 94,341.67          |
| US              | Business Data Analyst             | 73,567.76      | 74,000.00          |
| US              | Business Intelligence Data Analyst | 83,209.50      | 99,000.00          |
| US              | Compliance Data Analyst           | 45,000.00      | 60,000.00          |
| US              | Product Data Analyst              | 69,436.17      | 91,600.00          |
| US              | Machine Learning Developer        | 72,703.50      | 180,000.00         |

### 9. Role-Based Access Control for Entry-Level Employees
```sql
CREATE USER 'ENTRY_LEVEL'@'%' IDENTIFIED BY 'first';
CREATE VIEW select_only AS SELECT * FROM salaries WHERE experience_level = 'EN';
GRANT SELECT, INSERT ON CaseStudy.select_only TO 'ENTRY_LEVEL'@'%';
```

### 10. Career Transition Recommendations
```sql
DELIMITER //
CREATE PROCEDURE domain(IN exp_level VARCHAR(2), IN comp_location VARCHAR(2), IN comp_size VARCHAR(1), IN emp_type VARCHAR(2))
BEGIN
  SELECT job_title, experience_level, company_location, company_size, employment_type, AVG(salary_in_usd) AS avg_salary
  FROM salaries
  WHERE experience_level = exp_level AND company_location = comp_location AND company_size = comp_size AND employment_type = emp_type
  GROUP BY job_title;
END //
DELIMITER ;
```

## Conclusion
This SQL case study provides insights into salary trends, remote work evolution, and workforce distribution, aiding HR professionals and data analysts in making data-driven decisions.
