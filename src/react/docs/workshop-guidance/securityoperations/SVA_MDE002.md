# Assign Roles and Permissions for Microsoft Defender for Endpoint

**Implementation Effort:** Medium – This requires IT and Security Operations teams to plan and configure role-based access control (RBAC) or Unified RBAC (URBAC), including defining roles, mapping them to Microsoft Entra groups, and managing access reviews.

**User Impact:** Low – Only administrators and security personnel are affected; end users do not need to take any action or be notified.

## Overview

Assigning roles and permissions in Microsoft Defender for Endpoint (MDE) ensures that only authorized personnel can access and manage security data and configurations. MDE supports two models: basic permissions (full access or read-only) and role-based access control (RBAC), which allows for more granular control. As of February 2025, new customers must use Unified RBAC (URBAC), which centralizes role management across Microsoft security products.

Administrators can assign roles like **Security Administrator** or **Security Reader** through Microsoft Entra ID, and further refine access by linking roles to device groups. Microsoft recommends using **least privilege access** and **Privileged Identity Management (PIM)** to reduce risk and improve auditability. Not implementing proper role assignments can lead to overexposure of sensitive data, misconfigurations, or unauthorized changes, increasing the risk of breaches.

This activity aligns with the Zero Trust principle of **Use least privilege access**, ensuring users only have the permissions necessary for their role.

## Reference

- [Assign roles and permissions - Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/prepare-deployment)
- [Create and manage roles for role-based access control](https://learn.microsoft.com/en-us/defender-endpoint/user-roles)
- [Assign user access - Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/assign-portal-access)

