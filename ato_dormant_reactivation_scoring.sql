-- CTE 1 Seeds pipeline with today's active users only
-- Input: logins, users
-- Output: user_id
WITH recent_active_users AS (
  SELECT 
        l.user_id
  FROM logins l 
  JOIN users u ON l.user_id = u.user_id
  WHERE l.login_datetime > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
  AND u.country = 'Mordor'
),
--CTE 2 Identifies users with reactivation event after a long period of dormancy (12+ months)
-- Input: recent_active_users, logins
-- Output: user_id, prev_login_datetime/recent_login_datetime, login_gap, prev_useragent/recent_useragent
reactivation_event AS (
  SELECT  
        l.user_id,
        LAG(l.login_datetime) OVER(PARTITION BY l.user_id ORDER BY l.login_datetime) AS prev_login_datetime,
        l.login_datetime AS recent_login_datetime,
        DATETIME_DIFF(l.login_datetime, LAG(l.login_datetime) OVER(PARTITION BY l.user_id ORDER BY l.login_datetime), MONTH) AS login_gap,
        LAG(l.useragent) OVER(PARTITION BY l.user_id ORDER BY l.login_datetime) AS prev_useragent,
        l.useragent AS recent_useragent
  FROM recent_active_users rac
  JOIN logins l ON rac.user_id = l.user_id
  QUALIFY login_gap >= 12
),
-- CTE 3 Enriches with financial data
-- Input: reactivation_event, deposits, payment_methods
-- Output: user_id, deposit_count, failed_deposit_count, previous_card_count, new_card_count, total_amount
-- Note: previous_card_count, new_card_count will be used for risk scoring; previous_card_count specifically eliminates users depositing with their previously added cards
financials AS (
  SELECT
        re.user_id,
        COUNT(d.deposit_id) AS deposit_count,
        COUNT(CASE WHEN d.status = 'failed' THEN 1 END) AS failed_deposit_count,
        COUNT(DISTINCT CASE
                  WHEN pm.registered_at < re.recent_login_datetime
                  THEN pm.card_number_masked END) AS previous_card_count,
        COUNT(DISTINCT CASE
                  WHEN pm.registered_at BETWEEN re.recent_login_datetime
                  AND TIMESTAMP_ADD(re.recent_login_datetime, INTERVAL 24 HOUR)
                  THEN pm.card_number_masked END) AS new_card_count,
        SUM(d.amount) AS total_amount
  FROM reactivation_event re
  JOIN deposits d ON re.user_id = d.user_id
  LEFT JOIN payment_methods pm ON re.user_id = pm.user_id AND d.card_number_masked = pm.card_number_masked
  WHERE d.created_at BETWEEN re.recent_login_datetime AND TIMESTAMP_ADD(re.recent_login_datetime, INTERVAL 24 HOUR) 
  AND d.payment_method IN ('debit card', 'credit card')
  GROUP BY re.user_id
),
-- CTE 4 Scores risk 
-- Input: reactivation_event, financials
-- Output: user_id, recent_login_datetime, deposit_count, new_card_count, total_amount, risk_score
-- Note: the columns listed along user_id and risk_score are selected to help a reviewer to understand the scoring logic
scoring AS (
  SELECT
      re.user_id,
      re.recent_login_datetime,
      f.deposit_count,
      f.failed_deposit_count,
      f.new_card_count,
      f.total_amount,
      (CASE 
          WHEN COALESCE(re.prev_useragent, 'unknown') != COALESCE(re.recent_useragent, 'unknown') THEN 1 
          ELSE 0 
      END +
      CASE 
          WHEN f.new_card_count > 1 THEN 2 
          ELSE 1 
      END +
      CASE 
         WHEN f.deposit_count <= 5 THEN 1 
         WHEN f.deposit_count > 5 THEN 2
         ELSE 0
      END +
      CASE 
         WHEN f.failed_deposit_count > 2 THEN 1 
         ELSE 0 
      END) AS risk_score
  FROM reactivation_event re
  JOIN financials f ON re.user_id = f.user_id
  WHERE f.deposit_count >= 1
  AND f.previous_card_count = 0
  AND f.new_card_count >= 1
)
-- Final Query Labels risk as 'high', 'medium', 'monitoring'
-- Input: scoring
-- Output: all columns from scoring and risk_tier (ordered by priority)
SELECT
      *,
      CASE
        WHEN risk_score >= 6 THEN 'high'
        WHEN risk_score >= 4 THEN 'medium'
        ELSE 'monitoring'
      END AS risk_tier
FROM scoring
ORDER BY risk_score DESC
;

-- Sample Output:
-- | user_id | recent_login_datetime| deposit_count | failed_deposit_count | new_card_count| total_amount | risk_score | risk_tier  |
-- |---------|----------------------|---------------|---------------------|----------------|--------------|------------|------------|
-- | 10042   | 2024-03-15 09:23:00  | 7             | 3                   | 2              | 6850.00      | 6          | high       |
-- | 10187   | 2024-03-15 11:45:00  | 4             | 1                   | 2              | 3200.00      | 4          | medium     |
-- | 10391   | 2024-03-15 14:12:00  | 3             | 0                   | 1              | 1750.00      | 4          | medium     |
-- | 10056   | 2024-03-15 16:30:00  | 2             | 0                   | 1              | 890.00       | 3          | monitoring |
