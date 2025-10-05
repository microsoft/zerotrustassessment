When Microsoft Entra Connect Sync uses a user account instead of a service principal to connect to the cloud, threat actors who compromise the connector user accounts can maintain persistent access to identity synchronization infrastructure. Legacy service account authentication relies on username and a randomly generated password that can be more compromised through credential theft, or password attacks. Once compromised, threat actors can exploit these accounts to manipulate identity synchronization processes, potentially creating backdoor accounts, escalating privileges, or disrupting the entire hybrid identity infrastructure. Service principal authentication with certificate-based credentials provides stronger authentication mechanisms, making it significantly harder for threat actors to establish persistence in the identity infrastructure.

**Remediation action**

Configure application identity for Entra Connect:
- [Microsoft Entra Connect: Accounts and permissions](https://learn.microsoft.com/entra/identity/hybrid/connect/reference-connect-accounts-permissions)

Remove legacy Directory Synchronization Accounts:
- [Directory Synchronization Accounts](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference#directory-synchronization-accounts)

<!--- Results --->
%TestResult%

 
 
