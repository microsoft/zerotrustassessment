Without proper lifecycle management controls on access packages that apply to guest users, external users can maintain indefinite access to organizational resources, creating significant security exposure. Threat actors who compromise guest accounts or obtain unauthorized access through identity spoofing can persist in the environment undetected for extended periods. This unchecked access enables threat actors to perform lateral movement within the tenant, escalating their privileges through the accumulated permissions granted via the access package. Over time, stale guest accounts with persistent access become attractive targets for account takeover attacks, where threat actors can leverage these dormant but active accounts to establish persistence and avoid detection. The lack of periodic validation through access reviews or automatic expiration also prevents organizations from identifying when business relationships change or when guest users no longer require access, allowing unauthorized data exfiltration or resource abuse to continue unmonitored.

**Remediation action**
- [Configure lifecycle settings](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-access-package-lifecycle-policy)
- [Configure access reviews](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-access-reviews-create)

<!--- Results --->
%TestResult%
