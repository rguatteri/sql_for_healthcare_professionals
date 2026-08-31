SELECT
    risk_category,
    COUNT(*) AS patient_count
FROM (
    SELECT
        patient_id,
        CASE
            WHEN MAX(smoker_status) = 'Y' AND BOOL_OR(diagnosis IN ('Diabetes', 'Hypertension')) THEN 'High Risk'
            WHEN MAX(smoker_status) = 'N' AND BOOL_OR(diagnosis IN ('Diabetes', 'Hypertension')) THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_category
    FROM
        outpatient_visits
    GROUP BY
        patient_id
) AS patient_risk
GROUP BY
    risk_category
ORDER BY
    patient_count DESC;
