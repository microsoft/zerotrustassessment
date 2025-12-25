Excessive assignment of tenant-wide roles like Global Administrator (GA) and Global Secure Access Administrator (GSA) creates a single-step escalation path for threat actors who compromise any assigned identity. This check reviews all GA and GSA role assignments in your tenant and flags any assignments to groups, guest users, or service principals, as well as excessive assignment counts.

Over-privileged assignments also increase blast radius when credentials are phished or session tokens are stolen. Limiting these roles to a small, vetted set of administrators—and monitoring assignments for groups, guests, and service principals—reduces the tenant-wide attack surface and enforces least privilege.

**Remediation action**

Review and limit GA/GSA assignments:
- [Role-based access control permissions reference](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference)

Remove group and guest assignments; assign directly to vetted admins.

Use PIM for just-in-time eligibility:
- [Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-configure)
<!--- Results --->
%TestResult%
