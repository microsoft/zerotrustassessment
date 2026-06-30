Anti-malware policies in Exchange Online Protection enforce the multi-engine malware scan, the Common Attachment Filter (which blocks executables and risky file types by extension regardless of engine verdict), zero-hour auto purge (ZAP) for messages reclassified as malicious after delivery, and the quarantine policy that determines whether a recipient can self-release a detected message.

Threat actors deliver malware as the second stage of the email kill chain immediately after a successful phish — typically as macro-enabled Office documents, ISO/IMG/VHD container files that bypass Mark-of-the-Web, HTML smuggling payloads, or password-protected archives that evade engine scanning. The Common Attachment Filter is the primary pre-delivery control that blocks these file types regardless of scan verdict, and ZAP is the only post-delivery control that retroactively removes messages whose verdict changes after delivery.

A default policy with the Common Attachment Filter disabled, ZAP disabled, or a quarantine policy that permits recipient self-release leaves the post-delivery branch of the kill chain unmitigated.

**Remediation action**

- [Configure anti-malware policies in EOP](https://learn.microsoft.com/en-us/defender-office-365/anti-malware-policies-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Recommended settings for EOP and Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/recommended-settings-for-eop-and-office365?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#anti-malware-policy-settings)
- [Set-MalwareFilterPolicy](https://learn.microsoft.com/en-us/powershell/module/exchange/set-malwarefilterpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Anti-malware protection in EOP](https://learn.microsoft.com/en-us/defender-office-365/anti-malware-protection-about?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%
