Azure RMS includes both external and internal licensing capabilities that must be configured separately. While Azure RMS activation (test 35024) enables the service globally, internal RMS licensing specifically allows users and services within the organization to license protected content for internal distribution and sharing. Without internal RMS licensing enabled, users cannot share rights-protected content with internal recipients, preventing collaboration on encrypted emails and files within the organization. Internal RMS licensing must be explicitly enabled alongside super user configuration to ensure that legal holds, eDiscovery, and data recovery operations can access encrypted content. Organizations that have enabled Azure RMS but not internal licensing inadvertently block internal protected content sharing while potentially leaving external sharing unprotected. Both internal and external RMS licensing settings should be configured together as part of a comprehensive rights management strategy.

**Remediation action**

To enable internal RMS licensing:

1. Verify Azure RMS is enabled (test 35024) - internal licensing requires Azure RMS to be active
2. Sign in as Global Administrator to the [Microsoft Purview portal](https://purview.microsoft.com)
3. Navigate to Settings > Encryption > Azure Information Protection
4. Review RMS licensing configuration settings
5. Ensure internal licensing and distribution settings are enabled for the organization
6. If not enabled, contact Microsoft Support to activate internal licensing configuration

For organizations using Exchange Online, ensure mail flow policies and RMS features are not blocked:
1. Connect to Exchange Online: `Connect-ExchangeOnline`
2. Verify internal licensing is enabled: `Set-IRMConfiguration -InternalLicensingEnabled $true`
3. Verify the setting: `Get-IRMConfiguration | Select-Object -Property InternalLicensingEnabled, ExternalLicensingEnabled`

- [Configure Azure Rights Management licensing](https://learn.microsoft.com/en-us/purview/set-up-new-message-encryption-capabilities)
- [Rights Management in Exchange Online](https://learn.microsoft.com/en-us/purview/information-rights-management-in-exchange-online)

<!--- Results --->
%TestResult%
