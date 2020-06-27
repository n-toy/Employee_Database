# Employee_Database

## Project Overview
Incorporate the following: 

	1. Number of Retiring Employees by Title. Create three new tables, one showing number of titles retiring, one showing number of employees with each title, and one showing a list of current employees born between Jan. 1, 1952 and Dec. 31, 1955.
	2. Mentorship Eligibility. A table containing employees who are eligible for the mentorship program.
 
## Resources
Data Source: Employee, Department, Salary, Title Excel flat files
Software: pgAdmin4, PostgreSQL

## Report
  The goal of this analysis is to highlight current employees who have birthdates in 1952-1955 that are nearing retirement age. A colleague was able to share excel flat files containing employee information that were imported into a PostgreSQL Relational Database. The company has historical data for over 300,000 employees with the earliest birthday on February 1, 1952.
  
  ![Employee Database ERD](https://github.com/n-toy/Employee_Database/blob/master/resources/EmployeeDB.PNG)
  
  After all excel flat files for employees were imported into a PostgreSQL database queries were created to isolate employees born between Jan 1, 1952 and Dec 31, 1955. Once the population of employees was found duplicates were removed using **row_number() over (partition by)** SQL command, and non-active employees were filtered out. 
  Query below for employees retiring soon:
  ```
	select 
	a.emp_no
	,a.first_name
	,a.last_name
	,a.title
	,a.from_date
	,a.salary
	into retiring_title
	from (
		select 
		e.emp_no
		,e.first_name
		,e.last_name
		,ti.title
		,ti.from_date
		,ti.to_date
		,s.salary
		,row_number() over (partition by e.emp_no order by ti.from_date desc) as rn
		from employees e
		inner join titles ti
		on e.emp_no = ti.emp_no
		inner join salaries s
		on e.emp_no = s.emp_no
		WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	)a
	where rn = 1 and to_date > current_date
	;
  ```
	
  For the Mentorship Eligible employees a similar query was used for current employees. Mentorship Eligible employees are born in the year 1965. 
  Query below for Mentorship Eligible employees:
  ```
	select 
	a.emp_no
	,a.first_name
	,a.last_name
	,a.title
	,a.from_date
	,a.to_date
	into mentorship_eligible
	from(
		select 
		e.emp_no
		,e.first_name
		,e.last_name
		,ti.title
		,ti.from_date
		,ti.to_date
		,row_number() over (partition by e.emp_no order by ti.from_date desc) as rn
		from employees e
		inner join titles ti
		on e.emp_no = ti.emp_no
		WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	)a
	where rn = 1 and to_date > current_date
		;
  ```
  
	
  Based on the queries above, there are 7 titles impacted by of employees retiring soon. There are 72,458 current employees with those titles. Of the number of current employees, Senior Engineer and Senior Staff titles make up the bulk of retiring-soon employees (>50,000 or 70%).
  
  ![Employees retiring soon by title summary](https://github.com/n-toy/Employee_Database/blob/master/resources/Employee_count_breakdown.png)
  
  What may be worth revisiting is analyzing the employees retiring soon by department, or salary buckets. There may be cross-department representation in the data that is currently not visible because of the focus on title of the employee. From a salary standpoint the employees retiring soon may be over/under compensated for their job. With a large number of employees retiring soon it may be worthwhile to dive into salary ranges for all employees. 
	
  For Mentorship Eligible employees, only 1,549 current employees have been found. The narrow eligibility criteria of employees having to be born in 1965 is a hinderance to the total population of employees found. 
  