Without properly configured and assigned FileVault encryption policies in Intune, threat actors can exploit physical access to unmanaged or misconfigured macOS devices to extract sensitive corporate data. When devices remain unencrypted, data stored at rest remains unprotected, allowing attackers to bypass operating system-level security by booting from external media or removing the storage drive. These attacks can expose credentials, certificates, and cached authentication tokens, enabling privilege escalation and lateral movement within the environment. Additionally, unencrypted devices undermine compliance with data protection regulations and increase the risk of reputational damage and financial penalties if there's a breach.

**Remediation action**

- [Use FileVault disk encryption for macOS with Intune](https://learn.microsoft.com/intune/intune-service/protect/encrypt-devices-filevault?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Monitor device encryption with Intune](https://learn.microsoft.com/intune/intune-service/protect/encryption-monitor?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

