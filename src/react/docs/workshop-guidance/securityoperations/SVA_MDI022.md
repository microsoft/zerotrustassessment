# Remediate misconfigurations and risky identity practices with security posture assessments (weekly)

**Implementation Effort:** Low — Administrators only need to review and act on published security posture assessments; this is a targeted operational task, not a major project.  
**User Impact:** Low — All actions are taken by administrators to fix misconfigurations; end users are not required to take action or be notified.

## Overview

Security posture assessments in Microsoft Defender for Identity provide ongoing visibility into **misconfigurations, exploitable components, and risky identity practices** within your Active Directory environment. These assessments surface issues alongside their business impact and step‑by‑step remediation guidance. They appear in **Microsoft Secure Score**, allowing security teams to prioritize improvements based on objective scoring and measurable risk reduction. If not reviewed regularly, misconfigurations may remain undetected, leaving identity systems exposed to attacker techniques such as lateral movement, credential theft, or privilege escalation.

This activity aligns strongly with the Zero Trust principle **Verify Explicitly**, because posture assessments help ensure identity systems are continually evaluated against security best practices and verified through telemetry and configuration checks.


### Integration with the Identity Security Initiative

The **Identity Security Initiative** in Microsoft Security Exposure Management provides a broader programmatic framework for improving identity posture. It expands on posture assessments by offering prioritized identity security recommendations across Microsoft Defender XDR, helping organizations identify critical misconfigurations, improve resilience, and reduce exposure. This initiative complements weekly posture reviews by ensuring identity risks are tracked and addressed through an organized, measurable maturity model.  

### Where to configure or use this capability

You can find and review posture assessments in:

- **Microsoft Secure Score** within the Microsoft Defender portal, where misconfigurations and recommended remediation actions are displayed.  
  [1](https://learn.microsoft.com/en-us/defender-for-identity/security-assessment)
  [2](https://learn.microsoft.com/en-us/defender-xdr/microsoft-secure-score-improvement-actions)

- **Defender for Identity Posture Assessment Reports**, including account-specific assessments that list findings, impacts, and recommended remediation steps.  
  [3](https://learn.microsoft.com/en-us/defender-for-identity/security-posture-assessments/accounts)


## Reference

- 1 [Security posture assessments — Microsoft Defender for Identity ](https://learn.microsoft.com/en-us/defender-for-identity/security-assessment)  
- 2 [Accounts security posture assessments — Microsoft Defender for Identity ](https://learn.microsoft.com/en-us/defender-for-identity/security-posture-assessments/accounts)  
- 3 [Assess your security posture with Microsoft Secure Score](https://learn.microsoft.com/en-us/defender-xdr/microsoft-secure-score-improvement-actions) 
- [Identity Security Initiative — Microsoft Security Exposure Management](https://learn.microsoft.com/en-us/defender-for-identity/identity-security-initiative)

