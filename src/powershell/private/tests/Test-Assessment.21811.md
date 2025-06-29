When password expiration policies remain enabled, threat actors can exploit the predictable password rotation patterns that users typically follow when forced to change passwords regularly. Users frequently create weaker passwords by making minimal modifications to existing ones, such as incrementing numbers or adding sequential characters, which threat actors can easily anticipate and exploit through credential stuffing attacks or targeted password spraying campaigns. These predictable patterns enable threat actors to establish persistence through compromised credentials, escalate privileges by targeting administrative accounts with weak rotated passwords, and maintain long-term access by predicting future password variations. Research shows that forced password expiration leads users to create weaker, more predictable passwords that are easier for experienced attackers to crack, as they often make simple modifications to existing passwords rather than creating entirely new, strong passwords. Additionally, when users are required to frequently change passwords, they may resort to insecure practices such as writing passwords down or storing them in easily accessible locations, creating additional attack vectors for threat actors to exploit during physical reconnaissance or social engineering campaigns.

**Remediation action**

Disable password expiration at the domain level through Microsoft 365 admin center: Settings > Org Settings > Security & Privacy > Password expiration policy:
- [Set the password expiration policy for your organization](https://learn.microsoft.com/microsoft-365/admin/manage/set-password-expiration-policy?view=o365-worldwide)

Or, use Microsoft Graph:
- [Update domain](https://learn.microsoft.com/graph/api/domain-update?view=graph-rest-1.0&tabs=http)

Set individual user passwords to never expire using Microsoft Graph PowerShell: Update-MgUser -UserId <UserID> -PasswordPolicies DisablePasswordExpiration
- [Set an individual user's password to never expire](https://learn.microsoft.com/microsoft-365/admin/add-users/set-password-to-never-expire?view=o365-worldwide)
<!--- Results --->
%TestResult%
