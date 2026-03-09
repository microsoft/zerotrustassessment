When Microsoft Entra Private Access applications lack user or group assignments, users can't establish tunnels through the application to reach the configured fully qualified domain names (FQDNs) and IP addresses. This restriction prevents access to protected internal resources. Without assignments, organizations can't enforce Conditional Access policies because these policies require explicit user-to-application relationships to evaluate risk signals, device compliance, and authentication strength requirements.

Without user assignments on Private Access applications:

- Organizations lose the ability to enforce least privilege access controls where users get access only to the specific resources they need.
- Organizations can't apply risk-based access policies that block or challenge authentication based on sign-in risk, user risk, or device compliance.
- Identity protection signals that detect credential compromise, impossible travel, or anonymous IP addresses can't protect private resources.

**Remediation action**

- [Assign users and groups to Private Access applications](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-per-app-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-users-and-groups) to enable Zero Trust access controls and Conditional Access enforcement.
<!--- Results --->
%TestResult%

