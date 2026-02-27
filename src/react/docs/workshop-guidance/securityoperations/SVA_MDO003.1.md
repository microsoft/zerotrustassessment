# Onboard Admin Users with Least Privilege Roles in Microsoft Defender for Office 365

**Implementation Effort:** Medium  
Assigning least privilege roles requires coordination between IT and Security teams to define responsibilities, configure role-based access, and maintain ongoing governance.

**User Impact:** Low  
Only administrators are affected; end users do not need to take any action or be notified.

---

## Overview

Onboarding admin users with least privilege roles in Microsoft Defender for Office 365 (MDO) involves assigning only the minimum permissions necessary for admins to perform their tasks. This is done using role-based access control (RBAC) through Microsoft Entra ID and the Microsoft Defender portal. Key roles include **Security Administrator**, **Security Reader**, and custom role groups tailored to specific responsibilities like incident response or policy management.

This approach supports the **Zero Trust principle of "Use least privilege access"** by reducing the attack surface and limiting the potential damage from compromised accounts. If not implemented, organizations risk over-privileged accounts that can be exploited in lateral movement attacks or data exfiltration scenarios.

---

## Reference

- [Roles and role groups in Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/scc-permissions)
- [Get started with Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/mdo-deployment-guide#step-3-assign-permissions-to-admins)
