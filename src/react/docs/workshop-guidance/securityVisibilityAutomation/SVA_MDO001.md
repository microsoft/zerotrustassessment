# Configure Email Authentication

**Implementation Effort:** Medium – IT and Security teams must configure SPF, DKIM, and DMARC records, which involves DNS changes, Microsoft 365 configuration, and ongoing monitoring.

**User Impact:** High – While users don’t directly configure anything, the impact is high because misconfigured or missing authentication can cause legitimate emails to be marked as spam or rejected, disrupting communication across the organization.

## Overview

Email authentication in Microsoft 365 helps protect your organization from spoofing, phishing, and impersonation attacks. It uses three key standards:

- **SPF (Sender Policy Framework)**: Ensures only authorized IPs can send mail for your domain.
- **DKIM (DomainKeys Identified Mail)**: Adds a digital signature to verify message integrity.
- **DMARC (Domain-based Message Authentication, Reporting & Conformance)**: Aligns SPF and DKIM results and provides reporting to domain owners.

Together, these protocols validate that messages are truly from your domain and haven’t been altered in transit. Without proper configuration, your domain is vulnerable to abuse, and legitimate emails may be blocked or flagged as suspicious, leading to user confusion and loss of trust.

This aligns with the **Zero Trust principle of “Assume Breach”**, as it ensures all email traffic is authenticated and monitored, reducing the risk of impersonation and data exfiltration.

## Reference

- [Email authentication in Microsoft 365 – Overview](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-about)  
- [Set up SPF](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-spf-configure)  
- [Set up DKIM](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-dkim-configure) 
- [Set up DMARC](https://learn.microsoft.com/en-us/defender-office-365/email-authentication-dmarc-configure)

