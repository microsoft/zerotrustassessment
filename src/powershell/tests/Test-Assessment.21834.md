Directory synchronization accounts are highly privileged service accounts that facilitate identity synchronization between on-premises Active Directory and Microsoft Entra ID. Without location-based access controls, threat actors who compromise these accounts can synchronize malicious changes from any location, including unauthorized networks or geographic regions.

Once a directory sync account is compromised, threat actors can:
- Manipulate identity synchronization processes
- Create unauthorized user accounts
- Escalate privileges of existing accounts
- Persist access by modifying synchronization rules

Unrestricted network access allows threat actors to operate remotely from compromised infrastructure, making detection harder while maintaining long-term access to the hybrid identity environment. Restricting these accounts to trusted named locations through Conditional Access policies limits the attack surface by ensuring synchronization operations only occur from authorized network locations.

**Remediation action**

- [Block access by location with Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-by-location?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

