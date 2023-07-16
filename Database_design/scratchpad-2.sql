/*Create Dim_employee table and insert data into it*/
CREATE TABLE Dim_employee (
    emp_code SERIAL primary key,
    emp_id varchar(8),
	emp_nm varchar(50),
	email varchar(100),
	hire_dt DATE);

INSERT INTO Dim_employee(emp_id, emp_nm, email, hire_dt)
SELECT DISTINCT emp_id, emp_nm, email, hire_dt FROM proj_stg;

/*Create Dim_education table and insert data into it*/
CREATE TABLE Dim_education (
    education_id SERIAL primary key,
	education_level varchar(50));
			
INSERT INTO Dim_education(education_level)
SELECT DISTINCT education_lvl FROM proj_stg;

/*Create Dim_salary table and insert data into it*/
CREATE TABLE Dim_salary (
    salary_id SERIAL primary key,
	salary INT);
			
INSERT INTO Dim_salary(salary)
SELECT DISTINCT salary FROM proj_stg;

/*Create Dim_department table and insert data into it*/
CREATE TABLE Dim_department (
    department_id SERIAL primary key,
	department_nm varchar(50));
			
INSERT INTO Dim_department(department_nm)
SELECT DISTINCT department_nm FROM proj_stg;

/*Create Dim_job table and insert data into it*/
CREATE TABLE Dim_job (
    job_id SERIAL primary key,
	job_title varchar(100));
			
INSERT INTO Dim_job(job_title)
SELECT DISTINCT job_title FROM proj_stg;

/*Create Dim_location table and insert data into it*/
CREATE TABLE Dim_location (
	location_id SERIAL primary key,
    location varchar(50),
    city varchar(50),
    state varchar(2),
    address varchar(100));
		
INSERT INTO Dim_location(location, city, state, address)
SELECT DISTINCT location, city, state, address FROM proj_stg;

/*Create Fact_employment_details table and insert data into it*/
CREATE TABLE Fact_employment_details (
    emp_code INT,
    job_id INT,
    salary_id INT,
    department_id INT,
    manager_code INT,
    start_dt DATE,
    end_dt DATE,
    location_id INT,
    education_id INT);

INSERT INTO Fact_employment_details(emp_code,job_id,salary_id,department_id,manager_code,start_dt,end_dt,location_id,education_id)
SELECT DISTINCT de.emp_code,dj.job_id,dsa.salary_id,dd.department_id,dm.emp_code,p.start_dt,p.end_dt,dl.location_id,ded.education_id
FROM proj_stg p
JOIN Dim_employee de
ON p.emp_nm = de.emp_nm
FULL JOIN Dim_employee dm
ON dm.emp_nm=p.manager
JOIN Dim_job dj
ON dj.job_title=p.job_title
JOIN Dim_salary dsa 
ON p.salary=dsa.salary
JOIN Dim_department dd
ON p.department_nm=dd.department_nm
JOIN Dim_location dl
ON p.location=dl.location
JOIN Dim_education ded
ON p.education_lvl=ded.education_level;

ALTER TABLE Fact_employment_details ADD FOREIGN KEY (emp_code) REFERENCES Dim_employee(emp_code);
ALTER TABLE Fact_employment_details ADD FOREIGN KEY (job_id) REFERENCES Dim_job(job_id);
ALTER TABLE Fact_employment_details ADD FOREIGN KEY (salary_id) REFERENCES Dim_salary(salary_id);
ALTER TABLE Fact_employment_details ADD FOREIGN KEY (department_id) REFERENCES Dim_department(department_id);
ALTER TABLE Fact_employment_details ADD FOREIGN KEY (manager_code) REFERENCES Dim_employee(emp_code);
ALTER TABLE Fact_employment_details ADD FOREIGN KEY (location_id) REFERENCES Dim_location(location_id);
ALTER TABLE Fact_employment_details ADD FOREIGN KEY (education_id) REFERENCES Dim_education(education_id);

/*Question 1: Return a list of employees with Job Titles and Department Names*/
SELECT de.emp_id, dj.job_title, dd.department_nm
FROM Fact_employment_details fe
JOIN Dim_job dj
ON fe.job_id=dj.job_id
JOIN Dim_employee de
ON de.emp_code=fe.emp_code
JOIN Dim_department dd
ON fe.department_id=dd.department_id;

/*Question 2: Insert Web Programmer as a new job title*/
INSERT INTO Dim_job(job_title) VALUES ('Web Programmer');
/*Question 3: Update the job title from Web Programmer to Web Developer*/
UPDATE Dim_job SET job_title='Web Developer' WHERE job_title='Web Programmer';
/*Question 4: Delete the job title Web Developer from the database*/
DELETE FROM Dim_job WHERE job_title='Web Developer';

/*Question 5: How many employees are in each department?*/
SELECT dd.department_nm,count(fe.emp_code)
FROM Fact_employment_details fe
JOIN Dim_department dd
ON fe.department_id=dd.department_id
GROUP BY 1;

/*Question 6: Write a query that returns current and past jobs (include employee name, job title, department, manager name, start and end date for position) for employee Toni Lembeck.*/
SELECT de.emp_nm,dj.job_title,dd.department_nm,dm.emp_nm AS manager,fe.start_dt,fe.end_dt
FROM Fact_employment_details fe
JOIN Dim_employee de
ON fe.emp_code = de.emp_code
JOIN Dim_employee dm
ON dm.emp_code=fe.manager_code
JOIN Dim_job dj
ON dj.job_id=fe.job_id
JOIN Dim_department dd
ON fe.department_id=dd.department_id
WHERE de.emp_nm='Toni Lembeck';