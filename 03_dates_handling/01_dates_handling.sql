-- get the current date and time
SELECT LOCALTIMESTAMP AS today;

/*
beware that in SQL Server, GETDATE() is available, while PostgreSQL offers LOCALTIMESTAMP
both return a time stamp without time zone information e.g., '2026-08-25 13:14:44.397821'
alternatively, NOW() or CURRENT_TIMESTAMP are available in PostgreSQL
both return a time stamp with time zone information e.g., '2026-08-25 13:14:44.397821+00'
additionally, CURRENT_DATE just returns the date
*/

-- extract the day of the week from the "appointment_date" column in integer
SELECT
    appointment_date,
    DATE_PART('DOW', appointment_date) + 1 AS day_of_the_week
FROM
    appointment_analysis;
/*
beware that SQL Server's equivalent function is written as DATEPART()
SQL Server's DATEPART() uses two augments
the first one (interval) is the output that you want the query to retrieve (e.g., weekdays)
the second argument (date) is the column you're retrieving the information from
in PostgreSQL, DATE_PART()'s arguments are named field and source, respectively 
beware that in PostgreSQL's DATE_PART(), field must be quoted
some keywords carry over differently between SQL Server and PostgreSQL
SQL Server's DAYOFYEAR, WEEKDAY, HH, MI, and SS, become DOY, DOW, HOUR, MINUTE, SECOND in PostgreSQL, respectively
in addition to DATE_PART(), PostgreSQL offers EXTRACT e.g., EXTRACT(DOW FROM appointment_date)
beware that in PostgreSQL's EXTRACT(), the field argument is written as an identifier (i.e., not quoted)
last, PostgreSQL assigns 1 to Monday, 2 to Tuesday, ... 6 to Saturday, and 0 to Sunday
in contrast, SQL Server assigns 2 to Monday, 3 to Tuesday, ... 7 to Saturday, and 1 to Sunday
*/

-- extract the hour from the "appointment_time" column
SELECT
    appointment_date,
    DATE_PART('HOUR', appointment_time) AS appointment_hour
FROM
    appointment_analysis;

-- extract the day of the week from the "appointment_date" column in character strings
SELECT
    appointment_date,
    TRIM(TO_CHAR(appointment_date, 'Day')) AS day_of_the_week
FROM
    appointment_analysis;
/*
SQL Server's equivalent function to PostgreSQL's TO_CHAR()/EXTRACT is DATENAME(), which uses the same arguments as DATEPART()
DATENAME() can return either a name (e.g., for MONTH) or a number (e.g., 23 for DAY), however, both are returned as a string
PostgreSQL splits this behavior into two different tools depending on whether you want a name or a number-as-text
use TO_CHAR() for named parts (month, weekday), use EXTRACT for numeric parts (hour, day, year)
if you need a numeric part as text, use CAST(EXTRACT() AS TEXT)
TO_CHAR() uses format patterns rather than keywords: the casing of the pattern controls the casing of the output
e.g., 'Day' returns 'Monday', 'DAY' returns 'MONDAY', 'day' returns 'monday', 'Dy' returns 'Mon', 'dy' returns 'mon'
beware that TO_CHAR()'s month and day patterns are blank-padded to 9 characters by default
for instance, 'August' actually comes back as 'August ' with trailing spaces)
to address this issue, wrap the function in TRIM()
*/

-- retrieve the amount of days between January 1st 2024 and January 10th 2024
SELECT
    (DATE '2024-01-10' - DATE '2024-01-01') AS date_difference;
/*
while SQL features DATEDIFF(), PostgreSQL uses direct subtraction for day counts
still, when subtracting literal dates directly in SQL (rather than referencing a column that's already typed as date or timestamp)...
... PostgreSQL requires these dates to be explicitly casted
plus, the later date should come first to get a positive "days elapsed" count
*/

-- retrieve the number of months between January 1st 2023 and May 10th 2024
SELECT
    (DATE '2024-05-01' - DATE '2023-01-01') / 30 AS date_difference;

-- calculate the difference between the arrival time and appointment time in minutes
SELECT
    appointment_time,
    arrival_time,
    ROUND((EXTRACT(EPOCH FROM (appointment_time - arrival_time)) / 60), 0) AS minutes_difference
FROM
    appointment_analysis;
/*
subtracting (columns storing a) timestamp rather than plain date returns an interval
the desired unit can be pulled out with EXTRACT(EPOCH FROM interval), providing the total difference in seconds
dividing by 60 converts to minutes, dividing by 3600 converts to hours
*/

/*
(CURRENT_DATE - date_of_birth) / 365 divides an integer number of days by an integer 365...
... so PostgreSQL performs integer division and truncates the decimal; e.g., 49.9 years becomes 49, not rounded
that's usually the desired behavior for "age in completed years"
however, if you ever want a more precise age (accounting for leap years), the age() function would be the more calendar-accurate choice
EXTRACT(YEAR FROM age(date_of_birth)) AS age
*/