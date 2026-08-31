-- paste the following into `PSQL Tool`, with the CORRECT file path
\copy hospital_records FROM 'C:\Users\...\hospital_records.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy appointment_analysis FROM 'C:\Users\...\appointment_analysis.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy lab_results FROM 'C:\Users\...\lab_results.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy outpatient_visits FROM 'C:\Users\...\outpatient_visits.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy patients_table FROM 'C:\Users\...\patients_table.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- check tables are fine
SELECT COUNT(*) FROM hospital_records;
SELECT COUNT(*) FROM appointment_analysis;
SELECT COUNT(*) FROM lab_results;
SELECT COUNT(*) FROM outpatient_visits;
SELECT COUNT(*) FROM patients_table;

SELECT * FROM hospital_records LIMIT 10;
SELECT * FROM appointment_analysis LIMIT 10;
SELECT * FROM lab_results LIMIT 10;
SELECT * FROM outpatient_visits LIMIT 10;
SELECT * FROM patients_table LIMIT 10;
