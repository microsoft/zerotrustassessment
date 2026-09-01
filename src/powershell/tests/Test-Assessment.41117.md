Submissions are the feedback path that lets admins and users send suspected spam, phishing, malware, and false positives to Microsoft Defender for Office 365 for analysis. Microsoft Learn describes admin submissions from the Defender portal and user-reported messages that can be submitted or resubmitted by admins. These reports help confirm whether filtering, policy hits, payload reputation, detonation, or grader review should change a verdict. This matters because threat actors constantly adjust sender infrastructure, links, and attachments; without a regular submission flow, false negatives may stay delivered and false positives may push teams toward broad allow entries instead of correction. If this check fails, no email threat submissions were found in the last 30 days, or there are no admin-source submissions showing SOC engagement. A low-volume tenant might not submit every week, and this API is beta and Global-only, so absence of data should be interpreted with tenant size, cloud, and operating model in mind.

## Remediation action

- [Manage submissions in Microsoft Defender for Office 365](https://learn.microsoft.com/en-us/defender-office-365/submissions-admin)
- [Report messages and files to Microsoft](https://learn.microsoft.com/en-us/defender-office-365/submissions-report-messages-files-to-microsoft)
- [User-reported messages settings](https://learn.microsoft.com/en-us/defender-office-365/submissions-user-reported-messages-custom-mailbox)
- [List emailThreatSubmissions - Microsoft Graph beta](https://learn.microsoft.com/en-us/graph/api/security-emailthreatsubmission-list?view=graph-rest-beta&tabs=http)

<!--- Results --->
%TestResult%
