Azure Rights Management Service (Azure RMS) is the foundational encryption and access control technology underlying Microsoft Information Protection. Without Azure RMS enabled, organizations cannot implement sensitivity labels with encryption, protect emails with Office 365 Message Encryption (OME), enforce information rights management (IRM) policies on SharePoint sites or OneDrive files, or deploy rights protection through mail flow rules. Azure RMS must be explicitly activated at the tenant level before any downstream protection features (labels with encryption, OME, mail flow rule protection, DLP encryption actions) can function. Organizations that have not activated Azure RMS cannot protect sensitive information at rest or in transit, leaving encrypted content capabilities unavailable regardless of how thoroughly other compliance features are configured. Enabling Azure RMS is a prerequisite for all other information protection capabilities and should be one of the first steps in implementing a comprehensive data protection strategy.

**Remediation action**

To enable Azure RMS:

1. Connect to Exchange Online: `Connect-ExchangeOnline`
2. Enable the service: `Set-IRMConfiguration -AzureRMSLicensingEnabled $true`
3. Verify activation: `Get-IRMConfiguration | Select-Object -Property AzureRMSLicensingEnabled`

- [Enable Azure Information Protection](https://learn.microsoft.com/en-us/purview/activate-rights-management-service)
- [IRM Configuration](https://learn.microsoft.com/en-us/exchange/policy-and-compliance/information-rights-management)

<!--- Results --->
%TestResult%
