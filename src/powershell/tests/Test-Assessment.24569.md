Without properly configured and assigned FileVault encryption policies in Intune, threat actors can exploit physical access to unmanaged or misconfigured macOS devices to extract sensitive corporate data. Unencrypted devices allow attackers to bypass operating system-level security by booting from external media or removing the storage drive. These attacks can expose credentials, certificates, and cached authentication tokens, enabling privilege escalation and lateral movement. Additionally, unencrypted devices undermine compliance with data protection regulations and increase the risk of reputational damage and financial penalties in the event of a breach.

Enforcing FileVault encryption protects data at rest on macOS devices, even if lost or stolen. It disrupts credential harvesting and lateral movement, supports regulatory compliance, and aligns with Zero Trust principles of device trust.

**Remediation action**

Use Intune to enforce FileVault encryption and monitor compliance on all managed macOS devices:  
- [Create a FileVault disk encryption policy for macOS in Intune](https://learn.microsoft.com/intune/intune-service/protect/encrypt-devices-filevault?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-endpoint-security-policy-for-filevault)
- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)
- [Monitor device encryption with Intune](https://learn.microsoft.com/intune/intune-service/protect/encryption-monitor?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

