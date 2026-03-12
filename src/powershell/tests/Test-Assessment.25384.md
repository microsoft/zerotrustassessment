An Application Administrator role scoped at the tenant level can manage every app registration and enterprise application. If a threat actor compromises an Application Administrator with tenant-wide scope, they can add credentials to any service principal, consent to malicious APIs, modify or create applications that enable data exfiltration, and disable or tamper with Private Access apps. Scoping the role to only required Private Access enterprise apps enforces least privilege and limits the blast radius.

If you don't scope Application Administrator assignments to specific apps:

- A compromised Application Administrator can manage every app registration and enterprise application in your tenant.
- Threat actors can add credentials to any service principal, enabling persistence and lateral movement.
- There's no blast radius containment; a single compromised identity can affect all applications.

**Remediation action**

- [Assign Application Administrator roles scoped to specific app registrations](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-enterprise-app-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) instead of tenant-wide.
- [Assign Microsoft Entra roles](https://learn.microsoft.com/entra/identity/role-based-access-control/manage-roles-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) with the least privilege necessary to perform required tasks.
- [Use Privileged Identity Management to manage just-in-time role activation](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- [Manage Microsoft Entra role assignments in the admin center](https://learn.microsoft.com/entra/identity/role-based-access-control/manage-roles-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

