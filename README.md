### DATA ANALYTICS - ASSESSMENT
 
## OVERVIEW
This repository contains SQL queries designed for a data analytics assessment, focusing on customer insights and transaction analysis.

## STRUCTURE

DataAnalytics-Assessment/
│
├── Assessment_Q1.sql        1 High-Value Customers with Multiple Products
├── Assessment_Q2.sql        2 Transaction Frequency Analysis
├── Assessment_Q3.sql        3 Account Inactivity Alert
├── Assessment_Q4.sql        4 Customer Lifetime Value (CLV) Estimation
│
└── README.md
```

## HOW TO USE

1. Clone this repository:

   ```bash
   git clone https://github.com/femlectechguru/DataAnalytics-Assessment.git
   ```
2. Import the .sql files into your database environment (e.g., MySQL, DBeaver).

3. Run each .sql file in the specified order.

## REQUIREMENTS
- MySQL Server (Version: 8.0+ recommended)
- DBeaver or any other SQL client (optional)


## EXPLANATIONS

### Q1: High-Value Customers with Multiple Products

- **Approach**:Identified customers with at least one funded savings and one funded investment plan.
- **SQL Explanation**:Used INNER JOIN to combine savings and investment data, and calculated the total deposits using SUM.
- **STEP BY STEP QUERY GUIDE** 
- **SELECT Clause:**
`SELECT u.id as owner_id`: This uniquely identifies the customer.

`COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name)) as name:`

If the name column is null, it combines the first and last name.

`COUNT(DISTINCT s.id) as savings_count:` Counts unique savings account entries for each customer.

`COUNT(DISTINCT p.id) as investment_count:` Counts unique investment plans for each customer.

`ROUND((SUM(s.confirmed_amount) + SUM(p.amount)) / 100, 2) as total_deposits:` Adds the total of confirmed savings and investment amounts. The /100 is used because the amounts are in kobo (minor currency unit), converting them to naira.

The ROUND function ensures the value is rounded to two decimal places.

- **LEFT JOIN on Savings:**

```
LEFT JOIN savings_savingsaccount s 
ON u.id = s.owner_id 
AND s.confirmed_amount > 0 
AND s.plan_id IN (SELECT id FROM plans_plan WHERE is_regular_savings = 1)
```
We use LEFT JOIN to ensure all users are included, even if they don't have savings (but we filter later).

I ensured the savings are funded `(confirmed_amount > 0)`.

The `s.plan_id` must match a plan `from plans_plan where is_regular_savings = 1`, which means it is a savings plan.

- **LEFT JOIN on Investment:**
```
LEFT JOIN plans_plan p 
ON u.id = p.owner_id 
AND p.is_a_fund = 1
AND p.amount > 0
```
I use another LEFT JOIN for investments:

It must be marked as a fund `(is_a_fund = 1)`.

It must have a funded amount `(amount > 0)`.

- **GROUP BY Clause:**

`GROUP BY u.id, name`
This ensures the results are grouped by each customer, providing a unique row for each.

- **HAVING Clause:**

`HAVING savings_count > 0 AND investment_count > 0`
Only customers with at least one funded savings and one funded investment are included.

- **ORDER BY Clause:**
`ORDER BY total_deposits DESC;`
Customers are sorted by their total deposits in descending order.


### Q2: Transaction Frequency Analysis

Approach:Calculated average monthly transactions for each customer and categorized them.
SQL Explanation:Used GROUP BY to calculate transaction counts and categorized frequency using CASE statements.

- **Step 1: Calculate Monthly Transactions using CTE (Common Table Expression)**
```
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
```
I create a CTE (monthly_transactions) for cleaner and more efficient code.

`COUNT(s.id):` Counts the total transactions for each customer.

`TIMESTAMPDIFF(MONTH, MIN(u.created_on), CURDATE()):` Calculates the account tenure in months from the account creation date (u.created_on) to the current date (CURDATE()).

`COUNT(s.id) / TIMESTAMPDIFF(MONTH, MIN(u.created_on), CURDATE()):` This gives the average number of transactions per month.

`COALESCE:` Combines the full name (u.name) with the first and last name if u.name is null.

- **Step 2: Categorize Customers by Transaction Frequency**
```
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
```

We categorize customers based on their average transactions per month:

- High Frequency: ≥ 10 transactions/month.

- Medium Frequency: 3 - 9 transactions/month.

- Low Frequency: ≤ 2 transactions/month.

`COUNT(customer_id):` Counts the number of customers in each category.

`AVG(avg_transactions_per_month):` Calculates the average of these monthly transaction values per category.

`ROUND:` Rounds the average value to two decimal places for better presentation.


### Q3: Account Inactivity Alert

- **Approach:** Identified accounts without any inflow transactions for over one year.
SQL Explanation:Checked for last transaction dates using MAX(transaction_date) and filtered by DATEDIFF.

- **Step 1: Calculate Inactivity for Savings Accounts**
```
WITH inactive_savings AS (
    SELECT 
        s.plan_id AS plan_id,
        s.owner_id,
        'Savings' AS type,
        MAX(s.transaction_date) AS last_transaction_date,
        DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days
    FROM 
        savings_savingsaccount s
    WHERE 
        s.confirmed_amount > 0
    GROUP BY 
        s.plan_id, s.owner_id
    HAVING 
        inactivity_days > 365
)
```
`MAX(s.transaction_date):` Finds the most recent transaction date for each savings account.

`DATEDIFF(CURDATE(), MAX(s.transaction_date)):` Calculates the number of days since the last transaction.

`HAVING inactivity_days > 365:` Filters accounts with more than 365 days of inactivity.

`s.confirmed_amount > 0:` Ensures we are only considering funded transactions.

- **Step 2: Calculate Inactivity for Investment Accounts**
```
inactive_investments AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        'Investment' AS type,
        MAX(p.last_charge_date) AS last_transaction_date,
        DATEDIFF(CURDATE(), MAX(p.last_charge_date)) AS inactivity_days
    FROM 
        plans_plan p
    WHERE 
        p.is_a_fund = 1 
        AND p.amount > 0
    GROUP BY 
        p.id, p.owner_id
    HAVING 
        inactivity_days > 365
)
```
This CTE works similarly to the savings section but focuses on investment plans:

`p.is_a_fund = 1` ensures we are only considering investment plans.

`MAX(p.last_charge_date):` Finds the most recent charge date for each investment plan.

`HAVING inactivity_days > 365:` Filters for plans inactive for more than one year.

- **Step 3: Combine Inactive Accounts**
```
SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    inactivity_days
FROM 
    inactive_savings
