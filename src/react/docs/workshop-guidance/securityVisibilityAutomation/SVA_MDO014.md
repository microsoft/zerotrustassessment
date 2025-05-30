# Manage Allows and Blocks in the Tenant Allow/Block List

**Implementation Effort:** Medium  
This requires IT and Security Operations teams to configure and maintain allow/block entries across multiple vectors (email, URLs, files, IPs), and potentially integrate with PowerShell or submission workflows.

**User Impact:** Low  
End users are not directly involved; changes are handled by administrators and affect backend filtering behavior.

## Overview

The **Tenant Allow/Block List** in Microsoft Defender for Office 365 enables administrators to manually override Microsoft’s filtering verdicts for emails, URLs, files, and IP addresses. This is useful when legitimate messages are incorrectly flagged (false positives) or malicious content is missed (false negatives). Admins can allow or block specific senders, spoofed domains, URLs, or files, and these decisions influence mail flow and time-of-click protection. Block entries take precedence over allow entries, and internal spoofing is handled with special logic.

This feature supports the **"Assume Breach"** principle of Zero Trust by giving organizations the ability to proactively block known threats and reduce reliance on automated verdicts alone. If not implemented, organizations risk exposure to phishing, malware, or spoofing attacks that bypass default filters.

## Reference

- [Manage allows and blocks in the Tenant Allow/Block List](https://learn.microsoft.com/en-us/defender-office-365/tenant-allow-block-list-about)
- [Allow or block email using the Tenant Allow/Block List](https://learn.microsoft.com/en-us/defender-office-365/tenant-allow-block-list-email-spoof-configure)
- [Allow or block URLs using the Tenant Allow/Block List](https://learn.microsoft.com/en-us/defender-office-365/tenant-allow-block-list-urls-configure)
