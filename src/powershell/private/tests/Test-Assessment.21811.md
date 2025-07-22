When password expiration policies remain enabled, threat actors can exploit the predictable password rotation patterns that users typically follow when forced to change passwords regularly. Users frequently create weaker passwords by making minimal modifications to existing ones, such as incrementing numbers or adding sequential characters. Threat actors can easily anticipate and exploit these types of changes through credential stuffing attacks or targeted password spraying campaigns. These predictable patterns enable threat actors to establish persistence through:

- Compromised credentials
- Escalated privileges by targeting administrative accounts with weak rotated passwords
- Maintaining long-term access by predicting future password variations

Research shows that users create weaker, more predictable passwords when they are forced to expire. These predictable passwords are easier for experienced attackers to crack, as they often make simple modifications to existing passwords rather than creating entirely new, strong passwords. Additionally, when users are required to frequently change passwords, they might resort to insecure practices such as writing down passwords or storing them in easily accessible locations, creating more attack vectors for threat actors to exploit during physical reconnaissance or social engineering campaigns. 

**Remediation action**

- [Set the password expiration policy for your organization](https://learn.microsoft.com/microsoft-365/admin/manage/set-password-expiration-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
    - Sign in to the [Microsoft 365 admin center](https://admin.microsoft.com/). Go to **Settings** > **Org Settings** >** Security & Privacy** > **Password expiration policy**. Ensure the **Set passwords to never expire** setting is checked.
- [Disable password expiration using Microsoft Graph](https://learn.microsoft.com/graph/api/domain-update?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- [Set individual user passwords to never expire using Microsoft Graph PowerShell](https://learn.microsoft.com/microsoft-365/admin/add-users/set-password-to-never-expire?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
    - `Update-MgUser -UserId <UserID> -PasswordPolicies DisablePasswordExpiration`<!--- Results --->
%TestResult%

