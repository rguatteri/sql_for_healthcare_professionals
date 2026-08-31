SELECT
    appointment_time,
    COUNT(DISTINCT visit_id) AS visit_count
FROM
    appointment_analysis
GROUP BY
    appointment_time
ORDER BY
    visit_count DESC;

SELECT
    EXTRACT(HOUR FROM appointment_time) AS visit_hour,
    COUNT(DISTINCT visit_id) AS visit_count
FROM
    appointment_analysis
GROUP BY
    visit_hour
ORDER BY
    visit_count DESC;
