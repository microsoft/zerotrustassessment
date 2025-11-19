A threat actor or a well-intentioned but uninformed employee can create a new Microsoft Entra tenant if there are no restrictions in place. By default, the user who creates a tenant is automatically assigned the Global Administrator role. Without proper controls, this action fractures the identity perimeter by creating a tenant outside the organization's governance and visibility. It introduces risk though a shadow identity platform that can be exploited for token issuance, brand impersonation, consent phishing, or persistent staging infrastructure. Since the rogue tenant might not be tethered to the enterprise’s administrative or monitoring planes, traditional defenses are blind to its creation, activity, and potential misuse.

**Remediation action**

Enable the **Restrict non-admin users from creating tenants** setting. For users that need the ability to create tenants, assign them the Tenant Creator role. You can also review tenant creation events in the Microsoft Entra audit logs.

- [Restrict member users' default permissions](https://learn.microsoft.com/entra/fundamentals/users-default-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#restrict-member-users-default-permissions)
- [Assign the Tenant Creator role](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#tenant-creator)
- [Review tenant creation events](https://learn.microsoft.com/entra/identity/monitoring-health/reference-audit-activities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#core-directory). Look for OperationName=="Create Company", Category == "DirectoryManagement".
<!--- Results --->
%TestResult%

