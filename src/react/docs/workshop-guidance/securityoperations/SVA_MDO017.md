# Configure Teams protection policies

**Implementation Effort:** Medium — IT and SecOps teams must configure multiple Defender for Office 365 protection layers (Safe Links, Safe Attachments, ZAP, and reporting), which requires a coordinated project rather than a single action.

**User Impact:** Low — Most protections run automatically in the background; users are not required to take action unless optional reporting features are enabled.

## Overview
Microsoft Teams protection policies in Microsoft Defender for Office 365 provide security controls that scan URLs, files, and messages shared in Teams. These protections use Safe Attachments, Safe Links, Zero-hour Auto Purge (ZAP), and user‑reported message pipelines to identify and remove malware, unsafe links, and malicious messages. Without these configurations, Teams becomes a collaboration channel where threats can spread unchecked, increasing organizational risk.

This capability supports the **Zero Trust “Assume Breach” principle**, because it continuously scans content at delivery and after delivery, blocks malicious artifacts, and automatically purges detected threats.

### Where to configure this in the product
- **Safe Attachments for Teams**  
  Microsoft Defender portal → https://security.microsoft.com/safeattachmentv2  
  Verify **Turn on Defender for Office 365 for SharePoint, OneDrive, and Microsoft Teams** is enabled.

- **Safe Links for Teams**  
  Microsoft Defender portal → https://security.microsoft.com/safelinksv2  
  Open each custom policy → Enable the **Teams** toggle.

- **Unsafe link warnings in Teams (Preview)**  
  Teams Admin Center → https://admin.teams.microsoft.com/messaging/settings  
  Turn on **Scan messages for unsafe links**.

- **Zero-hour Auto Purge (ZAP) for Teams**  
  Microsoft Defender portal → https://security.microsoft.com/securitysettings/teamsProtectionPolicy  
  Enable ZAP and configure any exclusions.

- **User‑reported message settings (Teams)**  
  Teams Admin Center → Global or Custom messaging policies  
  Enable **Report a security concern** and **Report incorrect security detections**.  
  Defender portal → https://security.microsoft.com/securitysettings/userSubmission  
  Ensure **Monitor reported messages in Microsoft Teams** is selected.

## Reference
- [Security Operations Guide for Teams protection — Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/mdo-support-teams-quick-configure)
- [Quickly configure Microsoft Teams protection in Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/mdo-support-teams-sec-ops-guide)
