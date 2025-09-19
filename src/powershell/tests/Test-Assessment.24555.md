If Intune Scope Tags are not properly configured for delegated administration, threat actors who gain privileged access to Intune or Azure AD can escalate their privileges and access sensitive device configurations across the entire tenant. Without granular scope tags, administrative boundaries are blurred, allowing attackers to move laterally and manipulate device policies, exfiltrate configuration data, or deploy malicious settings to all users and devices. This lack of segmentation increases the risk of widespread compromise, as a single compromised admin account can impact the entire environment. Furthermore, the absence of delegated administration undermines least-privilege principles, making it difficult to contain breaches and enforce accountability. Attackers can exploit this by targeting global admin accounts or misconfigured RBAC roles, bypassing compliance policies and conditional access controls, and ultimately gaining control over device management at scale. 

**Remediation action**

Create and assign custom scope tags for delegated administration:
- [Use role-based access control (RBAC) and scope tags for distributed IT](https://learn.microsoft.com/mem/intune/fundamentals/scope-tags)

Intune RBAC:
- [Role-based access control (RBAC) with Microsoft Intune](https://learn.microsoft.com/intune/intune-service/fundamentals/role-based-access-control)

<!--- Results --->
%TestResult%
