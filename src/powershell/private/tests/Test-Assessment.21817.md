Without approval workflows, threat actors who compromise Global Administrator credentials through phishing, credential stuffing, or other authentication bypass techniques can immediately activate the most privileged role in the tenant without any additional verification or oversight. Since PIM allows eligible role activations to become active within seconds, compromised credentials enable near-instant privilege escalation. Once activated, threat actors leverage the Global Administrator role for persistent access by creating additional privileged accounts, modifying conditional access policies to exclude their accounts, and establishing alternate authentication methods such as certificate-based authentication or application registrations with high privileges. The Global Administrator role provides access to administrative features in Microsoft Entra ID and services that use Microsoft Entra identities, including Microsoft 365 Defender, Microsoft Purview, Exchange Online, and SharePoint Online. Without approval gates, threat actors can rapidly escalate to complete tenant takeover, exfiltrating sensitive data, compromising all user accounts, and establishing long-term backdoors through service principals or federation modifications that persist even after the initial compromise is detected.

**Remediation action**

Configure role settings to require approval for Global Administrator activation 
- [Configure Microsoft Entra role settings in Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings)

Set up approval workflow for privileged roles
- [Approve or deny requests for Microsoft Entra roles in Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-approval-workflow)
<!--- Results --->
%TestResult%
