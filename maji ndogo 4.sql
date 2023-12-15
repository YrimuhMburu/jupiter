--  SLIDE 4-6 Start by joining location to visits and water source table AND WHERE 
use md_water_services;
select  visits.visit_count, water_source.number_of_people_served, 
visits.location_id,  location.province_name, location.town_name,
water_source.type_of_water_source
 from 
visits 
join location on visits.location_id = location.location_id
join water_source on visits.source_id = water_source.source_id
where visits.location_id = 'AkHa00103'
;

-- Remove WHERE visits.location_id = 'AkHa00103' and add the visits.visit_count = 1 as
select  visits.visit_count, water_source.number_of_people_served, 
visits.location_id,  location.province_name, location.town_name,
water_source.type_of_water_source
 from 
visits 
join location on visits.location_id = location.location_id
join water_source on visits.source_id = water_source.source_id
WHERE visits.visit_count = 1;
-- SLIDE 8 Add the location_type column from location and time_in_queue from visits to our results 
select  visits.time_in_queue, water_source.number_of_people_served, 
location.location_type,  location.province_name, location.town_name,
water_source.type_of_water_source
 from 
visits 
join location on visits.location_id = location.location_id
join water_source on visits.source_id = water_source.source_id
WHERE visits.visit_count = 1;
-- --slide 9 and 
SELECT
water_source.type_of_water_source,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
 left JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;
-- slide 10
CREATE VIEW combined_analysis_table AS
SELECT
water_source.type_of_water_source AS source_type,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served AS people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;

-- We're building another pivot table! This time, we want to break down our data into provinces or towns and source types. If we understand where
-- the problems are, and what we need to improve at those locations, we can make an informed decision on where to send our repair teams

