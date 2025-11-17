Service principals without proper authentication credentials (certificates or client secrets) create security vulnerabilities that allow threat actors to impersonate these identities. This can lead to unauthorized access, lateral movement within your environment, privilege escalation, and persistent access that's difficult to detect and remediate. 

**Remediation action**

- For your organization's service principals: [Add certificates or client secrets to the app registration](https://learn.microsoft.com/entra/identity-platform/how-to-add-credentials?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- For external service principals: Review and remove any unnecessary credentials to reduce security risk
<!--- Results --->
%TestResult%

