# Security assessment: Replace Enterprise or Domain Admin account for Entra Connect AD DS Connector account

**Implementation Effort:** Medium: This effort score is chosen because it requires organizations to create or assign a lower-privileged account specifically for directory synchronization, which involves significant changes to existing configurations and ongoing monitoring.

**User Impact:** Medium: This ranking is chosen because a subset of non-privileged users, specifically IT administrators, need to take action or be notified of changes.

## Overview
Starting with [Entra Connect build 1.4.###.#](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/reference-connect-accounts-permissions), Enterprise Admin and Domain Admin accounts can no longer be used as the AD DS Connector account. This best practice prevents over-privileging the connector account, reducing the risk of domain-wide compromise if the account is targeted by attackers. Organizations must now create or assign a lower-privileged account specifically for directory synchronization, ensuring better adherence to the principle of least privilege and protecting critical admin accounts.

## Reference
[Security assessment: Replace Enterprise or Domain Admin account for Entra Connect AD DS Connector account](https://learn.microsoft.com/en-us/defender-for-identity/replace-entra-connect-default-admin)
