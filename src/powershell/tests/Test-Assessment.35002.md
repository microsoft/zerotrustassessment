When your users send or share encrypted files or emails with people outside your organization, or receive encrypted content from partners, Microsoft Entra ID needs to verify identities. It does this verification for both sides of the send and receive to enforce the encryption settings. If your cross-tenant access settings block access to the Azure Rights Management service, those users see an "Access is blocked by your organization" error. In this scenario, they can't open the protected content.

Allow the Microsoft Rights Management Services app by configuring your cross-tenant access settings for both inbound traffic (external users opening content you share) and outbound traffic (your users opening content from partners). Without this configuration, encrypted content sharing breaks, even when the right permissions are assigned.

**Remediation action**

- [Cross-tenant access settings and encrypted content](https://learn.microsoft.com/purview/encryption-azure-ad-configuration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#cross-tenant-access-settings-and-encrypted-content)
- [Configure cross-tenant access settings for B2B collaboration](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

