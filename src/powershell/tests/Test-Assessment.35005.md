SharePoint Online and OneDrive for Business require explicit enablement of sensitivity label integration to allow users to apply Microsoft Information Protection labels to files stored in these services. When `EnableAIPIntegration` is disabled, organizations lose the ability to classify and protect documents at rest in their primary collaboration platform. The content is opaque to SharePoint capabilities and Purview services like eDiscovery is not available.

**Remediation action**

To enable sensitivity labels in SharePoint Online:
1. Connect to SharePoint Online: `Connect-SPOService -Url https://<tenant>-admin.sharepoint.com`
2. Enable sensitivity labels: `Set-SPOTenant -EnableAIPIntegration $true`
3. Wait up to 24 hours for propagation across all sites
4. Verify users can apply labels in Office for the web and desktop apps

- [Enable sensitivity labels for Office files in SharePoint and OneDrive](https://learn.microsoft.com/microsoft-365/compliance/sensitivity-labels-sharepoint-onedrive-files)
- [Sensitivity labels in SharePoint and OneDrive](https://learn.microsoft.com/purview/sensitivity-labels-sharepoint-onedrive-files)

<!--- Results --->
%TestResult%
