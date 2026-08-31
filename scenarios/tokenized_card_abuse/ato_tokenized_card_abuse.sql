-- CTE 1 Seeds the pipeline with today's active users
-- Input: logins, users
-- Output: user_id
WITH active_logins AS (
  SELECT DISTINCT user_id
  FROM code-testing-ato.tokenized_ato_dep_test.tca_logins
  WHERE login_datetime > DATETIME_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
),
-- CTE 2: Identifies digital fingerprint change and time gap between logins
-- Input: active_logins, logins
-- Output: user_id, current_iso2, prev_iso2, current_device, prev_device, login_gap
login_change AS (
  SELECT 
         al.user_id,
         l.login_datetime AS last_login,
         l.iso2 AS current_iso2,
         LAG(l.iso2) OVER(PARTITION BY al.user_id ORDER BY l.login_datetime) AS prev_iso2,
         l.device_type AS current_device,
         LAG(l.device_type) OVER(PARTITION BY al.user_id ORDER BY l.login_datetime) AS prev_device,
         DATETIME_DIFF(l.login_datetime, LAG(l.login_datetime) OVER(PARTITION BY al.user_id ORDER BY l.login_datetime), HOUR) AS login_gap_hrs
  FROM code-testing-ato.tokenized_ato_dep_test.tca_logins l 
  JOIN active_logins al ON l.user_id = al.user_id
  QUALIFY current_iso2 != prev_iso2
  AND current_device != prev_device
  AND last_login > DATETIME_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  AND login_gap_hrs < 24       
),
-- CTE 3 Aggregates financial data, detects existing card draining
-- Input: deposits, login_change
-- Output: user_id, deposit_count, deposit_sum
financials AS (
  SELECT 
         lc.user_id,
         COUNT(CASE WHEN d.status = 'approved' THEN d.deposit_id END) AS approved_dep_count, 
         COUNT(CASE WHEN d.status = 'failed' THEN d.deposit_id END) AS failed_dep_count,
         SUM(CASE WHEN d.status = 'approved' THEN d.amount END) AS actual_total_deposit,
         SUM(amount) AS total_attempted_deposit
  FROM login_change lc
  LEFT JOIN code-testing-ato.tokenized_ato_dep_test.tca_deposits d ON lc.user_id = d.user_id
  -- Making time filter part of the matching condition in JOIN
  -- Filtering inside the ON clause evaluates the condition during the join
  AND d.dep_datetime BETWEEN lc.last_login AND DATETIME_ADD(lc.last_login, INTERVAL 30 MINUTE)
  GROUP BY lc.user_id
)
-- Final Query displays an overview of login and financials data
-- Input: CTE 2, CTE 3
SELECT 
       f.user_id,
       lc.current_iso2,
       lc.prev_iso2,
       lc.login_gap_hrs,
       lc.current_device,
       lc.prev_device,
       COALESCE(f.approved_dep_count, 0) AS approved_dep_count,
       COALESCE(f.failed_dep_count, 0) AS failed_dep_count,
       COALESCE(f.actual_total_deposit,0) AS actual_total_deposit,
       COALESCE(f.total_attempted_deposit, 0) AS total_attempted_deposit
FROM login_change lc
JOIN financials f ON lc.user_id = f.user_id
;
Sample Output:
  
| Row | user_id | current_iso2 | prev_iso2 | login_gap_hrs | current_device | prev_device | approved_dep_count | failed_dep_count | actual_total_deposit | total_attempted_deposit |
|-----|---------|--------------|-----------|---------------|----------------|-------------|--------------------|------------------|----------------------|-------------------------|
| 1   | 30001   | AU           | GB        | 16            | mobile         | desktop     | 3                  | 1                | 1600.0               | 2800.0                  |
| 2   | 30002   | DE           | GB        | 7             | mobile         | desktop     | 1                  | 0                | 150.0                | 150.0                   |
| 3   | 30003   | US           | GB        | 4             | mobile         | desktop     | 0                  | 0                | 0.0                  | 0.0                     |
