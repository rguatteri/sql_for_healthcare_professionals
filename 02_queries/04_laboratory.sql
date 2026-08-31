SELECT
    test_name,
    COUNT(DISTINCT result_id) AS order_count
FROM
    lab_results
GROUP BY
    test_name
ORDER BY
    order_count DESC;
