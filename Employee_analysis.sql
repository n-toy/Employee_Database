/*
* 	Create a table containing the # of employees who ar about to retire grouped by job title
*   Tables to use:
	Employees, Titles, Salaries
	Need:
		Employee number
		first name
		last name
		title
		from_date
		salary
		
	insert into retiring_title
*/

-- Partition the data to show only the most recent title per ACTIVE employee
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
order by a.emp_no
;

--Table 1: Number of titles retiring

select distinct(title)
into distinct_retiring_titles
from retiring_title a
order by title 
;

--Table 2: Number of employees with each title
select 
case 
	when title is null
		then 'Grand Total'
	else title
end as title
,emp_count
into retiring_title_employee_count
from(
	select title, count(distinct emp_no) as emp_count
	from retiring_title a
	group by cube(title)
	--order by count(distinct emp_no) desc
)a
;

-- List of current employees born between Jan 1 1952 and dec 31 1955


--Mentorship Eligibility
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
	
select *
from mentorship_eligible
;






