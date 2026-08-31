SELECT
    patients.patient_id,
    patients.patient_name,
    results.result_value
FROM
    lab_results AS results
INNER JOIN
    outpatient_visits AS visits
    ON
    results.visit_id = visits.visit_id
INNER JOIN
    patients_table AS patients
    ON
    visits.patient_id = patients.patient_id
WHERE
    results.test_name = 'Fasting Blood Sugar'
    AND
    (results.result_value < 70 OR results.result_value > 100)
-- ORDER BY
--     results.result_value DESC
-- LIMIT 5
;
