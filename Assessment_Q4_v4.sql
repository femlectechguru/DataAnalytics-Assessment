WITH customer_clv_data AS (
    SELECT 
        u.id AS customer_id,
        COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name)) AS name,
        TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) AS tenure_months,
        COUNT(s.id) AS total_transactions,
        SUM(s.confirmed_amount) / 100 AS total_transaction_value,
        (SUM(s.confirmed_amount) * 0.001) / 100 AS avg_profit_per_transaction -- 0.1% of transaction value
    FROM 
        users_customuser u
    LEFT JOIN 
        savings_savingsaccount s 
        ON u.id = s.owner_id 
        AND s.confirmed_amount > 0 
    GROUP BY 
        u.id, name, tenure_months
)
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    ROUND((total_transactions / NULLIF(tenure_months, 0)) * 12 * avg_profit_per_transaction, 2) AS estimated_clv
FROM 
    customer_clv_data
ORDER BY 
    estimated_clv DESC;
