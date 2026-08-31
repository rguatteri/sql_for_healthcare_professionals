SELECT
    CASE
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) < 18 THEN 'Pediatric'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)) BETWEEN 18 AND 64 THEN 'Adult'
        ELSE 'Senior'
    END AS age,
    gender,
    COUNT(*) AS patient_count
FROM
    patients_table
GROUP BY
    age,
    gender
ORDER BY
    MIN(EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_of_birth)));
