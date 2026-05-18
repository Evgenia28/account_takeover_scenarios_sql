### ato_dormant_reactivation_scoring.sql
### What: 
Account Takeover (ATO) is a form of cybercrime in which a malicious actor gains the same access and permissions as the legitimate account holder. By impersonating a trusted user, attackers can bypass standard security checks and use these accounts to move illicit funds or drain existing balances. 

### Manifestation: 
Operationally, these attacks can manifest as new or anomalous logins followed by behavioural shifts, such as adding new payment methods or cards and rapidly draining funds within a short timeframe.

### Description: 
#### This synthetic SQL study models the following ATO scenario:
	• Reactivation after long dormancy
	• Device or digital fingerprint change
	• New card onboarding
	• Rapid financial activity

### Limitations:
#### This SQL study focuses on the aspects outlined above. It does not currently cover:
	• Geographic inconsistencies
	• Device or cross-account linkage
	• IP anomalies
	• All post-reactivation transactions
#### The schema is synthetic, and there is no population baseline to assess false positives. In an operational setting, false positives may arise from:
	• Legitimate travel or device changes
	• Shared environments
	• VPN usage
	• Legitimate account detail updates (address, phone) triggering anomaly flags
Scoring thresholds are illustrative and would require calibration against real population data to minimise false positives.

