Cross-tenant access policies (XTAP) in Microsoft Entra ID control how users in your organization collaborate with external organizations. When users share encrypted content across organizational boundaries or receive encrypted documents from external partners, the Microsoft Rights Management Service (RMS) must authenticate users from both organizations to enforce encryption permissions. If cross-tenant access settings block or restrict the RMS application (App ID: `00000012-0000-0000-c000-000000000000`), users will encounter "Access is blocked by your organization" or "Access is blocked by the organization" error messages when attempting to open encrypted emails or documents from external organizations. This prevents legitimate cross-organizational collaboration on protected content. Organizations should configure both inbound and outbound cross-tenant access settings to explicitly allow the RMS application, ensuring that external users can open encrypted content shared by your organization (inbound) and your users can open encrypted content received from external partners (outbound). Without proper XTAP configuration, encrypted content sharing fails even when users have appropriate permissions assigned through sensitivity label encryption settings.

**Remediation action**

To configure cross-tenant access settings to allow RMS:
1. Navigate to [Microsoft Entra admin center > External Identities > Cross-tenant access settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/CrossTenantAccessSettings)
2. Select "Default settings" or a specific organizational setting
3. Under "Inbound access", select "B2B collaboration"
4. Select "Applications" tab
5. Choose "Allow access" and add "Microsoft Rights Management Services" (App ID: `00000012-0000-0000-c000-000000000000`)
6. Repeat for "Outbound access" settings
7. Save changes

- [Cross-tenant access settings and encrypted content](https://learn.microsoft.com/purview/encryption-azure-ad-configuration#cross-tenant-access-settings-and-encrypted-content)
- [Configure cross-tenant access settings for B2B collaboration](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration)

<!--- Results --->
%TestResult%
