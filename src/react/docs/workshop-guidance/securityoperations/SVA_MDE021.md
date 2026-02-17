# Review & Action Auto Investigation & Remediation Recommendations (Defender for Endpoint)

**Implementation Effort:** **Medium** – IT and SecOps teams must configure automation levels and establish workflows to review and approve remediation actions based on automated investigations.  
**User Impact:** **Low** – All work occurs in the security operations workflow; end users are not prompted to act or notified.

## Overview
Microsoft Defender for Endpoint Automated Investigation and Remediation (AIR) helps security teams quickly investigate alerts and automatically take actions such as quarantining files, stopping malicious services, or deleting scheduled tasks. Automated investigations produce remediation recommendations that security analysts can review, approve, or reject. This reduces manual work and speeds up containment. Not enabling or reviewing AIR actions increases attacker dwell time and slows incident response, exposing the environment to higher risk.

AIR supports the Zero Trust principle **Assume Breach** by continuously analyzing device activity, triggering automated investigations, and enforcing remediation actions that limit lateral movement.

### Where to enable/configure
You can configure AIR automation levels and review remediation actions in the Microsoft Defender portal.

- **Configure automation levels:** Settings → Endpoints → General → Automated investigation & remediation  
  [1](https://learn.microsoft.com/en-us/defender-endpoint/configure-automated-investigations-remediation)

- **Review/approve remediation actions:** Microsoft Defender → Action center  
  [2](https://learn.microsoft.com/en-us/defender-endpoint/auto-investigation-action-center)

- **View investigation results:** Incidents & alerts → Automated investigation details  
  [3](https://learn.microsoft.com/en-us/defender-endpoint/autoir-investigation-results)

*(No images were available in the Learn articles returned by search.)*

## Reference
- https://learn.microsoft.com/en-us/defender-endpoint/configure-automated-investigations-remediation
- https://learn.microsoft.com/en-us/defender-endpoint/automated-investigations
- https://learn.microsoft.com/en-us/defender-endpoint/manage-auto-investigation 
- https://learn.microsoft.com/en-us/defender-endpoint/auto-investigation-action-center 
- https://learn.microsoft.com/en-us/defender-endpoint/automation-levels 
- https://learn.microsoft.com/en-us/defender-endpoint/autoir-investigation-results
