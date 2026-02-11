
# Investigate incidents where a user or asset has unusual or high-risk activities

**Implementation Effort:** Low — This is a targeted action performed by security operations using built‑in investigation tools in the Microsoft Defender portal.  
**User Impact:** Low — Only administrators take action; end users do not need to be notified or make changes.

## Overview

Microsoft Defender XDR provides a unified incident investigation experience that correlates alerts and telemetry from multiple Defender components to surface **unusual or high‑risk activity** across users, endpoints, and other assets. Security teams can review correlated incidents, pivot into detailed user or asset investigation pages, and understand behaviors, alerts, and context that help identify potential compromise. If organizations do not regularly investigate these incidents, suspicious behavior may go undetected, giving attackers time to move laterally, escalate privileges, or persist in the environment.

This activity supports the Zero Trust principle **Assume Breach**, because it relies on analytics and visibility to detect threats quickly and reduce the potential impact of compromised accounts or devices.

### Where to configure or investigate this capability

- **Investigate Incidents**  
  Microsoft Defender portal → **Incidents & alerts** → **Incidents**  
  (Allows analysis of correlated signals across multiple Defender services.)  
  [1](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-planning)

- **Investigate Users**  
  Microsoft Defender portal → **Assets** → **Identities** → select user  
  (Provides identity activity, alerts, and contextual information on the user entity page.)  
  [2](https://learn.microsoft.com/en-us/defender-for-identity/entity-tags)

- **Investigate Assets (Devices, Users, Computers)**  
  Microsoft Defender for Identity → **Investigate**  
  (Enables analysis of suspicious users, computers, and devices.)  
  [3](https://learn.microsoft.com/en-us/defender-for-identity/identity-inventory)


## Reference

- Investigate Incidents in Microsoft Defender XDR  
  https://learn.microsoft.com/en-us/defender-xdr/investigate-incidents [1](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-planning)

- User Entity Page — Microsoft Defender XDR  
  https://learn.microsoft.com/en-us/defender-xdr/investigate-users [2](https://learn.microsoft.com/en-us/defender-for-identity/entity-tags)
