Microsoft Entra Connect Sync using user accounts instead of service principals creates security vulnerabilities. Legacy user account authentication with passwords is more susceptible to credential theft and password attacks than service principal authentication with certificates. Compromised connector accounts allow threat actors to manipulate identity synchronization, create backdoor accounts, escalate privileges, or disrupt hybrid identity infrastructure.  

**Remediation action**

- [Configure service principal authentication for Entra Connect](https://learn.microsoft.com/entra/identity/hybrid/connect/authenticate-application-id?tabs=default&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#onboard-to-application-based-authentication)
- [Remove legacy Directory Synchronization Accounts](https://learn.microsoft.com/entra/identity/hybrid/connect/authenticate-application-id?tabs=default&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#remove-a-legacy-service-account)
<!--- Results --->
%TestResult%

