# Regularly submit admin and user false positives/false negatives to Microsoft (Defender for Office 365)

**Implementation Effort:** Medium — Requires IT/SecOps to set up and maintain an ongoing process for reviewing and submitting misclassified messages.  
**User Impact:** Medium — Some subset of users must report suspicious or misclassified emails through Outlook.

## Overview
Submitting false positives (legitimate mail incorrectly blocked) and false negatives (malicious mail incorrectly delivered) helps Microsoft Defender for Office 365 improve its filtering logic and better protect your organization. Admins can submit messages directly through the Submissions portal, and users can report emails from Outlook using built‑in reporting tools. If this capability is not used regularly, threat filters may remain inaccurate, increasing the risk of phishing, malware exposure, or productivity loss. This supports the Zero Trust principle of **Assume Breach**, because continuous classification feedback improves detection quality and reduces repeated attacker success.

### Where to configure or use this capability
- **Microsoft Defender XDR → Email & Collaboration → Submissions**  
  Admins can submit false positives/negatives for emails, URLs, and attachments.  
  (No images available in the Microsoft Learn articles surfaced.)  
- **Outlook (desktop/web/mobile)**  
  Users report suspicious or misclassified messages using the *Report* or *Report Phishing* buttons, which feed into the admin review workflow.

## Reference
- https://learn.microsoft.com/en-us/defender-office-365/air-report-false-positives-negatives  
- https://learn.microsoft.com/en-us/defender-office-365/step-by-step-guides/how-to-handle-false-positives-in-microsoft-defender-for-office-365  
- https://learn.microsoft.com/en-us/defender-office-365/step-by-step-guides/how-to-handle-false-negatives-in-microsoft-defender-for-office-365  
- https://learn.microsoft.com/en-us/defender-office-365/submissions-outlook-report-messages  
- https://learn.microsoft.com/en-us/defender-office-365/submissions-admin-review-user-reported-messages  
- https://learn.microsoft.com/en-us/defender-office-365/submissions-admin
