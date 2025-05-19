WITH monthly_transactions AS (
    SELECT 
        u.id AS customer_id,
        COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name)) AS name,
        COUNT(s.id) / TIMESTAMPDIFF(MONTH, MIN(u.created_on), CURDATE()) AS avg_transactions_per_month
    FROM 
        users_customuser u
    LEFT JOIN 
        savings_savingsaccount s 
        ON u.id = s.owner_id 
        AND s.confirmed_amount > 0 
    GROUP BY 
        u.id, name
)
SELECT 
    CASE 
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(customer_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM 
    monthly_transactions
GROUP BY 
    frequency_category;
