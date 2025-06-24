# Security Assessment: Dormant Entities in Sensitive Groups

**Implementation Effort:** Medium. Customer IT and Security Operations teams need to drive projects to identify and manage dormant entities.

**User Impact:** Medium. Action can be taken by administrators, users don’t have to be notified.

## Overview
Microsoft Defender for Identity's security assessment for dormant entities identifies sensitive user accounts that have become inactive, disabled, or expired over a period of 180 days. These dormant accounts pose a risk as they can be exploited by malicious actors to gain unauthorized access to sensitive data. This assessment helps organizations secure their dormant user accounts by recommending actions such as removing privileged access rights or deleting the accounts, thereby fitting into the Zero Trust framework by ensuring that only active, verified users have access to sensitive resources.

## Reference
[Security assessment: Dormant entities in sensitive groups](https://learn.microsoft.com/en-us/defender-for-identity/security-assessment-dormant-entities)
