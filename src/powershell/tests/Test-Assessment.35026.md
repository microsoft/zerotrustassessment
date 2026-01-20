Office 365 Message Encryption (OME) provides encryption and access controls for emails in your organization. The SimplifiedClientAccessEnabled setting controls whether the Protect button is available in Outlook on the web, allowing users to quickly apply encryption protections to their messages. When enabled, users can click Protect to encrypt emails directly from Outlook on the web. When disabled, the Protect button is not available and users must use alternative encryption methods. Enabling SimplifiedClientAccessEnabled enhances user experience by providing straightforward encryption directly in Outlook on the web. SimplifiedClientAccessEnabled requires AzureRMSLicensingEnabled to be active, as Azure Rights Management is the underlying encryption foundation.

**Remediation action**

To enable SimplifiedClientAccessEnabled for OME:

1. Connect to Exchange Online: `Connect-ExchangeOnline`
2. Retrieve current IRM configuration: `Get-IRMConfiguration`
3. If SimplifiedClientAccessEnabled is false, enable it: `Set-IRMConfiguration -SimplifiedClientAccessEnabled $true`
4. Verify the change: `Get-IRMConfiguration | Select-Object -Property SimplifiedClientAccessEnabled`

Note: SimplifiedClientAccessEnabled is configurable only via PowerShell and does not have a GUI-based configuration option in the Exchange Online admin center.

- [Office 365 Message Encryption Overview](https://learn.microsoft.com/en-us/microsoft-365/compliance/ome)
- [Set-IRMConfiguration](https://learn.microsoft.com/en-us/powershell/module/exchange/set-irmconfiguration)
<!--- Results --->
%TestResult%
