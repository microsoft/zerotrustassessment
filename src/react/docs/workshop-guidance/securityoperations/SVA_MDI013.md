# Security assessment: Remove unsafe permissions on sensitive Entra Connect accounts

**Implementation Effort:** Medium: This effort score is chosen because customer IT and Security Operations teams need to implement programs that require ongoing time or resource commitment, including continuous monitoring and adjustments.

**User Impact:** Medium: A subset of non-privileged users have to take action or be notified of changes, particularly those managing hybrid identity infrastructure.

## Overview
This article describes the security assessment for removing unsafe permissions on sensitive Microsoft Entra Connect accounts using Microsoft Defender for Identity. It highlights the risks associated with powerful privileges granted to accounts like AD DS Connector and Microsoft Entra Seamless SSO computer accounts, which could be exploited by attackers to gain unauthorized access and escalate privileges, compromising both on-premises and cloud environments. This fits into the Zero Trust framework by ensuring that permissions are tightly controlled and monitored to prevent unauthorized access.

## Reference
[Security assessment: Remove unsafe permissions on sensitive Entra Connect accounts](https://learn.microsoft.com/en-us/defender-for-identity/remove-unsafe-permissions-sensitive-entra-connect)
