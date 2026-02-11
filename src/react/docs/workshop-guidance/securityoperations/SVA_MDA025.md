# Review the App Governance Overview Page and Create or Adjust App Governance Policies (Daily)

**Implementation Effort:** Low — This is a targeted daily action where administrators review insights and adjust app governance policies as needed.  
**User Impact:** Low — Only administrators perform these tasks; non‑privileged users are not required to take action.

## Overview
App governance in Microsoft Defender for Cloud Apps helps organizations monitor OAuth-enabled applications, assess their permissions, and detect anomalous or risky behaviors. The *App governance overview* page provides a daily snapshot of app posture, highlighting over‑privileged apps, unusual activity, unverified publishers, and other risks. Administrators should review this view daily and create or adjust app governance policies to mitigate emerging risks. If this task is not performed, risky or malicious apps may go unnoticed, exposing sensitive data or increasing the chances of account compromise.  
This activity supports the Zero Trust principle **Assume Breach**, because app governance uses continuous analytics to identify anomalies and reduce threat impact.

### Where to Review and Configure
In the Microsoft Defender portal:  
- **Cloud Apps → App Governance → Overview** for daily posture review  
- **Cloud Apps → App Governance → Policies** to create or adjust governance policies  
(Daily operational activities are outlined in the Defender for Cloud Apps operational guide.) [1](https://learn.microsoft.com/en-us/defender-cloud-apps/ops-guide/ops-guide-daily)

## Reference
- [Daily operational guide – Microsoft Defender for Cloud Apps](https://learn.microsoft.com/en-us/defender-cloud-apps/ops-guide/ops-guide-daily#check-app-governance-overview-page)
- [Get started with app governance policies](https://learn.microsoft.com/en-us/defender-cloud-apps/app-governance-app-policies-get-started)
- [Create app governance policies](https://learn.microsoft.com/en-us/defender-cloud-apps/app-governance-app-policies-create)
