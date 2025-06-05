Without Tenant Restrictions v2 (TRv2), organizations unauthorized exfiltration of corporate data to external Microsoft Entra tenants using local accounts, leading to potential data exfiltration and compliance violations. Threat actors can exploit this by conducting reconnaissance to identify accessible external tenants, followed by credential harvesting through phishing or other means, which can succeed if those external tenants have weaker controls. Once credentials are obtained, they can gain initial access to these external tenants. Without TRv2, there's no mechanism to prevent users from authenticating to unauthorized tenants, allowing threat actors to move laterally, escalate privileges, and potentially exfiltrate sensitive data, all while appearing as legitimate user activity that bypasses traditional data loss prevention controls focused on internal tenant monitoring. Implementing TRv2 enforces policies that restrict access to specified tenants, mitigating these risks by ensuring that authentication and data access are confined to authorized tenants only. 

Note that this check passing means that the policy is in place. This policy is a pre-requisite for TRv2 to work, however more steps are required to validate the scenario end to end.

**Remediation action**

Follow the deployment steps as documented here:
- [Configure Tenant Restrictions](https://learn.microsoft.com/entra/external-id/tenant-restrictions-v2)
<!--- Results --->
%TestResult%
