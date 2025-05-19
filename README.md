DataAnalytics-Assessment
 
Overview
This repository contains SQL queries designed for a data analytics assessment, focusing on customer insights and transaction analysis.

Structure

```
DataAnalytics-Assessment/
│
├── Assessment_Q1.sql        1 High-Value Customers with Multiple Products
├── Assessment_Q2.sql        2 Transaction Frequency Analysis
├── Assessment_Q3.sql        3 Account Inactivity Alert
├── Assessment_Q4.sql        4 Customer Lifetime Value (CLV) Estimation
│
└── README.md
```

How to Use

1. Clone this repository:

   ```bash
   git clone https://github.com/femlectechguru/DataAnalytics-Assessment.git
   ```
2. Import the .sql files into your database environment (e.g., MySQL, DBeaver).

3. Run each .sql file in the specified order.

Requirements
MySQL Server (Version: 8.0+ recommended)
DBeaver or any other SQL client (optional)


Explanations
Q1: High-Value Customers with Multiple Products

Approach:Identified customers with at least one funded savings and one funded investment plan.
Challenges:Handling cases where customer names were null; resolved using `COALESCE`.

Q2: Transaction Frequency Analysis
Approach:Calculated average monthly transactions for each customer and categorized them.
Challenges:Adjusting transaction calculations to account for varying account tenure.

Q3: Account Inactivity Alert
Approach:Identified accounts without any inflow transactions for over one year.
Challenges:Ensured accurate date calculations using `DATEDIFF`.

Q4: Customer Lifetime Value (CLV) Estimation
Approach:Calculated CLV using transaction volume, tenure, and a profit percentage.
Challenges:Avoided division by zero for customers with zero tenure using `NULLIF`.


Author
Oluwafemi Erinle
Data Analyst
