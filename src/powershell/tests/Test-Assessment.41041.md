Microsoft Defender for Office 365 Automated Investigation and Response investigates email-related alerts and proposes remediation actions such as soft-deleting a malicious message from recipients' mailboxes, blocking a sender, URL, or file hash through the Tenant Allow/Block List, or moving suspicious mail to quarantine. When these recommended actions wait for analyst approval and the approval queue is not worked, the confirmed phishing or malware message remains in the recipient's mailbox while the verdict already says it is malicious; the user opens the link or attachment in the intervening minutes or hours and the threat actor obtains the credential or executes the payload — the detection landed but containment never reached the inbox. This check confirms there are no Microsoft Defender for Office 365 incidents left stale beyond the response window, so an email-side detection translates into removal from mailboxes rather than a paused investigation.

**Remediation action**

- [Automated investigation and response (AIR) in Office 365](https://learn.microsoft.com/en-us/defender-office-365/air-about)
- [Approve or reject pending actions in AIR](https://learn.microsoft.com/en-us/defender-office-365/air-review-approve-pending-completed-actions)
- [Action center in Microsoft 365 Defender](https://learn.microsoft.com/en-us/defender-xdr/m365d-action-center)
- [Investigate incidents in Microsoft 365 Defender](https://learn.microsoft.com/en-us/defender-xdr/investigate-incidents)

<!--- Results --->
%TestResult%
