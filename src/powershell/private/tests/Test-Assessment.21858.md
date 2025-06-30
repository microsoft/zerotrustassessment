When guest identities remain active but unused for extended periods, threat actors can exploit these dormant accounts as entry vectors into the organization. Inactive guest accounts represent a significant attack surface because they often maintain persistent access permissions to resources, applications, and data while remaining unmonitored by security teams. Threat actors frequently target these accounts through credential stuffing, password spraying, or by compromising the guest's home organization to gain lateral access. Once an inactive guest account is compromised, attackers can utilize existing access grants to move laterally within the tenant, escalate privileges through group memberships or application permissions, and establish persistence through techniques like creating additional service principals or modifying existing permissions. The prolonged dormancy of these accounts provides attackers with extended dwell time to conduct reconnaissance, exfiltrate sensitive data, and establish backdoors without detection, as organizations typically focus monitoring efforts on active internal users rather than external guest accounts.

**Remediation action**

Monitor and clean up stale guest accounts as documented here :
- [Monitor and clean up stale guest accounts using access reviews](https://learn.microsoft.com/entra/identity/users/clean-up-stale-guest-accounts)
<!--- Results --->
%TestResult%
