# Email Authentication Configuration in Microsoft 365

**Implementation Effort:** High
Implementing email authentication involves configuring multiple standards (SPF, DKIM, DMARC, ARC) which require ongoing management and monitoring [1](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-about).

**User Impact:** Medium
A subset of non-privileged users may need to be aware of changes, especially if email delivery issues arise due to misconfigurations [1](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-about).

## Overview
Email authentication in Microsoft 365 uses standards like SPF, DKIM, DMARC, and ARC to prevent spoofing and phishing attacks. These methods work together to ensure the integrity of email messages and protect against email-based threats.

## Reference
- [Email authentication in Microsoft 365 - Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-about)
- [Set up SPF to identify valid email sources for your Microsoft 365 domain](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-spf-configure)
- [Set up DKIM to sign mail from your Microsoft 365 domain](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-dkim-configure)
