When workload identities operate without network-based conditional access restrictions, threat actors can compromise service principal credentials through various methods such as exposed secrets in code repositories or intercepted authentication tokens, then use these credentials from any location globally. This unrestricted access enables threat actors to perform reconnaissance activities, enumerate resources, and map the tenant's infrastructure while appearing legitimate. Once established within the environment, they can move laterally between services, access sensitive data stores, and potentially escalate privileges by exploiting overly permissive service-to-service permissions. The lack of network restrictions makes it impossible to detect anomalous access patterns based on location, allowing threat actors to maintain persistent access and exfiltrate data over extended periods without triggering security alerts that would normally flag connections from unexpected networks or geographic locations.

**Remediation action**

- [Configure Conditional Access for workload identities](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity)
- [Create named locations](https://learn.microsoft.com/en-us/entra/identity/conditional-access/location-condition)
- [Follow Best practices for securing workload identities](https://learn.microsoft.com/en-us/entra/identity-platform/workload-identities-overview)

<!--- Results --->
%TestResult%
