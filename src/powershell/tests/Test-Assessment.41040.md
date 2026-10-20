The Tenant Allow/Block List is an admin-controlled override of Microsoft's filtering verdicts in Microsoft Defender for Office 365. Each allow entry is a deliberate exception that bypasses spam, bulk, and non-high-confidence phishing filters for a specific sender, URL, or file hash. The risk is drift: an allow entry created for a legitimate business reason — a vendor that fails strict SPF, a URL the filter false-positives on — is not removed after that reason ends. The partner account is later compromised, the vendor changes hands, or the admin who created the entry leaves the company, and the entry remains as a permanent filter bypass. A threat actor who reuses the allowed sender, registers a lookalike under the allowed domain, or replays the allowed file hash delivers spam, bulk, or phishing messages with the false legitimacy of a tenant-trusted entry, and those messages do not face the filter verdicts that would otherwise stop them. Direct allow entries cannot override malware or high-confidence phishing verdicts, so the blast radius is bounded — but credential-harvesting and business email compromise payloads do not require malware to succeed. This check identifies admin-controlled allow entries that are unbounded, undocumented, or stale, so that drift in this high-trust override does not become a permanent gap.

**Remediation action**

- [Manage the Tenant Allow/Block List](https://learn.microsoft.com/en-us/defender-office-365/tenant-allow-block-list-about)
- [Allow or block emails using the Tenant Allow/Block List](https://learn.microsoft.com/en-us/defender-office-365/tenant-allow-block-list-email-spoof-configure)
- [Allow or block URLs using the Tenant Allow/Block List](https://learn.microsoft.com/en-us/defender-office-365/tenant-allow-block-list-urls-configure)
- [Submit messages and files to Microsoft for analysis](https://learn.microsoft.com/en-us/defender-office-365/submissions-admin)
- [Configure the advanced delivery policy for third-party phishing simulations](https://learn.microsoft.com/en-us/defender-office-365/advanced-delivery-policy-configure)

<!--- Results --->
%TestResult%
