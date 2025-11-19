Without approval workflows, threat actors who compromise Global Administrator credentials through phishing, credential stuffing, or other authentication bypass techniques can immediately activate the most privileged role in a tenant without any other verification or oversight. Privileged Identity Management (PIM) allows eligible role activations to become active within seconds, so compromised credentials can allow near-instant privilege escalation. Once activated, threat actors can use the Global Administrator role to use the following attack paths to gain persistent access to the tenant:
- Create new privileged accounts
- Modify Conditional Access policies to exclude those new accounts
- Establish alternate authentication methods such as certificate-based authentication or application registrations with high privileges

The Global Administrator role provides access to administrative features in Microsoft Entra ID and services that use Microsoft Entra identities, including Microsoft Defender XDR, Microsoft Purview, Exchange Online, and SharePoint Online. Without approval gates, threat actors can rapidly escalate to complete tenant takeover, exfiltrating sensitive data, compromising all user accounts, and establishing long-term backdoors through service principals or federation modifications that persist even after the initial compromise is detected. 

**Remediation action**

- [Configure role settings to require approval for Global Administrator activation](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Set up approval workflow for privileged roles](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-approval-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

