Office 365 Message Encryption (OME) allows organizations to send encrypted emails and protect sensitive information. When custom branding templates are not configured for OME, external recipients receive a generic Microsoft-branded encryption portal experience. This generic branding may reduce user confidence in the legitimacy of encrypted messages, as external recipients cannot immediately associate the encryption experience with the sending organization. Custom branding templates allow organizations to apply their company logo, custom colors, disclaimer text, and contact information to the OME portal, reinforcing organizational identity and improving user experience for external recipients. Configuring at least one OME custom branding template ensures that encrypted communications reflect the organization's brand and establish trust with external recipients by presenting a familiar, professional appearance that clearly identifies the message source.

**Remediation action**

To configure custom branding for Office 365 Message Encryption:

1. OME custom branding is configured via PowerShell only; there is no UI in the Exchange or Purview portals. See the New-OMEConfiguration cmdlet documentation for configuration syntax.

2. Create a new OME configuration with custom branding:
   - Documentation: [New-OMEConfiguration](https://learn.microsoft.com/en-us/powershell/module/exchange/new-omeconfiguration?view=exchange-ps)
   - Documentation: [Set-OMEConfiguration](https://learn.microsoft.com/en-us/powershell/module/exchange/set-omeconfiguration?view=exchange-ps)

3. Verify custom branding is applied:
   - Documentation: [Get-OMEConfiguration](https://learn.microsoft.com/en-us/powershell/module/exchange/get-omeconfiguration?view=exchange-ps)
   - Run: `Get-OMEConfiguration | Format-List` to view all configurations and their branding settings

4. Learn more about OME custom branding and requirements:
   - [Add your organization's brand to your encrypted messages](https://learn.microsoft.com/en-us/purview/add-your-organization-brand-to-encrypted-messages)
   - [Microsoft Purview Message Encryption](https://learn.microsoft.com/en-us/purview/ome-advanced-message-encryption)


<!--- Results --->
%TestResult%
