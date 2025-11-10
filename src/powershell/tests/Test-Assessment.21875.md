Access packages configured to allow "All users" instead of specific connected organizations expose your organization to uncontrolled external access. Threat actors can exploit this by requesting access through compromised external accounts from unauthorized organizations, bypassing the principle of least privilege. This enables initial access, reconnaissance, privilege escalation, and lateral movement within your environment. 

**Remediation action**

- [Define trusted organizations as connected organizations](https://learn.microsoft.com/entra/id-governance/entitlement-management-organization?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#view-the-list-of-connected-organizations)
- [Configure access packages to only allow specific connected organizations](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#allow-users-not-in-your-directory-to-request-the-access-package)
<!--- Results --->
%TestResult%

