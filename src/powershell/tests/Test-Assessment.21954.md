When non-administrator users can access their own BitLocker keys, threat actors who compromise user credentials through phishing, credential stuffing, or malware-based keyloggers gain direct access to encryption keys without requiring privilege escalation. This access vector enables threat actors to persist on the compromised device by accessing encrypted volumes. Once threat actors obtain BitLocker keys, they can decrypt sensitive data stored on the device, including cached credentials, local databases, and confidential files. Without proper restrictions, a single compromised user account provides immediate access to all encrypted data on that device, negating the primary security benefit of disk encryption and creating a pathway for lateral movement to network resources accessed from the compromised system.

**Remediation action**

[Configure BitLocker key access restrictions through Microsoft Entra admin](https://learn.microsoft.com/en-us/entra/identity/devices/manage-device-identities#view-or-copy-bitlocker-keys)

<!--- Results --->
%TestResult%