with province_totals as ( 
select
province_name,  sum(people_served) as Total_ppl_serv
from combined_analysis_table
group by province_name)
select ct.province_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;
-- province_totals is a CTE that calculates the sum of all the people surveyed grouped by province. If you replace the query above with this one:
with province_totals as ( 
select
province_name,  sum(people_served) as Total_ppl_serv
from combined_analysis_table
group by province_name)
SELECT
*
FROM
province_totals;
-- We join the province_totals table to our combined_analysis_table so that the correct value for each province's 
-- pt.total_ppl_serv value is
-- used.
-- Finally we group by province_name to get the provincial percentages.
with province_totals as ( 
select
province_name,  sum(people_served) as Total_ppl_serv
from combined_analysis_table
group by province_name)
select ct.province_name, total_ppl_serv,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;
-- Let's aggregate the data per town now. You might think this is simple,
--  but one little town makes this hard. Recall that there are two towns in Maji
-- Ndogo called Harare. One is in Akatsi, and one is in Kilimani.
--  Amina is another example. So when we just aggregate by town, SQL doesn't distinguish
-- between the different Harare's, so it combines their results.
-- To get around that, we have to group by province first, then by town, 
-- so that the duplicate towns are distinct because they are in different towns.
WITH town_totals AS (
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN 
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY 
ct.province_name,
ct.town_name
ORDER BY
ct.province_name;
-- return 3 rows only
WITH town_totals AS (
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name
FROM
combined_analysis_table ct
JOIN 
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY 
ct.province_name,
ct.town_name
ORDER BY
ct.province_name;
-- Temporary tables in SQL are a nice way to store the results of a complex query. We run the query once, and the results are stored as a table. The
-- catch? If you close the database connection, it deletes the table, so you have to run it again each time you start working in MySQL. The benefit is
-- that we can use the table to do more calculations, without running the whole query each time.
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN 
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY 
ct.province_name,
ct.town_name
ORDER BY
ct.province_name;
select * from town_aggregated_water_access;
-- which town has the highest ratio of people who have taps, but have no running water?
SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access;
--   slide 26 to slide 28Our final goal is to implement our plan in the database.
-- We have a plan to improve the water access in Maji Ndogo, so we need to think it through, and as our final task, create a table where our teams
-- have the information they need to fix, upgrade and repair water sources. They will need the addresses of the places they should visit (street
-- address, town, province), the type of water source they should improve, and what should be done to improve it.
-- We should also make space for them in the database to update us on their progress. We need to know if the repair is complete, and the date it was
-- completed, and give them space to upgrade the sources. Let's call this table Project_progress.
CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE,
Comments TEXT
);
-- first, let's filter the data to only contain sources we want to improve by thinking through the logic first.
-- 1. Only records with visit_count = 1 are allowed.
-- 2. Any of the following rows can be included:
-- a. Where shared taps have queue times over 30 min.
-- b. Only wells that are contaminated are allowed -- So we exclude wells that are Clean
-- c. Include any river and tap_in_home_broken sources.
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
where visits.visit_count =1
and ( visits.time_in_queue >=30 and water_source.type_of_water_source = 'shared_tap'
or well_pollution.results != "clean"  
or water_source.type_of_water_source in("river", "tap_in_home_broken"));
-- Step 1: Wells
-- Let's start with wells. Depending on whether they are chemically contaminated, or biologically contaminated — we'll decide on the interventions.
-- Use some control flow logic to create Install UV filter or Install RO filter values in the Improvement column where the results of the pollution
-- tests were Contaminated: Biological and Contaminated: Chemical respectively. Think about the data you'll need, and which table to find
-- it in. Use ELSE NULL for the final alternative.
-- If you did it right, there should be Install RO filter and Install UV and RO filter values in the Improvements column now, and lots of NULL
-- values.
-- Rivers
-- Now for the rivers. We upgrade those by drilling new wells nearby.
-- Add Drill well to the Improvements column for all river sources.
-- Check your records to make sure you see Drill well for river sources.
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source as source_type,
well_pollution.results,
case 
when well_pollution.results ='Contaminated: Chemical' then 'install ROfilter'
when well_pollution.results ='Contaminated: Biological' then "install UV filter and RO filter"
when water_source.type_of_water_source = 'river' then 'drill well'
when water_source.type_of_water_source = 'shared_tap'  THEN CONCAT("Install ", FLOOR(time_in_queue / 30), " taps nearby")
when water_source.type_of_water_source = 'tap_in_home_broken' then 'diagnose local infrastructure'
ELSE NULL
end as improvements
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
where visits.visit_count =1
and ( visits.time_in_queue >=30 and water_source.type_of_water_source = 'shared_tap'
or well_pollution.results != "clean"  
or water_source.type_of_water_source in("river", "tap_in_home_broken"));
-- Add the data to Project_progress
-- Now that we have the data we want to provide to engineers, populate the Project_progress table with the results of our query.
-- HINT: Make sure the columns in the query line up with the columns in Project_progress. If you make any mistakes, just use DROP TABLE
-- project_progress, and run your query again.
truncate md_water_services.project_progress;
insert into md_water_services.project_progress (Project_id, 
source_id, Address, Town, Province, Source_type, 
Improvement, Source_status, Date_of_completion, Comments)
(SELECT
NULL as Project_id,
water_source.source_id as source_id,
location.address as Address,
location.town_name as town,
location.province_name as province,
water_source.type_of_water_source as source_type,

case 
when well_pollution.results ='Contaminated: Chemical' then 'install ROfilter'
when well_pollution.results ='Contaminated: Biological' then "install UV filter and RO filter"
when water_source.type_of_water_source = 'river' then 'drill well'
when water_source.type_of_water_source = 'shared_tap'  THEN CONCAT("Install ", FLOOR(time_in_queue / 30), " taps nearby")
when water_source.type_of_water_source = 'tap_in_home_broken' then 'diagnose local infrastructure'
ELSE NULL
end as improvement,
'backlog'as Source_status,
    NULL as Date_of_completion,
    NULL as Comments
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
where visits.visit_count =1
and ( visits.time_in_queue >=30 and water_source.type_of_water_source = 'shared_tap'
or well_pollution.results != "clean"  
or water_source.type_of_water_source in("river", "tap_in_home_broken"))
);
 