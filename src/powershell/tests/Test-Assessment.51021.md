The Microsoft Entra Intune Administrator role grants broad administrative control across the Intune service. If every Intune administrator uses this full tenant-wide role, the organization has no evidence that least-privilege Intune RBAC is being used for day-to-day administration. Intune RBAC roles, whether built-in or custom, allow administrators to be scoped to specific duties, resources, users, devices, and scope tags. Using at least one assigned Intune RBAC role demonstrates that the tenant has started delegating Intune responsibilities through least-privilege administration rather than relying only on full Intune Administrator access.

This check verifies that the tenant has at least one assigned Intune RBAC role in addition to, or instead of, full Microsoft Entra Intune Administrator assignments.

**Remediation action**

- [Role-based access control with Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/role-based-access-control)
- [Assign admin permissions in Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/role-based-access-control)
- [Microsoft Entra built-in roles - Intune Administrator](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference#intune-administrator)
- [Privileged Identity Management for Microsoft Entra roles](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)

<!--- Results --->
%TestResult%
