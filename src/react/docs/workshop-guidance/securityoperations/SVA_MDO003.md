# Identify and Set Up Priority Accounts and User Tags in Microsoft Defender for Office

**Implementation Effort:** Medium  
This requires IT and Security Operations teams to identify high-risk users (like executives), apply tags, and configure policies and reporting in the Microsoft Defender portal.

**User Impact:** Low  
Only administrators are involved in tagging and configuration; end users are not required to take any action or be notified.

## Overview

In Microsoft Defender for Office 365 Plan 2, **priority accounts** are designated users—typically executives or other high-value targets—who receive enhanced protection against phishing and targeted attacks. These accounts are tagged with the **Priority account** user tag, which enables Defender to apply specialized heuristics and mail flow analysis tailored to their communication patterns. This helps detect and mitigate threats that might bypass standard protections.

**User tags** in Defender for Office 365 allow admins to classify users into categories (e.g., VIPs, departments) for better filtering in alerts, reports, and investigations. While custom tags can be created, only the **Priority account** tag has a direct impact on protection features.

Failing to identify and tag priority accounts can leave high-risk users more vulnerable to advanced threats, reducing the effectiveness of your Zero Trust strategy.

This feature supports the **"Assume breach"** principle by proactively segmenting and monitoring high-risk users, ensuring they receive elevated protection and visibility.

## Reference

- [Configure and review priority account protection in Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/priority-accounts-turn-on-priority-account-protection)  
- [User tags in Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/user-tags-about)  
- [Manage and monitor priority accounts](https://learn.microsoft.com/en-us/microsoft-365/admin/setup/priority-accounts?view=o365-worldwide)
