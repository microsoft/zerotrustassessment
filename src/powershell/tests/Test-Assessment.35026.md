Office 365 Message Encryption (OME) provides user-friendly encryption and access controls for emails sent both inside and outside the organization. The SimplifiedClientAccessEnabled setting controls whether external recipients of encrypted emails must use a web-based portal to access protected messages, or whether they can use native email clients (Outlook, Gmail, etc.) with simpler authentication flows. When SimplifiedClientAccessEnabled is enabled (set to true), external recipients experience streamlined access with browser-based reading and minimal authentication friction, improving user experience and increasing adoption of encryption protections. When disabled (set to false), external recipients must use the OME portal exclusively, which creates additional friction and reduces user willingness to send encrypted emails. Enabling SimplifiedClientAccessEnabled balances security with usability by allowing external recipients flexible access options while maintaining encryption protections on email content.

**Remediation action**

To enable SimplifiedClientAccessEnabled for OME:

1. Connect to Exchange Online: `Connect-ExchangeOnline`
2. Retrieve current IRM configuration: `Get-IRMConfiguration`
3. If SimplifiedClientAccessEnabled is false, enable it: `Set-IRMConfiguration -SimplifiedClientAccessEnabled $true`
4. Verify the change: `Get-IRMConfiguration | Select-Object -Property SimplifiedClientAccessEnabled`

Alternatively, enable via Exchange Online admin center:
1. Navigate to [Exchange Online admin center](https://admin.exchange.microsoft.com)
2. Go to Mail flow > Rules
3. Find OME encryption rules and verify they are configured
4. Note: Some OME settings may only be configurable via PowerShell

- [Manage Office 365 Message Encryption](https://learn.microsoft.com/en-us/purview/ome-advanced-features)
- [Office 365 Message Encryption FAQ](https://learn.microsoft.com/en-us/exchange/security-and-compliance/message-encryption-faq)
<!--- Results --->
%TestResult%
