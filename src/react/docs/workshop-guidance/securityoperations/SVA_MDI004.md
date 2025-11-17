# Security Assessment: Ensure privileged accounts are not delegated

**Implementation Effort:** Medium: Customer IT and Security Operations teams need to drive projects to review and configure privileged accounts.

**User Impact:** Low: Action can be taken by administrators, users don’t have to be notified.

## Overview
This documentation provides guidance on ensuring privileged accounts are not delegated by setting the "account is sensitive and cannot be delegated" flag. This is crucial to prevent attackers from exploiting Kerberos delegation to misuse privileged account credentials, leading to unauthorized access and potential security breaches. This fits into the Zero Trust framework by ensuring that sensitive accounts are protected from unauthorized delegation and lateral movement.

## Reference
[Security Assessment: Ensure privileged accounts are not delegated](https://learn.microsoft.com/en-us/defender-for-identity/ensure-privileged-accounts-with-sensitive-flag)
