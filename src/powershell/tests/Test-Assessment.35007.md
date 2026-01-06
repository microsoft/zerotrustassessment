Information Rights Management (IRM) integration in SharePoint Online libraries is a legacy feature that has been replaced by Enhanced SharePoint Permissions (ESP). Any library using this legacy capability should be flagged to move to newer capabilities.

**Remediation action**

To disable legacy IRM in SharePoint Online:
1. Identify libraries currently using IRM protection (audit existing sites)
2. Plan migration to modern sensitivity labels with encryption
3. Connect to SharePoint Online: `Connect-SPOService -Url https://<tenant>-admin.sharepoint.com`
4. Disable legacy IRM: `Set-SPOTenant -IrmEnabled $false`
5. Enable modern sensitivity labels: `Set-SPOTenant -EnableAIPIntegration $true`
6. Configure and publish sensitivity labels with encryption to replace IRM policies

- [Enable sensitivity labels for SharePoint and OneDrive](https://learn.microsoft.com/microsoft-365/compliance/sensitivity-labels-sharepoint-onedrive-files)
- [SharePoint IRM and sensitivity labels (migration guidance)](https://learn.microsoft.com/microsoft-365/compliance/sensitivity-labels-sharepoint-onedrive-files#sharepoint-information-rights-management-irm-and-sensitivity-labels)
- [Create and configure sensitivity labels with encryption](https://learn.microsoft.com/microsoft-365/compliance/encryption-sensitivity-labels)

<!--- Results --->
%TestResult%
