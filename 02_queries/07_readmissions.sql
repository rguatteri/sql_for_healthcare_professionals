SELECT
    visits_initial.patient_id,
    visits_initial.visit_date AS initial_visit_date,
    visits_initial.reason_for_visit AS reason_for_initial_visit,
    visits_readmit.visit_date AS readmission_date,
    visits_readmit.reason_for_visit AS reason_for_readmission,
    (visits_readmit.visit_date - visits_initial.visit_date) AS days_between_initial_and_readmission
FROM
    outpatient_visits AS visits_initial
INNER JOIN
    outpatient_visits AS visits_readmit
    ON
    visits_initial.patient_id = visits_readmit.patient_id
WHERE
    (visits_readmit.visit_date - visits_initial.visit_date) <= 30
    AND
    visits_readmit.visit_date > visits_initial.visit_date
-- LIMIT 5
;
