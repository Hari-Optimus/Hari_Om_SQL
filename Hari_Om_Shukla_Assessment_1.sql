create database Assessment;
use Assessment;
create table Employee(
Emp_id int identity(1001,2) primary key,
Emp_Code varchar(30),
Emp_f_name varchar(10) not null ,
Emp_m_name varchar(30),
Emp_l_name varchar(30),
Emp_DOB Date,
Emp_DOJ Date not null,
check (DateDiff(year,Emp_DOJ,Emp_DOB) <18)
);
create table Activity(
Activity_id int primary key,
Activity_description varchar(30)
);
create table salary (
Salary_id int primary key,
Emp_id int,
Changed_date Date,
New_Salary Decimal(12,2),
Foreign key (Emp_id) references Employee(Emp_id)
);
create table Attendance(
Atten_id int identity(1001,1) primary key,
Emp_id int,
Activity_id int,
Atten_start_datetime DateTime,
Atten_end_hrs int,
Foreign key (Emp_id) references Employee(Emp_id),
Foreign key (Activity_id) references Activity(Activity_id)
);


insert into Employee values ('OPT20110105','Manmohan','Kumar','Singh', '2001-01-01','2022-01-23'),
('OPT20110106','Hariom','Kumar','Shukla','2004-07-10','2025-03-03'),
('OPT20110107','Govind','Kumar','Shukla','2002-07-10','2025-07-03'),
('OPT20110108','Shreya','Kumar','Shukla','2005-04-14','2025-09-15'),
('OPT20110109','Krishna','Goapl','Shukla','1997-07-09','2020-06-12'),
('OPT20110110','Krishna','Goapl','Shukla','1997-07-09','2020-06-12'),
('OPT20110111','Krishna','Goapl','Shukla','1997-02-28','2020-06-12');

insert into Activity values(1,'Code Analysis'),
(2,'Lunch'),
(3,'Coding'),
(4,'Knowledge Transition'),
(5,'Database');

insert into Attendance values(1001,5,'2011-02-13 10:00:00',2),
(1001,1,'2011-01-14 10:00:00',3),
(1001,3,'2011-01-14 13:00:00',5),
(1003,5,'2011-02-16 10:00:00',8),
(1003,5,'2011-02-17 10:00:00',8),
(1003,5,'2011-02-19 10:00:00',7);

insert into Salary values(1001,1003,'2011-02-16',20000.00),
(1002,1003,'2011-01-05',25000.00),
(1003,1001,'2011-02-16',2600.00);



select * from Employee;
select * from Attendance;
select * from Activity;
Select * from Salary;
-- Query 1:

select Emp_f_name+Emp_m_name+Emp_l_name as Name, Emp_DOB as Date_Of_Birth
from Employee where month(Emp_DOB)!=month(Dateadd(day,1,Emp_DOB));

--Query 2:

select t1.Emp_id,Emp_f_name+Emp_m_name+Emp_l_name as Name_Employee, 
iif(t2.cnt>1 and New_Salary>Previous,'True','False') as Get_Salary_Increment,
t5.Previous,
t5.New_Salary,
tot as total_worked_hours,
t7.Activity_id,
t7.Activity_description as last_worked_activity,
Atten_end_hrs as hours_worked
from Employee t1 left join 
(select Emp_id, count(*) as cnt from Salary group by Emp_id) t2 on t1.Emp_id = t2.Emp_id
left join 
(select t3.Emp_id,Previous,New_Salary from 
(select Emp_id, New_Salary from 
(select 
Emp_id,
New_Salary,
ROW_NUMBER() over(partition by Emp_id order by Changed_date desc) as S_U
from Salary)as l1 
where S_U = 1)  as t3
left join 
(select Emp_id, New_Salary as Previous from 
(select 
Emp_id,
New_Salary,
ROW_NUMBER() over(partition by Emp_id order by Changed_date desc) as S_U
from Salary)as l2 
where S_U = 2) as t4
on t3.Emp_id = t4.Emp_id)as t5
on t1.Emp_id = t5.Emp_id  left join (
select 
Emp_id,
Attendance.Activity_id,
Atten_end_hrs,
Activity_description,
sum(Atten_end_hrs) over (partition by Emp_id) as tot,
rank()  over (partition by Emp_id order by Atten_start_datetime) as time_updates
from Attendance left join 
Activity on Attendance.Activity_id=Activity.Activity_id 
) as t7 
on t1.Emp_id= t7.Emp_id 
where t7.time_updates =1
group by t1.Emp_id,Emp_f_name,
Emp_l_name,
Emp_m_name,
t2.cnt,
Previous,
New_Salary,
tot,
t7.Atten_end_hrs,
t7.Activity_id,
t7.Activity_description;



