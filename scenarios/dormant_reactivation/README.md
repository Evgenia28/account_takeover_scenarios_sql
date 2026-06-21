### Threat Overview :

Unauthorised access to long-dormant accounts followed by new card onboarding and rapid financial activity.

Long-dormant accounts represent an attractive target for ATO attacks — extended inactivity reduces the likelihood of the legitimate account holder noticing unauthorised access quickly, providing a window for rapid fund extraction.

 ### Detection Logic: 

Identification of dormant accounts with new logins and newly added cards; risk scoring based on the login data, card addition, and financial activity within 24 hours of reactivation.

 ### Limitations:

* geographic inconsistencies are not covered
* device or cross-account linkage not being reviewed
* IP anomalies not being reviewed
* all post-reactivation transactions
