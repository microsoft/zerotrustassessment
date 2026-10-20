Account-takeover threat actors regularly succeed against email filters — credential phishing, business-email-compromise lures, and AI-generated spear phishing reach inboxes after every automated control has decided the message is clean. The last line of detection in those cases is the user, but only if they have a one-click way to report the message and only if those reports actually reach somewhere a human responder can act on them. When user reporting is turned off, points to a mailbox no one watches, or skips Microsoft entirely, a successful phish reaches credential capture, the threat actor moves on to mailbox persistence and lateral campaigns against colleagues, and the SOC never learns the original message slipped through — so it cannot pull the same campaign out of other mailboxes before the attack progresses. Routing reports to Microsoft also feeds the global anti-phishing model so every customer benefits from every reported message. The recommended baseline turns on the built-in Outlook Report button, routes user-reported messages to both Microsoft (for re-evaluation and model training) and to a monitored SOC mailbox (so analysts can hunt the campaign), and exposes the submission queue programmatically through the Microsoft Graph email threat submission API so SOC tooling can ingest them automatically. A check that fails means the customer has a Report button that goes nowhere actionable — a known false-sense-of-security pattern.

**Remediation action**

- [User reported messages](https://learn.microsoft.com/en-us/defender-office-365/submissions-user-reported-messages-custom-mailbox)
- [Set-ReportSubmissionPolicy](https://learn.microsoft.com/en-us/powershell/module/exchange/set-reportsubmissionpolicy)
- [Submit messages and files to Microsoft for analysis](https://learn.microsoft.com/en-us/defender-office-365/submissions-admin)
- [Microsoft Report Message and Report Phishing add-ins](https://learn.microsoft.com/en-us/defender-office-365/submissions-users-report-message-add-in-configure)

<!--- Results --->
%TestResult%
