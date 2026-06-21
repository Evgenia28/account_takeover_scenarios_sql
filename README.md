### account_takeover_scenarios_sql
### A SQL case study series modelling Account Takeover fraud across operational scenarios, demonstrating detection logic applied to login, payment, and behavioural data.

### Threat Overview: 
Account Takeover (ATO) is a form of cybercrime in which a malicious actor gains the same access and permissions to an account as the legitimate account holder. By impersonating a trusted user, attackers can bypass standard security checks and use these accounts to move illicit funds or drain existing balances.

### Impact & Risk:

**Reputational Risk**: damage to brand credibility, erosion of consumer trust that may result in reduction of customer base\
**Regulatory Exposure**: non-compliance with data protection (GDPR or PCI DSS) following a breach can result in legal and financial penalties\
**Financial Liability**: companies frequently bear the brunt of refunding victims, chargeback fees\
**Operational Cost**: internal teams are required to investigate incidents, review system logs, reset credentials, and verify communication

### Key Manifestations: 

Operationally, these attacks can manifest as new or anomalous logins followed by behavioural shifts, such as adding new payment methods or cards and rapidly draining funds within a short timeframe.

### Description: 

#### This SQL study models the following ATO scenario:
* Long-dormant account reactivation with a new card onboarding followed by rapid financial activity: [ato_dormant_reactivation_scoring.sql](scenarios/dormant_reactivation/ato_dormant_reactivation_scoring.sql)
* Unauthorised access followed by exploitation of stored payment methods and tokenised payment process: [ato_tokenized_card_abuse.sql](scenarios/tokenized_card_abuse/ato_tokenized_card_abuse.sql)

### Limitations:
* Scoring thresholds are illustrative and would require calibration against real population data to minimise false positives.
* The schema is synthetic, and there is no population baseline to assess false positives. In an operational setting, false positives may arise from:\
	• Legitimate travel or device changes\
	• Shared environments\
	• VPN usage\
	• Legitimate account detail updates (address, phone) triggering anomaly flags

### SQL Concepts Demonstrated:
* Common Table Expressions (CTEs)
* Window functions: LAG for comparing current and previous values
* QUALIFY for post-window filtering
* CASE WHEN for sorting and labelling
* COUNT & CASE WHEN for approved/failed deposit aggregation
* COALESCE for null handling
* DATETIME_DIFF and TIMESTAMP_SUB for time-based analysis
* DATETIME_ADD for capturing specific time window
* Multi-table joins and aggregation
