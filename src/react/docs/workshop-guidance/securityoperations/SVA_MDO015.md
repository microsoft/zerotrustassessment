# Configure Outbound Spam Policy

**Implementation Effort:** Medium  
Outbound spam policy configuration requires IT administrators to define and manage policies in the Microsoft Defender portal or via PowerShell, and may involve coordination with security teams to monitor alerts and adjust settings.

**User Impact:** Low  
End users are not directly affected unless their accounts are flagged for suspicious activity, in which case administrative action is taken without requiring broad user communication.

## Overview

Outbound spam policies in Microsoft 365 help detect and block spam or malicious emails sent from within your organization. These policies are part of Exchange Online Protection (EOP) and Microsoft Defender for Office 365. They are crucial for preventing compromised accounts from damaging your organization’s reputation or getting Microsoft’s email servers blacklisted. The default policy applies to all users, but custom policies can be created for specific users, groups, or domains.

Admins can configure these policies through the Microsoft Defender portal or PowerShell. Suspicious outbound messages are automatically flagged and routed through a high-risk delivery pool. Alerts are generated for administrators when users are blocked due to suspicious activity. If outbound spam policies are not configured, your organization risks undetected account compromise, potential data exfiltration, and damage to email deliverability.

This capability supports the **"Assume breach"** principle of Zero Trust by treating all outbound traffic as potentially risky and applying controls to detect and contain threats.

## Reference

- [Configure outbound spam policies - Microsoft Learn](https://learn.microsoft.com/en-us/defender-office-365/outbound-spam-policies-configure)  
- [External email forwarding controls](https://learn.microsoft.com/en-us/defender-office-365/outbound-spam-policies-external-email-forwarding)
