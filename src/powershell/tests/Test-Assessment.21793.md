Tenant Restrictions v2 (TRv2) allows organizations to enforce policies that restrict access to specified Microsoft Entra tenants, preventing unauthorized exfiltration of corporate data to external tenants using local accounts. Without TRv2, threat actors can exploit this vulnerability, which leads to potential data exfiltration and compliance violations, followed by credential harvesting if those external tenants have weaker controls. Once credentials are obtained, threat actors can gain initial access to these external tenants. TRv2 provides the mechanism to prevent users from authenticating to unauthorized tenants. Otherwise, threat actors can move laterally, escalate privileges, and potentially exfiltrate sensitive data, all while appearing as legitimate user activity that bypasses traditional data loss prevention controls focused on internal tenant monitoring.

Implementing TRv2 enforces policies that restrict access to specified tenants, mitigating these risks by ensuring that authentication and data access are confined to authorized tenants only. 

If this check passes, your tenant has a TRv2 policy configured but more steps are required to validate the scenario end-to-end.

**Remediation action**
- [Set up Tenant Restrictions v2](https://learn.microsoft.com/en-us/entra/external-id/tenant-restrictions-v2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

