create database Case_study5;
use Case_study5;
select * from data;
select * from localities;
Alter table data
add column New_Pickup_date date;
Set SQL_SAFE_Updates =0;
update data
set New_Pickup_date = Str_to_date(pickup_date,"%d-%m-%Y");
Alter table data
add column New_Pickup_time time;
Alter table data
drop column New_Pickup_time;
Alter table data
add column New_Pickup_datetime datetime;
Set SQL_SAFE_Updates =0;
UPDATE data
SET New_Pickup_datetime = Str_to_date(pickup_datetime, '%d-%m-%Y %H:%i');

Alter table data
add column New_Confirmed_at datetime;
Set SQL_SAFE_Updates =0;
UPDATE data
SET New_Confirmed_at = Str_to_date(Confirmed_at, '%d-%m-%Y %H:%i');

-- 1. Make a table with count of bookings with booking_type = p2p catgorized by booking mode as 'phone', 'online','app',etc	

select Booking_type,Booking_mode,count(*) as Total_booking
from data
where Booking_type ="p2p"
group by Booking_mode;

-- 2. Find top 5 drop zones in terms of  average revenue.

select l.Zone_id, Avg(fare) as AvgRevenue
from data as d inner join  localities as l ON l.Area = d.DropArea
group by Zone_id
order by 2 desc
limit 5;

-- 3. Find all unique driver numbers grouped by top 5 pickzones	

Create View Top5PickZones As
SELECT zone_id, Sum(fare) as SumRevenue
FROM Data as D, Localities as L
WHERE D.pickuparea = L.Area
Group By Zone_id
Order By 2 DESC
Limit 5;

select * from Top5PickZones;

SELECT Distinct zone_id, driver_number
FROM localities as L INNER JOIN Data as D ON L.Area = D.PickupArea
WHERE zone_id IN (Select Zone_id FROM Top5PickZones)
order by 1, 2;


-- 6. Make a hourwise table of bookings for week between Nov01-Nov-07 and highlight the hours with more than average no.of bookings day wise.

-- part-1(Hour wise booking)

SELECT Hour(str_To_date(pickup_time,"%H:%i:%s")) as Hr, Count(*) as TotalBookings
FROM Data 
WHERE New_pickup_date between '2013-11-01' and '2013-11-07'
Group By Hour(str_to_date(pickup_time,"%H:%i:%s"))
Order by 1;

-- part-2(Avg daily booking)

SELECT Avg(NoOfBookingsDaily)
FROM (
SELECT Day(New_pickup_date), count(*) as NoOfBookingsDaily
FROM data 
Group By Day(New_pickup_date)) as tt;

-- Combined - Part 1 & Part 2

SELECT Hour(str_To_date(pickup_time,"%H:%i:%s")) as Hr, Count(*) as TotalBookings
FROM Data 
WHERE New_pickup_date between '2013-11-01' and '2013-11-07'
Group By Hour(str_to_date(pickup_time,"%H:%i:%s"))
HAVING Count(*) > (SELECT Avg(NoOfBookingsDaily)
FROM (
SELECT Day(New_pickup_date), count(*) as NoOfBookingsDaily
FROM data 
Group By Day(New_pickup_date)) as tt)
Order By 1 ASC;

