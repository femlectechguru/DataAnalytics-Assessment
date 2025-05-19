SELECT  
    u.id AS owner_id,
    COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name)) AS name,
    COUNT(DISTINCT s.id) AS savings_count,
    COUNT(DISTINCT p.id) AS investment_count,
    ROUND((SUM(s.confirmed_amount) + SUM(p.amount)) / 100, 2) AS total_deposits
FROM 
    users_customuser u
LEFT JOIN 
    savings_savingsaccount s 
    ON u.id = s.owner_id 
    AND s.confirmed_amount > 0 
    AND s.plan_id IN (SELECT id FROM plans_plan WHERE is_regular_savings = 1)
LEFT JOIN 
    plans_plan p 
    ON u.id = p.owner_id 
    AND p.is_a_fund = 1
    AND p.amount > 0
GROUP BY 
    u.id, name
HAVING 
    savings_count > 0 AND investment_count > 0
ORDER BY 
    total_deposits DESC;
