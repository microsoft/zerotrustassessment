# Role-Based Access Control (RBAC)

**Last Updated:** May 2025  
**Implementation Effort:** Medium – IT admins must define roles, assign permissions, and maintain scope tags to align with organizational structure and security policies.  
**User Impact:** Low – RBAC affects only administrative access; end users are not impacted or required to take action.

---

## Introduction

Role-Based Access Control (RBAC) in Intune allows organizations to delegate administrative permissions based on roles, responsibilities, and scope. For macOS environments, RBAC ensures that only authorized personnel can manage devices, deploy configurations, or access sensitive data. This is a foundational control in a Zero Trust model, where **access is granted based on least privilege and verified identity**.

This section helps administrators evaluate their RBAC model and align it with Zero Trust principles—particularly around administrative segmentation, operational accountability, and scope limitation.

---

## Why This Matters

- **Prevents over-permissioning** by assigning only the rights needed for each role.  
- **Supports Zero Trust** by enforcing least privilege and role-based access.  
- **Improves operational security** by limiting who can manage macOS devices and policies.  
- **Enables auditability** of administrative actions.  
- **Reduces risk** of misconfiguration or insider threats.  

---

## Key Considerations

### Built-in Roles

Intune includes predefined roles such as:

- **Intune Administrator**  
- **Policy and Profile Manager**  
- **Help Desk Operator**  
- **Application Manager**  

These roles can be assigned to users or groups and scoped to specific device groups.

> From a Zero Trust perspective: Built-in roles provide a **structured starting point** for enforcing least privilege.

---

### Custom Roles

- You can create custom roles with granular permissions tailored to your organization’s needs.  
- For example, a macOS-specific role could be created to allow managing only macOS compliance policies and configuration profiles.

> From a Zero Trust perspective: Custom roles enable **fine-grained access control** and **role separation**.

---

### Scope Tags

- Scope tags allow you to segment administrative access by department, geography, or business unit.  
- They ensure that admins only see and manage the resources they are responsible for.

> From a Zero Trust perspective: Scope tags enforce **segmentation and visibility boundaries**, reducing lateral risk.

---

### Delegation for macOS Management

- Assign roles to macOS-specific IT teams to manage only macOS devices and policies.  
- Avoid giving global permissions to teams that don’t manage other platforms.

> From a Zero Trust perspective: This supports **role clarity** and **platform-specific accountability**.

---

### Audit and Review

- Use the **Microsoft Intune audit logs** and **Microsoft Entra sign-in logs** to track administrative actions.  
- Regularly review role assignments and scope tags to ensure they reflect current responsibilities.

> From a Zero Trust perspective: Auditing supports **explicit verification** and **continuous trust** in administrative access.

---

## Zero Trust Considerations

- **Verify explicitly**: RBAC ensures that only verified, authorized users can perform administrative actions.  
- **Least privilege**: Roles are scoped to the minimum permissions required for the task.  
- **Assume breach**: Segmentation and scope tags reduce the blast radius of compromised credentials.  
- **Continuous trust**: Role assignments and access scopes should be reviewed regularly.  
- **Defense in depth**: RBAC complements Conditional Access, compliance policies, and device restrictions.  

---

## Recommendations

- **Use built-in roles** as a baseline and extend with custom roles as needed.  
- **Create macOS-specific roles** to delegate platform-specific responsibilities.  
- **Apply scope tags** to enforce administrative segmentation and visibility boundaries.  
- **Avoid assigning global admin rights** unless absolutely necessary.  
- **Audit role assignments** and administrative actions regularly.  
- **Review RBAC configurations quarterly** to ensure alignment with organizational structure and Zero Trust principles.  

---

## References

- [Role-Based Access Control in Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/role-based-access-control)  
- [Create and Assign Custom Roles](https://learn.microsoft.com/en-us/mem/intune/fundamentals/custom-rbac)  
- [Use Scope Tags in Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/scope-tags)  
- [Monitor Admin Activity with Audit Logs](https://learn.microsoft.com/en-us/mem/intune/fundamentals/intune-audit-logs)
