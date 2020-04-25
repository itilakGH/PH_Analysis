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
