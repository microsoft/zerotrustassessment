Without configuring access packages for external users to use specific connected organizations, organizations expose themselves to uncontrolled access from any external identity source. When access packages allow "All users" threat actors can potentially request access through compromised external accounts from any domain or organization, including those not authorized by the organization. This broad external access scope bypasses the principle of least privilege and creates multiple attack vectors for lateral movement within the environment. Threat actors can exploit weakly configured access packages to establish initial access through legitimate-appearing requests, then use these granted permissions to perform reconnaissance activities. Once internal access is established through these overprivileged external access paths, threat actors can attempt escalate their privileges, persist in the environment through additional access requests, and potentially move laterally to compromise critical business systems and data repositories.

**Remediation action**

* [Explicitly define the list of organizations allowed in your tenant as connected organizations](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-organization)

* [Configure access packages assignment policies to specific connected organizations](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-access-package-create#allow-users-not-in-your-directory-to-request-the-access-package)

<!--- Results --->
%TestResult%
