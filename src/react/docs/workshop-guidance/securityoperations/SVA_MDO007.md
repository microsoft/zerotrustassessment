# Set up Anti-Spam Policies in Microsoft Defender for Office 365

**Implementation Effort:** Low  
Admins can apply preset or custom anti-spam policies using the Microsoft Defender portal with minimal configuration effort.

**User Impact:** Medium  
Some users may need to check quarantine notifications, report false positives, or adjust safe sender lists based on how spam filtering affects their mail flow.

## Overview

Anti-spam policies in Microsoft Defender for Office 365 (MDO) help protect your organization from spam, phishing, and spoofing attacks. These policies are part of Exchange Online Protection (EOP) and can be applied globally or scoped to specific users, groups, or domains. Admins can use the Microsoft Defender portal or PowerShell to configure these policies, or apply Microsoft’s preset security policies (Standard or Strict) for simplified deployment.

If anti-spam policies are not configured, malicious or unwanted emails may reach users, increasing the risk of credential theft, malware infections, or data loss.

This setup supports the **"Assume breach"** principle of Zero Trust by filtering threats before they reach users and isolating suspicious messages in quarantine.

## Reference

- [Configure spam filter policies - Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/anti-spam-policies-configure)  
- [Anti-spam protection overview](https://learn.microsoft.com/en-us/defender-office-365/anti-spam-protection-about)  
- [Preset security policies](https://learn.microsoft.com/en-us/defender-office-365/preset-security-policies)