UNION ALL
SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    inactivity_days
FROM 
    inactive_investments
ORDER BY 
    inactivity_days DESC;
```
I use `UNION ALL` to combine the inactive savings and investment accounts:

`UNION ALL` (not just UNION) is used to retain any duplicate entries (unlikely, but for completeness).

`ORDER BY inactivity_days DESC:` Sorts the output by the highest inactivity days to the lowest.


### Q4: Customer Lifetime Value (CLV) Estimation

- **Approach:** Calculated CLV using transaction volume, tenure, and a profit percentage.
SQL Explanation:Calculated tenure using TIMESTAMPDIFF and avoided division by zero using NULLIF.

- **Step 1: Calculate Basic Customer Metrics**
```
WITH customer_clv_data AS (
    SELECT 
        u.id AS customer_id,
        COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name)) AS name,
        TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) AS tenure_months,
        COUNT(s.id) AS total_transactions,
        SUM(s.confirmed_amount) / 100 AS total_transaction_value,
        (SUM(s.confirmed_amount) * 0.001) / 100 AS avg_profit_per_transaction
    FROM 
        users_customuser u
    LEFT JOIN 
        savings_savingsaccount s 
        ON u.id = s.owner_id 
        AND s.confirmed_amount > 0 
    GROUP BY 
        u.id, name, tenure_months
)
```
`TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()) AS tenure_months:` Calculates how many months each customer has been active.

`COUNT(s.id) AS total_transactions:` Counts the number of transactions made by the customer.

`SUM(s.confirmed_amount) / 100 AS total_transaction_value:` Calculates the total value of transactions (converted from kobo to naira).

`(SUM(s.confirmed_amount) * 0.001) / 100 AS avg_profit_per_transaction:` Computes the average profit per transaction at 0.1% of transaction value.

- **Step 2: Calculate Estimated CLV**

```
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
```
`ROUND((total_transactions / NULLIF(tenure_months, 0)) * 12 * avg_profit_per_transaction, 2):`

- **The CLV formula:**

`CLV =
Total Transactions/
Tenure in Months multiply by 12 multiply by
Avg Profit per Transaction`

`NULLIF(tenure_months, 0)` prevents division by zero.

`ORDER BY estimated_clv DESC:` Displays customers with the highest CLV first.



**Author**

Oluwafemi Erinle

Data Analyst




