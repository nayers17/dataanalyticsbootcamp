-- ORDER BY

SELECT *
FROM employee_demographics
ORDER BY first_name DESC;

-- WHERE

SELECT *
FROM employee_demographics
WHERE age > 40;

-- GROUP BY and HAVING
SELECT sum(age), avg(age), min(age), max(age), count(age), gender
FROM employee_demographics
GROUP BY gender;
-- HAVING sum(age) > 200;

-- JOINS

SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;

SELECT 
	*
FROM employee_demographics AS dem
RIGHT JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;

-- outer joins (left join, right join or a left outer and a right outer join, self join)

SELECT
	*
FROM
    employee_demographics AS ed
JOIN employee_salary AS es
	ON ed.employee_id = es.employee_id
;

-- SELF JOIN

SELECT 
	emp1.employee_id AS emp_santa,
    emp1.first_name AS first_name_santa,
    emp1.last_name AS last_name_santa,
    emp2.employee_id AS emp_santa,
    emp2.first_name AS first_name_santa,
    emp2.last_name AS last_name_santa
FROM employee_salary AS emp1
JOIN employee_salary AS emp2
	ON emp1.employee_id + 1 = emp2.employee_id;
    
-- joining multiple tables
    
SELECT *
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
JOIN parks_departments AS dep
	ON sal.dept_id = dep.department_id;

SELECT *
FROM parks_departments;


-- UNION

SELECT first_name, last_name
FROM employee_demographics
UNION DISTINCT
SELECT first_name, last_name
FROM employee_salary;



SELECT first_name, last_name, age, 'Old Man' AS Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, age, 'Old Lady' AS Label
FROM employee_demographics
WHERE age > 40 AND gender = "Female"
UNION
SELECT first_name, last_name, salary, 'Highly Paid Employee' AS Label
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name;


-- string functions

SELECT UPPER(first_name)
FROM employee_demographics;

SELECT LTRIM('             sky       ');


-- substring function

SELECT 
	first_name, 
    LEFT(first_name, 4),
    RIGHT(first_name, 3),
    SUBSTRING(first_name, 3, 2),
    birth_date,
    SUBSTRING(birth_date, 6, 2) AS birthday_month
FROM employee_demographics;

-- replace (replaces specific characters with characters you want)

SELECT 
	first_name,
	REPLACE(first_name, 'a', 'z')
FROM employee_demographics;

SELECT
	REPLACE('alexander', 'a', 'z');

-- locate

SELECT
	LOCATE('x', 'alexander');
    
SELECT 
	first_name,
	LOCATE('An', first_name)
FROM employee_demographics;

SELECT
	first_name,
    last_name,
    CONCAT(first_name, ' ', last_name)
FROM employee_demographics
ORDER BY last_name;

-- case statements

SELECT 
	first_name,
    last_name,
    age,
CASE
	WHEN age <= 30 THEN 'Young'
    WHEN age BETWEEN 31 AND 50 THEN 'Old'
    WHEN age >= 50 THEN "On Death's door"
END AS Age_Bracket
FROM employee_demographics;


-- goal: find out what percentage of raise employees get based off income (my first attempt without watching video)
-- < 50000 = 5% raise
-- > 50000 = 7% raise
-- Finance department = 10% bonus

SELECT 
	first_name,
    last_name,
    salary,
    department_name,
CASE
	WHEN salary < 50000 THEN "5% raise"
	WHEN department_name = "Finance" AND salary > 50000 THEN "10% Bonus"
    WHEN salary >= 50000 THEN "7% raise"
END AS Raise_Bonus
FROM employee_salary AS sal
JOIN parks_departments AS dep
	ON dep.department_id = sal.dept_id;
    
-- attempt #2

SELECT
	first_name,
    last_name,
    salary,
    department_name,
CASE
	WHEN salary < 50000 
		THEN salary + (.05 * salary)
	WHEN salary >= 50000 AND department_name != 'Finance'
		THEN salary + (.07 * salary)    
    WHEN department_name = 'Finance'
		THEN salary + (.1 * salary)
END AS "New_Salary"
FROM employee_salary AS sal
LEFT JOIN parks_departments AS dep
   ON dep.department_id = sal.dept_id;
-- ON sal.dept_id = dep.department_id;



SELECT 
	first_name,
	last_name,
    salary,
    dept_id,
CASE
	WHEN salary < 50000 THEN (salary * 1.05)
    WHEN salary > 50000 THEN (salary * 1.07)
END AS new_salary,
CASE 
	WHEN dept_id = 6 THEN (salary * 1.10)
END AS BONUS
FROM employee_salary;

-- SUBQUERIES (test: select all employee demographics that are in the first department)

