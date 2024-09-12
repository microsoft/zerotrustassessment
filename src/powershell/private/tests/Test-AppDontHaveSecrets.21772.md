Applications using client secrets can be stored in configuration files, hardcoded in scripts or otherwise exposed, making them susceptible to leaks and attractive to attackers.  Client secrets, when exposed, provide attackers with legitimate credentials to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s client secret, they can escalate their privileges within the system, leading to broader access and control, depending on the permissions of the application. 

#### Remediation

- Move applications away from secrets to use Managed Identities, App Secrets, or federated identities.
- For applications that cannot be migrated in the short term, rotate the secret and ensure they use secure practices such as usage of Keyvault.  
- Deploy conditional access policies for workload identities based on Application risk: [Microsoft Entra Conditional Access for workload identities](https://learn.microsoft.com/entra/identity/conditional-access/workload-identity)
- Implement CredScan and similar tools to detect future mishandling of secrets.
- [Deploy Entra Application Authentication Policies (require additional licensing)](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy)
- Start triaging and monitoring working
- [Use federated identity for service accounts (Github Actions and Kubernetes Clusters, or any entity that can sign a JWT)](https://learn.microsoft.com/graph/api/resources/federatedidentitycredentials-overview?view=graph-rest-1.0)
- [Create a the least-privileged custom role to rotate application credentials](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/custom-create)

<!--- Results --->
%TestResult%
