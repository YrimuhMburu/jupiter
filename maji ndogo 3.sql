/* slide 6 Creating auditor report table*/

DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE md_water_services. `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);
/* slide 7 compare water quality score in water_quality_table and True_score_ from auditors_report*/
use md_water_services;
select * from auditor_report;
select location_id,true_water_source_score from auditor_report;
/* slide 8 join the visits table to the auditor_report table. Make sure to grab subjective_quality_score, record_id and location_id.*/
select
a.location_id as Audit_location,
a.true_water_source_score,
v.record_id,
v.location_id as Visit_location
from auditor_report as a
 join  visits  as v
on a.location_id = v.location_id;
/* slide 9 to retrieve the corresponding scores from the water_quality table. We
are particularly interested in the subjective_quality_score. JOIN the visits table and the water_quality table, using the
record_id as the connecting key*/
 select 
 auditor_report.location_id as Audit_location,
 auditor_report.true_water_source_score,
 visits.record_id,
 visits.location_id as Visit_location,
 water_quality.subjective_quality_score
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id;
 /* slide 10 Since it is a duplicate, we can drop one of
the location_id columns. Let's leave record_id and rename the scores to surveyor_score and auditor_score to make it clear which scores
we're looking at in the results set.*/
alter table auditor_report
rename  column true_water_source_score  to Auditor_score;
 select * from auditor_report;
alter  table water_quality
rename column subjective_quality_score to employee_score;
select * from  water_quality;
 select 
 auditor_report.location_id,
 auditor_report.auditor_score,
 visits.record_id,
 water_quality.employee_score
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 limit 10000;
/* slide 10 A good starting point is to check if the auditor's and exployees' scores agree. There are many ways to do it. We can have a
WHERE clause and check if surveyor_score = auditor_score, or we can subtract the two scores and check if the result is 0.*/
select 
 auditor_report.location_id,
 auditor_report.auditor_score,
 visits.record_id,
 water_quality.employee_score
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 where 
  auditor_report.auditor_score = water_quality.employee_score
  limit 10000;
 /* slide 11 Some of the locations were visited multiple times, so these records are duplicated here. To fix it, we set visits.visit_count
= 1 in the WHERE clause. Make sure you reference the alias you used for visits in the join.*/
select 
auditor_report.location_id,
 auditor_report.auditor_score,
 visits.record_id,
 visits.visit_count,
 water_quality.employee_score
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 where 
 auditor_report.auditor_score = water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000;
 select 
auditor_report.location_id,
 auditor_report.auditor_score,
 visits.record_id,
 visits.visit_count,
 water_quality.employee_score
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 where 
 auditor_report.auditor_score = water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000;
 /* slide 11 But that means that 102 records are incorrect. 
 So let's look at those. You can do it by adding one character in the last query!*/

  select 
auditor_report.location_id,
 auditor_report.auditor_score,
 visits.record_id,
 visits.visit_count,
 water_quality.employee_score
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 where 
 auditor_report.auditor_score <> water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000 ;
/*  slide 12 So, to do this, we need to grab the type_of_water_source column from the water_source table and call it survey_source, using the
source_id column to JOIN. Also select the type_of_water_source from the auditor_report table, and call it auditor_source.*/
 select 
auditor_report.location_id,
 auditor_report.auditor_score,
 visits.record_id,
 visits.visit_count,
 water_quality.employee_score
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 where 
 auditor_report.auditor_score <> water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000 ; 
/* slide 14 In either case, the employees are the source of the errors, so let's JOIN the assigned_employee_id for all the people on our list from the visits
table to our query. Remember, our query shows the shows the 102 incorrect records, so when we join the employee data, we can see which
employees made these incorrect records.*/
-- select 
-- auditor_report.location_id,
-- visits.record_id,
-- visits. assigned_employee_id,
--  water_quality.employee_score,
--  auditor_report.auditor_score
--  from auditor_report
--  join visits 
--  on auditor_report.location_id =visits.location_id
--  join water_quality
--  on water_quality.record_id = visits.record_id 
--  
--  order by water_quality.employee_score desc
--  limit 10000;
 select 
auditor_report.location_id,
 visits.record_id,
 employee.employee_name,
 visits.visit_count,
 auditor_report.auditor_score,
 water_quality.employee_score
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 join employee
 on employee.assigned_employee_id = visits. assigned_employee_id
and
 auditor_report.auditor_score <> water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000 ;
/* slide 16 save this as a CTE, so when we do more analysis, we can just call that CTE
like it was a table. Call it something like Incorrect_records. Once you are done, check if this query SELECT * FROM Incorrect_records, gets
the same table back.*/
 
with Incorrect_records_3 as 
(select 
auditor_report.location_id,
visits.record_id,
 visits.visit_count, 
 employee.employee_name,
 auditor_report.auditor_score,
 water_quality.employee_score
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 join employee
 on employee.assigned_employee_id = visits. assigned_employee_id
and
 auditor_report.auditor_score <> water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000)
 select  * from Incorrect_records_3;
/* slide 16 Let's first get a unique list of employees from this table. */
with Incorrect_records_3 as 
(select 
auditor_report.location_id,
visits.record_id,
 visits.visit_count, 
 employee.employee_name,
 auditor_report.auditor_score,
 water_quality.employee_score
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 join employee
 on employee.assigned_employee_id = visits. assigned_employee_id
and
 auditor_report.auditor_score <> water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000)
select distinct(employee_name) from Incorrect_records_3;
/*slide 16let's try to calculate how many mistakes each employee made. So basically we want to count how many times their name is in
Incorrect_records list, and then group them by name, right?*/

 with error_count  as (
SELECT
		employee_name,
		COUNT(employee_name) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)
SELECT * FROM error_count;
/*always comment out the the querry after CTE so thatt you can call the cte* or just copy the cte every time you wan to use it /
/* slide 19 Then, we need to calculate the average number of mistakes employees made. We can do that by taking the average of the previous query's
results.*/
 with error_count  as (
SELECT
		employee_name,
		COUNT(employee_name) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)
SELECT
AVG(no_of_mistakes) as  avg_error_count_per_empl
from error_count;

/*slide 20 * saving the CTe as a view */
DROP VIEW incorrect_records_3;
 create view  Incorrect_records_3 as 
(select 
auditor_report.location_id,
visits.record_id,
employee.employee_name,
 auditor_report.auditor_score,
 water_quality.employee_score,
 visits.visit_count,
 auditor_report.statements
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 join employee
 on employee.assigned_employee_id = visits. assigned_employee_id
where
 auditor_report.auditor_score <> water_quality.employee_score and visits.visit_count =1);
 select * from incorrect_records_3;
/* slide 21  Next, we convert the query error_count, we made earlier, into a CTE. Test it to make sure it gives the same result again, using SELECT * FROM
Incorrect_records*/
with error_count  as (
SELECT
		employee_name,
		COUNT(employee_name ) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)
	select * from error_count;
    /*Now calculate the average of the number_of_mistakes in error_count. You should get a single value*/
with error_count  as (
SELECT
		employee_name,
		COUNT(employee_name ) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)
    SELECT
 AVG(no_of_mistakes) as  avg_error_count_per_empl
from error_count;
/* slide 22 to  find the employees who made more mistakes than the average person, we need the employee's names, the number of mistakes each one
made, and filter the employees with an above-average number of mistakes.*/
with error_count  as (
SELECT
		employee_name,
		COUNT(employee_name ) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)
SELECT
employee_name,
no_of_mistakes
FROM
error_count
where
no_of_mistakes > ( SELECT
AVG(no_of_mistakes) as  avg_error_count_per_empl
 from error_count); 
/*convert the suspect_list to a CTE, so we can use it to filter the records from these four employees. Make sure you get the names of the
four "suspects", and their mistake count as a result, using SELECT employee_name FROM suspect_list*/
with error_count  as (
SELECT
		employee_name,
		COUNT(employee_name ) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)

 -- ,suspect_list AS (
--   SELECT
--     employee_name,
--     no_of_mistakes
--   FROM
--     error_count
-- )
,suspect_list AS (
    SELECT ec1.employee_name, ec1.no_of_mistakes
    FROM error_count ec1
    WHERE ec1.no_of_mistakes >= (
        SELECT AVG(ec2.no_of_mistakes)
        FROM error_count ec2
        WHERE ec2.employee_name = ec1.employee_name))
 select 
* from suspect_list;

-- SELECT employee_name,
--      no_of_mistakes
-- FROM suspect_list
-- WHERE no_of_mistakes > (SELECT AVG(no_of_mistakes) FROM suspect_list);
/* slide  23 Now we can filter that Incorrect_records CTE to identify all of the records associated with the four employees we identified.*/
-- with Incorrect_records_3 as 
-- (select 
-- auditor_report.location_id,
--  auditor_report.auditor_score,
--  visits.record_id,
--  visits.visit_count,
--  water_quality.employee_score,
--  employee.employee_name
--  from auditor_report
--  join visits 
--  on auditor_report.location_id =visits.location_id
--  join water_quality
--  on water_quality.record_id = visits.record_id
--  join employee
--  on employee.assigned_employee_id = visits. assigned_employee_id
-- and
--  auditor_report.auditor_score <> water_quality.employee_score
--  and 
--  visits.visit_count = 1 
--  limit 10000)
--  ,error_count  as (
-- SELECT
-- 		employee_name,
-- 		COUNT(employee_name ) AS no_of_mistakes
-- 	FROM incorrect_records_3
-- 	GROUP BY employee_name)
--  ,suspect_list as(
--   SELECT
--     employee_name,
--     no_of_mistakes
--   FROM
--     error_count
-- )
-- select employee_name from suspect_list

-- WHERE no_of_mistakes > (SELECT AVG(no_of_mistakes) FROM suspect_list);
with error_count  as (
SELECT
		employee_name,
		COUNT(employee_name ) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)
 ,suspect_list as(
  SELECT
    employee_name,
    no_of_mistakes
  FROM
    error_count
)
select employee_name from suspect_list

WHERE no_of_mistakes > (SELECT AVG(no_of_mistakes) FROM suspect_list);
/* slide 23 Firstly, let's add the statements column to the Incorrect_records CTE. Then pull up all of the records where the employee_name is in the
suspect list. HINT: Use SELECT employee_name FROM suspect_list as a subquery in WHERE.*/
with Incorrect_records_3 as 
(select 
auditor_report.location_id,
 auditor_report.auditor_score,
 visits.record_id,
 visits.visit_count,
 water_quality.employee_score,
 employee.employee_name,
 auditor_report.statements
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 join employee
 on employee.assigned_employee_id = visits. assigned_employee_id
and
 auditor_report.auditor_score <> water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000)
 ,error_count  as (
SELECT
		employee_name,
		COUNT(employee_name ) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)
 ,suspect_list as(
  SELECT
    employee_name,
	no_of_mistakes
  FROM
    error_count
)
select employee_name ,statements,location_id from incorrect_records_3
WHERE employee_name IN (select employee_name from suspect_list);
/*another method to get same results as above */
with Incorrect_records_3 as 
(select 
auditor_report.location_id,
 auditor_report.auditor_score,
 visits.record_id,
 visits.visit_count,
 water_quality.employee_score,
 employee.employee_name,
 auditor_report.statements
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 join employee
 on employee.assigned_employee_id = visits. assigned_employee_id
and
 auditor_report.auditor_score <> water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000)
 ,error_count  as (
SELECT
		employee_name,
		COUNT(employee_name ) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)
 ,suspect_list as(
  SELECT
    employee_name,
	no_of_mistakes
  FROM
    error_count
)
select suspect_list.employee_name ,incorrect_records_3.statements,incorrect_records_3.location_id from suspect_list join
incorrect_records_3 on incorrect_records_3.employee_name  = suspect_list.employee_name
WHERE no_of_mistakes > (SELECT AVG(no_of_mistakes) FROM suspect_list) 
;
/*slide 26*/
with Incorrect_records_3 as 
(select 
auditor_report.location_id,
 auditor_report.auditor_score,
 visits.record_id,
 visits.visit_count,
 water_quality.employee_score,
 employee.employee_name,
 auditor_report.statements
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 join employee
 on employee.assigned_employee_id = visits. assigned_employee_id
and
 auditor_report.auditor_score <> water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000)
 ,error_count  as (
SELECT
		employee_name,
		COUNT(employee_name ) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)
 ,suspect_list as(
  SELECT
    employee_name,
	no_of_mistakes
  FROM
    error_count
)
select  employee_name  from error_count
-- mcq project 3use md_water_services;
-- question 1

SELECT
    auditorRep.location_id,
    visitsTbl.record_id,
    Empl_Table.employee_name,
    auditorRep.Auditor_score,
    wq. employee_score
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
ON visitsTbl.record_id = wq.record_id
JOIN employee as Empl_Table
ON Empl_Table.assigned_employee_id = visitsTbl.assigned_employee_id
limit 10000;
-- question 2
-- This CTE fetches all of the records with wrong scores
WITH Incorrect_records AS ( 
SELECT
    auditorRep.location_id,
    visitsTbl.record_id,
    Empl_Table.employee_name,
    auditorRep.auditor_score,
    wq.employee_score
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
ON visitsTbl.record_id = wq.record_id
JOIN employee as Empl_Table
ON Empl_Table.assigned_employee_id = visitsTbl.assigned_employee_id
WHERE visitsTbl.visit_count =1 AND auditorRep.auditor_score != wq.employee_score)

SELECT
    employee_name,
    count(employee_name)
FROM Incorrect_records
GROUP BY Employee_name;
-- question 4 
with Incorrect_records_3 as 
(select 
auditor_report.location_id,
 auditor_report.auditor_score,
 visits.record_id,
 visits.visit_count,
 water_quality.employee_score,
 employee.employee_name,
 auditor_report.statements
 from auditor_report
 join visits 
 on auditor_report.location_id =visits.location_id
 join water_quality
 on water_quality.record_id = visits.record_id
 join employee
 on employee.assigned_employee_id = visits. assigned_employee_id
and
 auditor_report.auditor_score <> water_quality.employee_score
 and 
 visits.visit_count = 1 
 limit 10000)
 ,error_count  as (
SELECT
		employee_name,
		COUNT(employee_name ) AS no_of_mistakes
	FROM incorrect_records_3
	GROUP BY employee_name)
 ,suspect_list AS (
    SELECT ec1.employee_name, ec1.no_of_mistakes
    FROM error_count ec1
    WHERE ec1.no_of_mistakes >= (
        SELECT AVG(ec2.no_of_mistakes)
        FROM error_count ec2
        WHERE ec2.employee_name = ec1.employee_name))
        select * from suspect_list;
  -- question 7      
WITH Incorrect_records AS (
SELECT
    auditorRep.location_id,
    visitsTbl.record_id,
    Empl_Table.employee_name,
    auditorRep.auditor_score,
    wq.employee_score,
    auditorRep.statements AS statements
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
ON visitsTbl.record_id = wq.record_id
JOIN employee as Empl_Table
ON Empl_Table.assigned_employee_id = visitsTbl.assigned_employee_id
WHERE visitsTbl.visit_count =1 AND auditorRep.Auditor_score != wq.employee_score);
-- question 10
SELECT
auditorRep.location_id,
visitsTbl.record_id,
auditorRep.auditor_score,
wq.employee_score,
wq.employee_score- auditorRep.Auditor_score  AS score_diff
FROM auditor_report AS auditorRep
JOIN visits AS visitsTbl
ON auditorRep.location_id = visitsTbl.location_id
JOIN water_quality AS wq
ON visitsTbl.record_id = wq.record_id
WHERE (wq.employee_score - auditorRep.Auditor_score) > 9;