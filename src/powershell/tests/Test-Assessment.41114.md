Microsoft Teams is a common collaboration channel, so threat actors can use chats, channels, and meeting conversations for social engineering, malicious URLs, and files shared through Teams-backed SharePoint or OneDrive storage. Microsoft Defender for Office 365 adds Teams protections beyond built-in warnings: Safe Links checks Teams URLs at time of click, Safe Attachments detonates files shared in Teams storage, ZAP for Teams quarantines malware and high confidence phishing messages after delivery, and the Defender submission policy can monitor user-reported Teams items. These controls reduce the chance that initial access through a chat becomes credential access, malware execution, lateral movement, or impact. If this check fails, one or more Teams delivery paths remains weak: a user might click a weaponized link after delivery, open a malicious file, miss a post-delivery quarantine action, or lack Defender monitoring for Teams reports. This check verifies configuration, not every user's license assignment or every Teams admin-center setting, so review exceptions and license coverage separately.

## Remediation resources

- [Microsoft Defender for Office 365 support for Microsoft Teams](https://learn.microsoft.com/en-us/defender-office-365/mdo-support-teams-about)
- [Safe Attachments for SharePoint, OneDrive, and Microsoft Teams](https://learn.microsoft.com/en-us/defender-office-365/safe-attachments-for-spo-odfb-teams-about)
- [Safe Links in Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/safe-links-about)
- [User reported settings in Teams](https://learn.microsoft.com/en-us/defender-office-365/submissions-teams)

<!--- Results --->
%TestResult%
