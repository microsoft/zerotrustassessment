When guest users are assigned highly privileged directory roles such as Global Administrator or Privileged Role Administrator, organizations create significant security vulnerabilities that threat actors can exploit for initial access through compromised external accounts or business partner environments. Since guest users originate from external organizations without direct control of security policies, threat actors who compromise these external identities gain privileged access to the target organization's Microsoft Entra tenant. Once threat actors obtain access through compromised guest accounts with elevated privileges, they can perform privilege escalation by leveraging administrative permissions to create additional backdoor accounts, modify security policies, or assign themselves permanent roles within the organization. The compromised privileged guest accounts enable threat actors to establish persistence by creating cloud-only accounts, bypassing conditional access policies applied to internal users, or maintaining access even after the guest's home organization detects the compromise. Threat actors can then conduct lateral movement using administrative privileges to access sensitive resources, modify audit settings, or disable security monitoring across the entire tenant. Finally, threat actors achieve impact through unauthorized access to sensitive data, or complete compromise of the organization's identity infrastructure while maintaining plausible deniability through the external guest account origin.

**Remediation action**

Remove Guest users from privileged roles
- [Assign Microsoft Entra roles](https://learn.microsoft.com/entra/identity/role-based-access-control/manage-roles-portal?tabs=admin-center)
- [Best practices for Microsoft Entra roles](https://learn.microsoft.com/entra/identity/role-based-access-control/best-practices)

<!--- Results --->
%TestResult%