SELECT *
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;

SELECT *
FROM employee_demographics
WHERE employee_id IN (SELECT employee_id
					  FROM employee_salary
                      WHERE dept_id = 1);
                      
SELECT 
	first_name,
	salary,
	(SELECT
		avg(salary)
	 FROM employee_salary)
FROM employee_salary;

SELECT 
	gender,
    AVG(age),
    MAX(age),
    MIN(age),
    count(age)
FROM employee_demographics
GROUP BY gender;

SELECT AVG(max_age) as Average_Max_Age, MAX(Max_Age)
FROM (SELECT 
	gender,
    AVG(age) AS Avg_Age,
    MAX(age) AS Max_Age,
    MIN(age) AS Min_Age,
    count(age) AS Total
FROM employee_demographics
GROUP BY gender) AS Agg_table;

-- window functions and rolling totals

SELECT
	dem.first_name,
    dem.last_name,
	gender,
    salary,
    sum(salary)
		OVER(partition by gender ORDER BY dem.employee_id) -- AS SUM_salary_by_gender,
	-- avg(salary)
		-- OVER(partition by gender) AS average_salary_by_gender -- over() is the window function
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;
    
-- special things you can only do with window functions and RANK()

SELECT
	sal.employee_id,
    dem.employee_id,
	dem.first_name,
    dem.last_name,
	gender,
    salary,
	ROW_NUMBER() OVER(partition by gender ORDER BY salary) AS ROW_NUM_by_gender,
    RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS salary_rank_by_gender,
    DENSE_RANK() OVER(partition by gender ORDER BY salary DESC) as DENSE_RANK_by_gender
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;
    
-- CTE (Common Table Expression) define a subqueery block that you can reference in a main query

WITH CTE_example (Gender, Avg_Sal, Max_Sal, Min_Sal, Total_Sal) AS 

(
SELECT gender, AVG(salary) AS avg_sal, MAX(salary) AS max_sal, MIN(salary) AS min_sal, COUNT(salary) AS total_sal
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)

SELECT *
FROM CTE_example
;


-- joining CTEs

WITH CTE_example AS 
(
SELECT employee_id, gender, birth_date
FROM employee_demographics
WHERE birth_date > '1985-01-01'
),
CTE_example2 AS
(
SELECT employee_id, salary
FROM employee_salary
WHERE salary > 50000
)
SELECT *
FROM CTE_example AS dem
JOIN CTE_example2 AS sal
	ON dem.employee_id = sal.employee_id;


-- Temp Table

CREATE TEMPORARY TABLE temp_table
(first_name varchar(50),
last_name varchar(50),
favorite_movie varchar(100)
);

SELECT *
FROM temp_table;

INSERT INTO temp_table
VALUES('Nathan', 'Ayers', 'Lord of the Rings: The Two Towers');

SELECT *
FROM employee_salary;

CREATE TEMPORARY TABLE salary_over_50k
SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT *
FROM salary_over_50k;


-- stored procedures

SELECT *
FROM employee_salary
WHERE salary >= 50000;

-- USE Parks_and_Recreation
CREATE PROCEDURE large_salaries()
SELECT *
FROM employee_salarylarge_salaries
WHERE salary >= 50000;

CALL large_salaries();

DELIMITER $$
CREATE PROCEDURE large_salaries3()
BEGIN
	SELECT *
	FROM employee_salary
	WHERE salary >= 50000;
	SELECT *
	FROM employee_salary
	WHERE salary >= 10000;
END $$
DELIMITER ;

CALL large_salaries3();


-- parameters 
DELIMITER $$
CREATE PROCEDURE large_salaries4(emp_id_param INT)
BEGIN
	SELECT salary
    FROM employee_salary
    WHERE employee_id = emp_id_param;
END $$
DELIMITER ;

CALL large_salaries4(3);

DELIMITER $$
CREATE PROCEDURE large_salaries4(p_emp_id INT)
BEGIN
	SELECT salary
    FROM employee_salary
    WHERE employee_id = p_emp_id;
END $$
DELIMITER ;

CALL large_salaries4(2);

-- Triggers

SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;

SELECT *
FROM employee_demographics AS dem
JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id;

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW
BEGIN
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUE (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ;

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES(13, 'Jean-Ralphio', 'Saperstein', 'Entertainment 720 CEO', 1000000, NULL);

-- EVENTS (create an event that checks it every month/day, and if they are over a certain age, they will be retired)

SELECT *
FROM employee_demographics;


DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN
	DELETE
    FROM employee_demographics
    WHERE age >= 60;
END $$
DELIMITER ;

SHOW VARIABLES LIKE 'event%';















