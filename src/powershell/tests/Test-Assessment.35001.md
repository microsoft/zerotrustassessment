Microsoft Rights Management Service (RMS) is the protection technology that enforces encryption for sensitivity labels and information protection policies. When users access encrypted content, their applications must authenticate to the RMS service (App ID: `00000012-0000-0000-c000-000000000000`) to decrypt the content. If Conditional Access policies incorrectly block or restrict this authentication - for example, by requiring multi-factor authentication (MFA), device compliance, or specific network locations - users will be unable to open encrypted emails, documents, or files protected by sensitivity labels.
This is most notable when trying to collaborate on MIP protected content from an external tenant to the source tenant.
The RMS service should be explicitly excluded from Conditional Access policies that enforce authentication controls, as the application itself is handling the decryption and the user has already authenticated through their primary client application. Blocking RMS authentication prevents the decryption process and breaks information protection workflows across Microsoft 365 services including Outlook, Word, Excel, PowerPoint, Teams, and SharePoint.

**Remediation action**

To exclude RMS from Conditional Access policies:
1. Navigate to [Microsoft Entra admin center > Entra ID > Conditional Access > Policies](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies)
2. Select the policy that is blocking RMS
3. Under Target resources > All resources (formerly 'All cloud apps')
4. Under Exclude, select 'Select resources' and add "Microsoft Rights Management Services" (App ID: `00000012-0000-0000-c000-000000000000`)
5. Save the policy

- [Microsoft Entra configuration for Azure Information Protection](https://learn.microsoft.com/purview/encryption-azure-ad-configuration)
- [Conditional Access policies and encrypted documents](https://learn.microsoft.com/purview/encryption-azure-ad-configuration#conditional-access-policies-and-encrypted-documents)
- [Conditional Access: Cloud apps, actions, and authentication context](https://learn.microsoft.com/entra/identity/conditional-access/concept-conditional-access-cloud-apps)

<!--- Results --->
%TestResult%
