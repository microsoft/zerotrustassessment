An Application Administrator role scoped at the tenant can manage every app registration and enterprise app. If a threat actor compromises an App Admin with tenant-wide scope, they can add credentials to any service principal (Persistence), consent malicious APIs (Defence Evasion), modify or create applications that proxy data exfiltration (Exfiltration), and disable or tamper with Private Access (PA) apps (Impact). Scoping the role to only required Private Access enterprise apps enforces least privilege and limits blast radius.

Additionally, assigning Application Administrator to groups, service principals, or guest users increases risk. Groups make it difficult to track who has access, service principals can be compromised through stolen credentials, and guest users may have different security controls. Assignments should be made directly to member users only.

**Remediation action**

To constrain Application Administrator rights to specific Private Access apps:

1. **Scope App Admin to specific apps**: Remove tenant-wide assignments and reassign with `directoryScopeId` pointing to the required Private Access or Quick Access apps.
   - [Assign roles with app registration scope](https://learn.microsoft.com/entra/identity/role-based-access-control/assign-roles-different-scopes?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#app-registration-scope)

2. **Remove problematic assignments**: Remove assignments to groups, service principals, or guest users. Assign directly to member user accounts instead.
   - [Manage directory role assignments](https://learn.microsoft.com/graph/api/rbacapplication-list-roleassignments?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)

3. **Use PIM for JIT elevation**: Implement Privileged Identity Management to provide just-in-time access for Application Administrator role.
   - [Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)

<!--- Results --->
%TestResult%
