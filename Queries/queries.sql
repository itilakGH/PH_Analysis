select * from departments;

select * from dept_emp;
select * from salaries
limit(10);

select first_name, last_name, birth_date
from employees
where birth_date between '1952-01-01' and '1952-12-31';

-- Retirement eligibility
select first_name, last_name, birth_date, hire_date
from employees
where (birth_date between '1952-01-01' and '1955-12-31') and (hire_date between '1985-01-01' and '1988-12-31');

-- Count records
select count(first_name)
from employees
where (birth_date between '1952-01-01' and '1955-12-31') and (hire_date between '1985-01-01' and '1988-12-31');

-- Creating a teble with Retirement eligibility
select first_name, last_name, birth_date, hire_date
into retirement_info
from employees
where (birth_date between '1952-01-01' and '1955-12-31') 
and (hire_date between '1985-01-01' and '1988-12-31');

select * from retirement_info;

drop table retirement_info;

-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;

-- Joining departments and dept_manager tables
SELECT departments.dept_name,
     dept_manager.emp_no,
     dept_manager.from_date,
     dept_manager.to_date
FROM departments
INNER JOIN dept_manager
ON departments.dept_no = dept_manager.dept_no;

-- Joining retirement_info and dept_emp tables
SELECT ri.emp_no, ri.first_name, ri.last_name, de.to_date
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no;

select * from retirement_info;

-- Joining departments and dept_manager tables
SELECT d.dept_name, 
	   dm.emp_no, 
	   dm.from_date, 
	   dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

-- Creating a table with the current employees
SELECT ri.emp_no, ri.first_name, ri.last_name, de.to_date
into current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
where de.to_date = '9999-01-01';

select * from retirement_info;
select * from current_emp;

-- Employee count by department number
select count(ce.emp_no), de.dept_no
into ret_count_dept
from current_emp as ce
left join dept_emp as de
on ce.emp_no = de.emp_no
group by de.dept_no
order by de.dept_no;

select * from ret_count_dept;

drop table emp_info;

SELECT e.emp_no,
	   e.first_name,
	   e.last_name,
	   e.gender,
	   s.salary,
	   de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

select * from emp_info;

-- List of managers per department
SELECT  ce.last_name,
        ce.first_name,
        ce.emp_no,
        d.dept_name
--INTO manager_info
FROM current_emp as ce
INNER JOIN dept_emp AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);
		
select * from current_emp;

select ce.emp_no, ce.first_name, ce.last_name, d.dept_name
from current_emp as ce
left join dept_emp as de
on (ce.emp_no = de.emp_no)
left join departments as d
on (de.dept_no = d.dept_no)
where d.dept_name in ('Sales', 'Development');

select count(emp_no) 
from salaries
group by emp_no
order by emp_no desc;

select ce.emp_no, 
	   ce.first_name, 
	   ce.last_name, 
	   tl.title, 
	   tl.from_date, 
	   s.salary
into people_titles
from current_emp as ce
inner join titles as tl
on (ce.emp_no = tl.emp_no)
inner join salaries as s
on (ce.emp_no = s.emp_no);

select * from people_titles;

-- Partition the data to show only most recent title per employee
SELECT *
INTO recent_titles
FROM
 (SELECT *,
 ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY from_date DESC) rn
 FROM people_titles
 ) tmp WHERE rn = 1
ORDER BY emp_no;

select count(title), title, round(avg(salary),0) as avg_salary
into current_ret_titles
from recent_titles
group by title;

select * from recent_titles;

select rt.emp_no, rt.first_name, rt.last_name, rt.title, e.birth_date
--de.from_date, de.to_date
from recent_titles as rt
inner join employees as e
on (rt.emp_no = e.emp_no)
order by e.birth_date;
where e.birth_date between '1965-01-01' and '1965-12-31';

left join dept_emp as de
on (rt.emp_no = de.emp_no);

-- Defining the list of employees who are aligible to participate in the mentorship program

--1. Selecting only current employees with day of birth between 1/1/1965 and 12/31/1965
select e.emp_no, e.first_name, e.last_name, e.birth_date, de.to_date
into current_emp_1965
from employees as e
left join dept_emp as de
on (e.emp_no = de.emp_no)
where (e.birth_date between '1965-01-01' and '1965-12-31')
and (de.to_date = '9999-01-01');

select * from current_emp_1965;

--2. Find out their titles to be able to count the number of employees of each title (with removing duplications)
select emp_no, first_name, last_name, title, from_date, to_date
into current_titles_1965
from
	(select ce.emp_no, ce.first_name, ce.last_name, tl.title, tl.from_date, ce.to_date,
 	row_number() over
 	(partition by (ce.emp_no)
 	order by tl.from_date desc) rn
 		from current_emp_1965 as ce
		inner join titles as tl
		on (ce.emp_no = tl.emp_no)
 	) temporarily
where rn = 1
order by emp_no;

select * from current_titles_1965;

select count(emp_no), title
into count_titles_1965
from current_titles_1965
group by title;

select * from count_titles_1965;

select *
from current_ret_titles as crt
full outer join count_titles_1965 as ct
on (crt.title = ct.title);
