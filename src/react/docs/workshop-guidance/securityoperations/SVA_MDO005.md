# Configure Antimalware Policies

**Implementation Effort:** Low
Creating and managing custom anti-malware policies requires IT teams to define rules, assign scopes (users/groups/domains), and maintain them over time, especially if not using preset security policies.

**User Impact:** Low  
These policies are enforced at the email gateway level, so end users are protected automatically without needing to take action or be notified.

## Overview

Antimalware policies in Microsoft Defender for Office 365 are used to detect and block malware in email messages. By default, Exchange Online Protection (EOP) applies a global policy to all users, but organizations can create custom policies for more granular control. These policies define how to handle malware in attachments, what notifications to send, and how to quarantine messages. Admins can configure them via the Microsoft Defender portal or PowerShell.

This capability supports the **"Assume Breach"** principle of Zero Trust by ensuring that all email content is scanned and filtered before reaching users, reducing the risk of malware spreading internally. Not configuring these policies—or relying solely on defaults—can leave gaps in protection, especially for high-risk users or domains.

## Reference

- [Configure anti-malware policies - Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/anti-malware-policies-configure)  


