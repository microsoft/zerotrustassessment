# Investigate Incident Details & Remediate as Necessary (Daily)

**Implementation Effort:** Medium — Security operations teams must perform daily review and triage of incidents, which requires ongoing analyst time but no major implementation projects.  
**User Impact:** Low — All work happens within security teams; end users do not need to take action or be notified of changes.

## Overview
Daily investigation of incidents in Microsoft Defender for Endpoint gives security analysts a complete understanding of ongoing threats by correlating alerts, devices, users, evidence, and automated investigation results into a single incident. Defender automatically investigates supported events and suspicious entities, helping analysts quickly identify impacted assets, suspicious processes, and malicious files. Reviewing incidents daily reduces attacker dwell time and enables fast remediation steps such as isolating devices or approving automated remediation actions. If this review is not done regularly, threats may persist longer, increasing the chances of data exposure, lateral movement, or system disruption.

This supports the Zero Trust **Assume Breach** principle by ensuring constant monitoring, rapid response, and thorough investigation to limit the blast radius of any intrusion.

### Where to investigate and remediate
You can view and investigate incidents in the following areas of the Microsoft Defender portal:

- **Incidents & alerts → Incidents** — provides correlated alerts, assets, investigations, and evidence from across your environment.  
  [Investigate incidents in Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/investigate-incidents)  
- **Incident details page** — shows alerts, affected devices, user accounts, mailboxes, and automated investigation results.  
  [View the details and results of an automated investigation](https://learn.microsoft.com/en-us/defender-endpoint/autoir-investigation-results)  
- **Automated investigations** — includes information about suspicious entities and remediation actions automatically performed or awaiting approval.  
  [Investigate incidents in Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/investigate-incidents)

## Reference
- [Investigate incidents in Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/investigate-incidents)  
- [Investigate incidents in Microsoft Defender XDR](https://learn.microsoft.com/en-us/defender-xdr/investigate-incidents)  
- [View the details and results of an automated investigation](https://learn.microsoft.com/en-us/defender-endpoint/autoir-investigation-results)
