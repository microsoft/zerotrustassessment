When applications that support both authentication and provisioning through Microsoft Entra aren't configured for automatic provisioning, organizations become vulnerable to identity lifecycle gaps that threat actors can exploit. Without automated provisioning, user accounts might persist in applications after employees leave the organization. This vulnerability creates dormant accounts that threat actors can discover through reconnaissance activities. These orphaned accounts often retain their original access permissions but lack active monitoring, making them attractive targets for initial access.

Threat actors who gain access to these dormant accounts can use them to establish persistence in the target application, as the accounts appear legitimate and might not trigger security alerts. From these compromised application accounts, attackers can:

- Attempt to escalate their privileges by exploring application-specific permissions
- Access sensitive data stored within the application
- Use the application as a pivot point to access other connected systems

The lack of centralized identity lifecycle management also makes it difficult for security teams to detect when an attacker is using these orphaned accounts, as the accounts might not be properly correlated with the organization's active user directory. 

**Remediation action**

- [Configure application provisioning for missing applications](https://learn.microsoft.com/en-us/entra/identity/app-provisioning/configure-automatic-user-provisioning-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

