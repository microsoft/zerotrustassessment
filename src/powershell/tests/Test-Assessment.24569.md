If macOS FileVault encryption policies are not properly configured and enforced via Intune management, threat actors can exploit physical access to unmanaged or misconfigured macOS devices to extract sensitive corporate data. Without enforced FileVault encryption, data stored on the device remains unprotected at rest, allowing attackers to bypass operating system-level security by booting from external media or removing the storage drive. This enables credential harvesting, certificate theft, and unauthorized access to cached authentication tokens, which can be used to escalate privileges and move laterally across the environment. Additionally, unencrypted devices undermine compliance with data protection regulations and increase the risk of reputational damage and financial penalties in the event of a breach. 

**Remediation action**

Create and assign Local Users and Groups policy in Intune:

- [Configure and assign macOS FileVault encryption policies](https://learn.microsoft.com/intune/intune-service/protect/encrypt-devices-filevault)  

- [Monitor macOS FileVault encryption status](https://learn.microsoft.com/intune/intune-service/protect/encryption-monitor)  
<!--- Results --->
%TestResult%
