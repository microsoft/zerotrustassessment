If Platform SSO policies aren't enforced on macOS devices, endpoints might rely on insecure or inconsistent authentication mechanisms, allowing attackers to bypass Conditional Access and compliance policies. This opens the door to lateral movement across cloud services and on-premises resources, especially when federated identities are used. Threat actors can persist by leveraging stolen tokens or cached credentials and exfiltrate sensitive data through unmanaged apps or browser sessions. The absence of SSO enforcement also undermines app protection policies and device posture assessments, making it difficult to detect and contain breaches. Ultimately, failure to configure and assign macOS Platform SSO policies compromises identity security and weakens the organization's Zero Trust posture.

Enforcing Platform SSO policies on macOS devices ensures consistent, secure authentication across apps and services. This strengthens identity protection, supports Conditional Access enforcement, and aligns with Zero Trust by reducing reliance on local credentials and improving posture assessments.

**Remediation action**

Use Intune to configure and assign Platform SSO policies for macOS devices to enforce secure authentication and strengthen identity protection, see:

- [Configure Platform SSO for macOS in Intune](https://learn.microsoft.com/intune/intune-service/configuration/platform-sso-macos?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) – *Step-by-step guidance for enabling Platform SSO on macOS devices.*
- [Single sign-on (SSO) overview and options for Apple devices in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/configuration/use-enterprise-sso-plug-in-ios-ipados-macos?pivots=macos&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) – *Overview of SSO options available for Apple platforms.*<!--- Results --->
%TestResult%

