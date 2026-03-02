# Hunt for Threats Using Email and Collaboration Advanced Hunting Tables

**Implementation Effort:** Medium – This requires SecOps teams to author, run, and maintain KQL queries using advanced hunting tables, which is a project‑level activity involving analysis and repeatable workflows..  
**User Impact:** Low – All activity is done by administrators; end users are not notified or required to take action.

## Overview
Email and collaboration advanced hunting tables in Microsoft Defender XDR—such as the **EmailEvents** table—provide detailed data about email processing events, detection signals, and threat indicators. Security teams use these tables to hunt for malicious emails, suspicious attachments, harmful URLs, and patterns of attacker behavior across collaboration workloads. These tables allow analysts to proactively detect phishing, malware delivery, and compromised account activity. If organizations do not regularly hunt using these tables, threats delivered through email may remain undetected, allowing attackers to perform lateral movement, steal data, or escalate privileges.  
This activity supports **Zero Trust: Assume Breach**, because it uses telemetry and analytics to detect threats early and reduce potential impact.

### Where to Access or Configure
You can access advanced hunting in the Microsoft Defender portal here:  
**Microsoft Defender XDR → Hunting → Advanced hunting**  
From there, you can run KQL queries using tables such as **EmailEvents**, which provide email‑level event details.  


## Reference
- [EmailEvents table in Microsoft Defender XDR advanced hunting schema](https://learn.microsoft.com/en-us/defender-office-365/mdo-sec-ops-manage-incidents-and-alerts)
- [Hunt for threats across devices, emails, apps, and identities](https://learn.microsoft.com/en-us/defender-xdr/investigate-incidents)
- [Advanced hunting examples for Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-xdr/incidents-overview)
