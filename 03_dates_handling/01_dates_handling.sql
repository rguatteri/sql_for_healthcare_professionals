-- get the current date and time
SELECT LOCALTIMESTAMP AS today;

-- extract the day of the week from the "appointment_date" column in integer
SELECT
    appointment_date,
    DATE_PART('DOW', appointment_date) + 1 AS day_of_the_week
FROM
    appointment_analysis;

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

-- retrieve the amount of days between January 1st 2024 and January 10th 2024
SELECT
    (DATE '2024-01-10' - DATE '2024-01-01') AS date_difference;

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
