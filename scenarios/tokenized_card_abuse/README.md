### Threat Overview: 

Unauthorised access manifested via digital fingerprint change followed by exploitation of stored payment methods and tokenised payment process. 

In tokenised card abuse, fraudsters who gain unauthorised access to an active account inherit immediate payment capability without needing to add new cards or re-authenticate. Stored payment methods and tokenised card credentials allow one-click transactions, enabling rapid fund extraction against cards already trusted by the platform.

Unlike dormant account ATO where the attacker must onboard new payment methods, this scenario targets accounts with active financial history — meaning cards are verified, limits are established, and transaction patterns are familiar to detection systems. The attack window is short and the damage is often irreversible: with real-time payments, funds can be extracted within minutes, frequently before the legitimate account holder receives a notification or can act on it.

The financial impact can run into significant amounts per incident, and the speed of execution makes intervention extremely difficult.


### Detection Logic: 

The query models fingerprint change, geographic inconsistency, rapid financial activity/card draining within 30 minutes

### Limitations: 

* requires both country AND device change simultaneously
* geographic velocity/impossible travel is not assessed
* 30-minute window is intentionally narrow - in this particular scenario it reflects fast-extraction scenario and may miss slower-paced exploitation
* does not cover new payment method addition or withdrawals

