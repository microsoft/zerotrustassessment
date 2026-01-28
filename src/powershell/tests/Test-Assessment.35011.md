The super user feature in Azure Information Protection grants designated accounts the ability to decrypt all content protected by the organization's Rights Management service, regardless of the encryption permissions originally assigned. Super users can access encrypted documents even when they are not explicitly granted permissions by the content owner, enabling scenarios such as eDiscovery, data recovery, compliance investigations, and migration from encrypted content. 

Without super user configuration, organizations risk data loss when encryption keys become inaccessible, employees leave without transferring ownership of critical encrypted files, or legal holds require access to protected content where the original rights holders cannot be reached. The super user feature must be explicitly enabled and membership must be carefully controlled—typically limited to service accounts used by compliance tools, backup systems, or eDiscovery platforms rather than individual user accounts. Failure to configure super users creates operational risk where encrypted content becomes permanently inaccessible, while overly broad super user membership creates security risk where unauthorized accounts gain unrestricted access to all protected content.

**Remediation action**

To configure super users:

1. Connect to Azure Information Protection PowerShell: `Connect-AipService`
2. Enable the super user feature: `Enable-AipServiceSuperUserFeature`
3. Add super users (service accounts recommended):
   - For user accounts: `Add-AipServiceSuperUser -EmailAddress "serviceaccount@contoso.com"`
   - For service principals: `Add-AipServiceSuperUser -ServicePrincipalId "service-principal-id"`
4. Verify configuration: `Get-AipServiceSuperUser`

Best practices:

- Limit super user membership to dedicated service accounts
- Use service principals for automated tools (eDiscovery, backup)
- Avoid assigning super user to individual employee accounts
- Audit super user access regularly
- Document business justification for each super user account

- [Configure super users for Azure Information Protection](https://learn.microsoft.com/en-us/purview/encryption-super-users)
- [Enable-AipServiceSuperUserFeature](https://learn.microsoft.com/en-us/powershell/module/aipservice/enable-aipservicesuperuserfeature)
- [Add-AipServiceSuperUser](https://learn.microsoft.com/en-us/powershell/module/aipservice/add-aipservicesuperuser)

<!--- Results --->
%TestResult%
