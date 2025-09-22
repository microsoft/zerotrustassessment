If Intune scope tags aren't properly configured for delegated administration, attackers who gain privileged access to Intune or Azure Active Directory (Azure AD) can escalate privileges and access sensitive device configurations across the tenant. Without granular scope tags, administrative boundaries are unclear, allowing attackers to move laterally, manipulate device policies, exfiltrate configuration data, or deploy malicious settings to all users and devices. This lack of segmentation increases the risk of widespread compromise, and single compromised admin account can impact the entire environment. In addition, the absence of delegated administration undermines least-privileged access, making it difficult to contain breaches and enforce accountability. Attackers might exploit global administrator accounts or misconfigured role-based access control (RBAC) roles, bypass compliance policies and conditional access controls, and gain control over device management at scale.

**Remediation action**

- [Use scope tags to determine what admins can see](https://learn.microsoft.com/intune/intune-service/fundamentals/scope-tags?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Role-based access control with Microsoft Intune](https://learn.microsoft.com/intune/intune-service/fundamentals/role-based-access-control ?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

