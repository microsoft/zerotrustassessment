# Review Defender for Office Incidents Page for Suspicious Activity

**Implementation Effort:** Low – This is a targeted action performed by Security Operations analysts to review and triage incidents in the Defender portal.  
**User Impact:** Low – All investigation and remediation actions occur within the admin experience; non‑privileged users are not required to take action.

## Overview
The Microsoft Defender for Office 365 Incidents page provides a consolidated view of alerts, related entities, and automated investigation results to help analysts detect and understand suspicious activity such as phishing, malware delivery, and anomalous email behavior. It correlates signals across Defender for Office 365 and other Defender XDR components to create a single incident, giving SecOps teams clear visibility into the scope and impact of a threat. Regularly reviewing this page ensures early detection of active attacks—if neglected, malicious emails, compromised mailboxes, or lateral movement attempts may go unnoticed and escalate into larger breaches. This activity supports the **Zero Trust “Assume Breach”** principle by strengthening threat detection through correlated analytics and deep visibility.

### Where to Access or Configure
You can access incidents in the Microsoft Defender portal:  
**Microsoft Defender XDR → Incidents & alerts → Incidents**  
Here you can filter by alert source (including Defender for Office 365), review suspicious entities, drill into email details, and launch or view automated investigations.  

## Reference
- [Manage incidents and alerts from Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/mdo-sec-ops-manage-incidents-and-alerts)
- [Investigate incidents in the Microsoft Defender portal](https://learn.microsoft.com/en-us/defender-xdr/investigate-incidents)
- [Microsoft Defender for Office 365 Security Operations Guide](https://learn.microsoft.com/en-us/defender-office-365/mdo-sec-ops-guide)
