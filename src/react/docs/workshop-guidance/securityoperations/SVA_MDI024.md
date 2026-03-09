
# Investigate All Sensitive Accounts in Your Organization with Identity Inventory (Daily)

**Implementation Effort:** Low — This is a targeted admin‑led activity that uses the built‑in Microsoft Defender for Identity Identity Inventory to review and tag sensitive accounts.  
**User Impact:** Low — All actions are performed by administrators and security operations; end users are not notified or required to take any action.

## Overview

Microsoft Defender for Identity provides an **Identity Inventory** that gives administrators a centralized view of all identities in the environment, improving visibility and enabling investigation of identity-related risks. The inventory helps teams quickly see identity details, behaviors, and security-relevant context across their environment. [1](https://learn.microsoft.com/en-us/defender-for-identity/identity-inventory)

Security teams should review **sensitive accounts daily**, focusing on unusual activity, lateral movement exposure, and misconfigurations. Defender for Identity also supports **entity tags**, which allow administrators to mark specific identities as *sensitive*. Tagging is required for detections that depend on sensitivity status, such as sensitive group modification or lateral movement detection paths. Without this daily oversight and tagging, sensitive accounts—common attacker targets—may go unnoticed and remain vulnerable to compromise. [2](https://learn.microsoft.com/en-us/defender-for-identity/entity-tags)

This task supports the Zero Trust principle **Assume Breach**, because it improves visibility into high‑value and high‑risk identities, enabling rapid detection of suspicious behavior and reducing attacker opportunity.

### Where to configure or use this capability
- **Identity Inventory:**  
  Microsoft Defender portal → **Assets** → **Identities** (updated centralized identity view).  
  [1](https://learn.microsoft.com/en-us/defender-for-identity/identity-inventory)

- **Sensitive Account Tagging:**  
  Microsoft Defender portal → **Identities** → select an identity → **Entity Tags** → mark as *Sensitive*.  
  [2](https://learn.microsoft.com/en-us/defender-for-identity/entity-tags)


## Reference

- Identity Inventory — Microsoft Defender for Identity  
  https://learn.microsoft.com/en-us/defender-for-identity/identity-inventory [1](https://learn.microsoft.com/en-us/defender-for-identity/identity-inventory)

- Entity Tags — Sensitive Account Tagging  
  https://learn.microsoft.com/en-us/defender-for-identity/entity-tags [2](https://learn.microsoft.com/en-us/defender-for-identity/entity-tags)
