PDF files stored in SharePoint Online and OneDrive for Business require separate enablement of sensitivity label support beyond the base Office file integration. When `EnableSensitivityLabelforPDF` is disabled, organizations create a protection gap where PDF documents remain unclassified and unprotected despite sensitivity label policies being active for Office files.

**Remediation action**

To enable PDF labeling support in SharePoint Online:
1. Verify base integration is enabled: `Get-SPOTenant | Select-Object EnableAIPIntegration` (must be `$true`)
2. Connect to SharePoint Online: `Connect-SPOService -Url https://<tenant>-admin.sharepoint.com`
3. Enable PDF labeling: `Set-SPOTenant -EnableSensitivityLabelforPDF $true`
4. Wait for propagation (typically immediate, but can take up to 1 hour)
5. Test by uploading a PDF to SharePoint and applying a label through Office for the web

- [PDF support for sensitivity labels in SharePoint and OneDrive](https://learn.microsoft.com/purview/sensitivity-labels-sharepoint-onedrive-files#pdf-support)
- [Enable sensitivity labels for Office files in SharePoint and OneDrive](https://learn.microsoft.com/microsoft-365/compliance/sensitivity-labels-sharepoint-onedrive-files)

<!--- Results --->
%TestResult%
