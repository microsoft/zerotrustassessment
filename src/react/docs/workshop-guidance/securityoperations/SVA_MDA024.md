# Review Conditional Access App Control Alerts Along With the Activity Log (Daily)

**Implementation Effort:** Low — This is a targeted daily task for administrators to review alerts and activity logs, requiring no major deployment effort.  
**User Impact:** Low — Only administrators perform these reviews; end users are not notified or required to take action.

## Overview
Conditional Access App Control (CAAC) in Microsoft Defender for Cloud Apps provides real‑time visibility and control over user sessions to detect risky or suspicious actions. Reviewing CAAC alerts and the activity log daily helps identify unusual behaviors, policy violations, and potential threats early. Microsoft recommends reviewing these alerts and filtering the activity log by source, access control, and session control to quickly locate relevant events. If this activity is not done, suspicious actions may go unnoticed, increasing the risk of data exposure or account compromise.  
This activity supports the Zero Trust principle **Assume Breach**, as it uses continuous monitoring and analytics to detect and respond to threats.  

### Where to Review in the Product
You can perform this daily review in:  
- **Microsoft Defender Portal → Cloud Apps → Alerts**  
- **Microsoft Defender Portal → Cloud Apps → Activity Log**  
  (Daily operational guidance recommends focusing on CAAC alerts and filtering the activity logs for more effective review.) 

## Reference
- [Daily Operational Guide: Reviewing Conditional Access App Control Alerts](https://learn.microsoft.com/en-us/defender-cloud-apps/ops-guide/ops-guide-daily#review-conditional-access-app-control)
