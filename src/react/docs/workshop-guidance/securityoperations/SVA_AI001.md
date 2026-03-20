# Provision Security Copilot Units (SCUs)

**Implementation Effort:** Medium — Provisioning SCUs requires IT and Security Operations teams to configure and manage capacity through Azure or the Security Copilot portal.  
**User Impact:** Low — All actions occur at the admin level; non‑privileged users do not need to take any action.

## Overview
Security Compute Units (SCUs) provide the required capacity for Microsoft Security Copilot to run AI-driven security analysis workloads. Organizations that do not have Microsoft 365 E5 licensing must provision SCUs to enable Security Copilot. Administrators can increase or decrease SCUs from the Azure portal or the Security Copilot portal, and a usage monitoring dashboard helps them understand consumption over time. If SCUs are not provisioned—or the capacity is insufficient—Security Copilot may not operate or may perform poorly, weakening detection and investigation capabilities during active threats. This activity supports the **Zero Trust “Assume Breach”** principle by ensuring enough analytic capacity to rapidly detect, investigate, and respond to attacks.
Security Copilot uses Microsoft Entra ID role-based access control (RBAC) to authorize access, and Microsoft recommends using the Microsoft Security roles group, which provides balanced access and administrative efficiency. This planning step protects sensitive security insights, prevents accidental exposure, and reduces the risk of unauthorized operations if roles are poorly scoped.

### Where to configure this setting
- **Azure Portal** — Adjust SCU quantity and configure overage.  
- **Security Copilot Portal** — Track usage, view capacity dashboards, and tune allocation.  
*(No configuration images are available in the source documentation.)*

## Reference
- [Security Compute Units and capacity](https://learn.microsoft.com/en-us/copilot/security/security-compute-units-capacity)  
- [Get started with Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/get-started-security-copilot)  
- [Onboarding to Security Copilot for non-Microsoft 365 E5 customers](https://learn.microsoft.com/en-us/copilot/security/manual-onboarding)
- [Understand authentication in Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/authentication)
