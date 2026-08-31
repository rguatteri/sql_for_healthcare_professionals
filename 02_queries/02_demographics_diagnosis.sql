SELECT
    CASE
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, patients.date_of_birth)) < 18 THEN 'Pediatric'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, patients.date_of_birth)) BETWEEN 18 AND 64 THEN 'Adult'
        ELSE 'Senior'
    END AS age,
    patients.gender,
    visits.diagnosis,
    COUNT(*) AS patient_count
FROM
    patients_table AS patients
INNER JOIN
    outpatient_visits AS visits
    ON
    patients.patient_id = visits.patient_id
-- WHERE
--     visits.diagnosis != 'N/A'
GROUP BY
    age,
    patients.gender,
    visits.diagnosis
ORDER BY
    patient_count DESC
-- LIMIT 5;
