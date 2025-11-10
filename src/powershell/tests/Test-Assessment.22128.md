When guest users are assigned highly privileged directory roles such as Global Administrator or Privileged Role Administrator, organizations create significant security vulnerabilities that threat actors can exploit for initial access through compromised external accounts or business partner environments. Since guest users originate from external organizations without direct control of security policies, threat actors who compromise these external identities can gain privileged access to the target organization's Microsoft Entra tenant.

When threat actors obtain access through compromised guest accounts with elevated privileges, they can escalate their own privilege to create other backdoor accounts, modify security policies, or assign themselves permanent roles within the organization. The compromised privileged guest accounts enable threat actors to establish persistence and then make all the changes they need to remain undetected. For example they could create cloud-only accounts, bypass Conditional Access policies applied to internal users, and maintain access even after the guest's home organization detects the compromise. Threat actors can then conduct lateral movement using administrative privileges to access sensitive resources, modify audit settings, or disable security monitoring across the entire tenant. Threat actors can reach complete compromise of the organization's identity infrastructure while maintaining plausible deniability through the external guest account origin. 

**Remediation action**

- [Remove Guest users from privileged roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/best-practices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

