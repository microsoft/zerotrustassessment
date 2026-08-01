<!-- markdownlint-disable MD041 -->
Advanced hunting in Microsoft Defender XDR lets security teams query event and entity data across email and collaboration telemetry using Kusto Query Language. Email and Collaboration tables such as `EmailEvents`, `EmailAttachmentInfo`, `EmailUrlInfo`, `EmailPostDeliveryEvents`, and `UrlClickEvents` help analysts find suspicious messages, attachments, links, clicks, and post-delivery actions that may not already be tied to an alert. Threat actors can use new sender patterns, weaponized links, or delivered attachments before alert rules fully identify the campaign. Hunting gives the SOC a way to look across initial access, credential access, lateral movement, and impact signals and connect them to incidents. This check only proves the API and table are available and returning data; it does not prove that skilled analysts are writing effective hunts or that hunts run on a useful cadence.

## Remediation action

- [Run a hunting query - Microsoft Graph](https://learn.microsoft.com/en-us/graph/api/security-security-runhuntingquery?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Advanced hunting schema tables](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-schema-tables?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Hunt for threats across devices, emails, apps, and identities](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-query-emails-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)

<!--- Results --->
%TestResult%
