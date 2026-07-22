Anti-spam policies (also called hosted content filter policies) decide what Exchange Online Protection does with inbound messages that the spam filter classifies as spam, high-confidence spam, phishing, high-confidence phishing, or bulk — quarantine the message, move it to the user's Junk Email folder, or deliver it untouched. Threat actors abuse over-permissive anti-spam configurations in two predictable ways. They slip credential-harvesting and malware-laden messages below a loose bulk-complaint threshold so the messages reach inboxes that should have rejected them; and they exploit the per-policy allowed-sender list — a single domain added to fix a one-time deliverability complaint bypasses spam, spoofing, and most phishing checks for every future message from that domain, so when the domain is later compromised or impersonated, phishing flows in without inspection. Microsoft's documented recommendation is to quarantine high-confidence verdicts with admin-only release, keep the bulk threshold low enough that genuine bulk traffic is filtered, and never use the per-policy allow lists for routine exceptions — narrow, time-bounded entries belong in the Tenant Allow/Block List, where they can be reviewed and expired. Some teams worry that strict quarantine actions will lose legitimate vendor mail; the recommended quarantine policies route everything to admin review first, so messages can be released without the recipient ever seeing them.

**Remediation action**

- [Anti-spam protection in EOP](https://learn.microsoft.com/en-us/defender-office-365/anti-spam-protection-about)
- [Configure anti-spam policies in EOP](https://learn.microsoft.com/en-us/defender-office-365/anti-spam-policies-configure)
- [Set-HostedContentFilterPolicy](https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/set-hostedcontentfilterpolicy?view=exchange-ps)
- [Bulk complaint level (BCL) values](https://learn.microsoft.com/en-us/defender-office-365/anti-spam-bulk-complaint-level-bcl-about)
- [Recommended anti-spam settings](https://learn.microsoft.com/en-us/defender-office-365/recommended-settings-for-eop-and-office365#anti-spam-policy-settings)

<!--- Results --->
%TestResult%
