When non-administrator users can access their own BitLocker keys, threat actors who compromise user credentials gain direct access to encryption keys without requiring privilege escalation. Once attackers obtain BitLocker keys, they can decrypt sensitive data stored on the device, including cached credentials, local databases, and confidential files.

Without proper restrictions, a single compromised user account provides immediate access to all encrypted data on that device, negating the primary security benefit of disk encryption and creating a pathway for lateral movement. 

**Remediation action**

- [Restrict non-admin users from recovering the BitLocker key(s) for their owned devices](https://learn.microsoft.com/entra/identity/devices/manage-device-identities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-device-settings)
<!--- Results --->
%TestResult%

