# Review Microsoft Defender for Cloud Apps Incidents for Suspicious Activity

**Implementation Effort:** Low — This is a targeted administrative task focused on reviewing and investigating alerts in the Defender for Cloud Apps portal, with no broader program or deployment required.  
**User Impact:** Low — Only administrators perform the investigation steps; non-privileged users are not required to take action.

## Overview
Microsoft Defender for Cloud Apps helps security teams detect threats by generating alerts and incidents related to suspicious or risky behavior in cloud applications. These incidents may include anomalous sign-ins, impossible travel events, unusual data downloads, or behaviors that match Defender’s machine‑learning–based anomaly detection. Regular review of these incidents helps identify compromised accounts, malicious applications, or risky activities before they escalate. If this activity is not performed, threats may go unnoticed, allowing attackers to persist, exfiltrate data, or expand access across cloud resources.

This activity supports the Zero Trust principle **Assume Breach**, because it relies on continuous monitoring and analytics to detect malicious activity and reduce potential impact.

### Where to Review and Investigate Incidents
You can review suspicious activity and alerts in:
1. **Microsoft Defender Portal** → *Cloud Apps* → **Alerts** or **Incidents**  
   (The investigation workflow for alerts is described in Microsoft's guidance.) 
2. Use the **anomaly detection investigation guides**, which outline how to inspect unusual behaviors flagged by Defender for Cloud Apps. 
3. During analysis, apply **activity filters** to refine user, session, and app‑related evidence.

*Note: The Learn articles do not provide extractable images through tool output, so no image is available to embed.*

## Reference
- (https://learn.microsoft.com/en-us/defender-cloud-apps/investigate)  
- (https://learn.microsoft.com/en-us/defender-cloud-apps/investigate-anomaly-alerts)  
