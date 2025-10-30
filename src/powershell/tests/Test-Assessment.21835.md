Microsoft recommends that organizations have two cloud-only emergency access accounts permanently assigned the [Global Administrator](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#global-administrator) role. These accounts are highly privileged and aren't assigned to specific individuals. The accounts are limited to emergency or "break glass" scenarios where normal accounts can't be used or all other administrators are accidentally locked out.

Emergency access accounts should meet the following criteria:

- **Cloud-only accounts**: Not synchronized from on-premises Active Directory
- **Permanent Global Administrator assignment**: Not managed through Privileged Identity Management (PIM)
- **Phishing-resistant authentication**: Use only FIDO2 security keys and/or Certificate-Based Authentication (CBA)
- **Excluded from Conditional Access policies**: To ensure access during emergencies
- **Monitored for usage**: Alerts configured for any sign-in activity

**Remediation action**

- Create accounts following the [emergency access account recommendations](https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Ensure 2-4 emergency access accounts are configured to avoid tenant lockout while preventing excessive privileged access.
- Register FIDO2 security keys or configure Certificate-Based Authentication for these accounts.
- Exclude emergency access accounts from all Conditional Access policies.
- Configure monitoring and alerting for emergency account usage.

<!--- Results --->
%TestResult%
