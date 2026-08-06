Email content can be judged clean at the moment of delivery and later be reclassified as malware, phishing, or spam once new threat intelligence arrives. Without zero-hour auto purge, that reclassified message stays in the user's inbox, the user opens the attachment or follows the link in the minutes or hours after delivery, and the threat actor obtains the credential or executes the payload — the protection arrived but never reached the user. Zero-hour auto purge, a capability of Exchange Online Protection available to all cloud mailboxes, retroactively moves the message to quarantine or the Junk Email folder after the verdict changes, closing the gap between delivery and detection. This check confirms zero-hour auto purge is enabled for malware, phishing, and spam in email, so a delayed verdict still results in containment.

**Remediation action**

- [Zero-hour auto purge (ZAP) in Exchange Online](https://learn.microsoft.com/en-us/defender-office-365/zero-hour-auto-purge)
- [Set-MalwareFilterPolicy](https://learn.microsoft.com/en-us/powershell/module/exchange/set-malwarefilterpolicy)
- [Set-HostedContentFilterPolicy](https://learn.microsoft.com/en-us/powershell/module/exchange/set-hostedcontentfilterpolicy)

<!--- Results --->
%TestResult%
