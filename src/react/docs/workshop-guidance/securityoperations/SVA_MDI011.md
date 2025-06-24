# Remove non-admin accounts with DCSync permissions

**Implementation Effort:** Medium: Customer IT and Security Operations teams need to drive projects to identify and remove DCSync permissions from non-admin accounts.

**User Impact:** Medium: Action can be taken by administrators, users don’t have to be notified.

## Overview
The "Remove non-admin accounts with DCSync permissions" security assessment in Microsoft Defender for Identity identifies accounts with DCSync permissions that are not domain admins. DCSync permissions allow accounts to initiate domain replication, which can be exploited by attackers to gain unauthorized access or manipulate domain data. This assessment helps ensure the security and integrity of your Active Directory environment by recommending the removal of these permissions from non-admin accounts.

## Reference
[Remove non-admin accounts with DCSync permissions - Microsoft Defender for Identity](https://learn.microsoft.com/en-us/defender-for-identity/security-assessment-non-admin-accounts-dcsync)
