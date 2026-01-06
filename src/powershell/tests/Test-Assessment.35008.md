SharePoint document libraries support configuring default sensitivity labels that automatically apply baseline protection to new or edited files that lack existing labels or have lower-priority labels. When the tenant-level capability `DisableDocumentLibraryDefaultLabeling` is enabled (set to `$true`), organizations block site administrators from establishing automatic baseline classification for document libraries.
Using default labels is a critical feature in organizations' auto-labeling strategy. 

**Remediation action**

To enable the default sensitivity label capability for SharePoint document libraries:
1. Verify sensitivity labels are enabled for SharePoint: `(Get-SPOTenant).EnableAIPIntegration` (must be `$true`)
2. Connect to SharePoint Online: `Connect-SPOService -Url https://<tenant>-admin.sharepoint.com`
3. Enable default library labeling capability (if disabled): `Set-SPOTenant -DisableDocumentLibraryDefaultLabeling $false`
4. Wait approximately 15 minutes for tenant-level change to propagate
5. Site admins can then configure default labels on individual libraries via library settings

- [Configure a default sensitivity label for a SharePoint document library](https://learn.microsoft.com/microsoft-365/compliance/sensitivity-labels-sharepoint-default-label)
- [Add a sensitivity label to SharePoint document library](https://support.microsoft.com/office/54b1602b-db0a-4bcb-b9ac-5e20cbc28089)
- [Enable sensitivity labels for SharePoint and OneDrive](https://learn.microsoft.com/microsoft-365/compliance/sensitivity-labels-sharepoint-onedrive-files)

<!--- Results --->
%TestResult%
