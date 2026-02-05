# Swiftly remediate compromised identities with Response Actions to prevent further damage (daily)

**Implementation Effort:** Low — Administrators only need to take targeted response actions such as disabling accounts or resetting passwords when identities are compromised, which requires no large project or ongoing program.  
**User Impact:** Low — Remediation actions are taken by administrators; end users do not need to take action unless their password is reset.

## Overview

Swift remediation of compromised identities is critical to stopping attacker movement and preventing further damage. Microsoft Defender for Identity provides **Response Actions** that allow security teams to quickly disable compromised user accounts or reset their passwords to stop active misuse. These actions appear directly within the investigation workflow, allowing analysts to rapidly contain threats as soon as suspicious or confirmed malicious activity is detected. After actions are taken, teams can review activity details in the **Action Center** to validate that containment was successful. If these response actions are not performed promptly, attackers may continue using compromised identities for lateral movement, data theft, privilege escalation, or persistence.

This activity strongly aligns with the Zero Trust principle **Assume Breach**, because it focuses on rapid containment of high‑risk identities based on real‑time analytics and detections.

### Where to configure or take these response actions

- **Microsoft Defender for Identity → Response Actions**  
  You can disable compromised accounts or reset user passwords directly from the Defender for Identity portal, and review results in the Action Center.  
  [1](https://learn.microsoft.com/en-us/defender-for-identity/remediation-actions)

*(No images were provided in the referenced Learn articles.)*

## Reference

- Remediation actions — Microsoft Defender for Identity  
  https://learn.microsoft.com/en-us/defender-for-identity/remediation-actions [1](https://learn.microsoft.com/en-us/defender-for-identity/remediation-actions)

- Remediate risky users — Microsoft Entra ID Protection (optional additional remediation guidance)  
  https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-remediate-unblock [2](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-remediate-unblock)
