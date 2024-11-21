Applications that use client secrets might store them in configuration files, hardcode them in scripts, or risk their exposure in other ways. Secret management complexities make secrets susceptible to leaks and attractive to attackers. Client secrets, when exposed, provide attackers with legitimate credentials to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s client secret, they can escalate their privileges within the system, leading to broader access and control, depending on the permissions of the application. 

**Remediation action**

- Move applications away from secrets to use managed identities, app secrets, or federated identities. https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/how-to-assign-app-role-managed-identity 
- For applications that cannot be migrated in the short term, rotate the secret and ensure they use secure practices such as using Azure Key Vault. https://learn.microsoft.com/azure/key-vault/general/developers-guide 
- Deploy Conditional Access policies for workload identities based on application risk: https://learn.microsoft.com/entra/identity/conditional-access/workload-identity 
- Implement credential scanning and similar tools to detect future mishandling of secrets.   
- Deploy Microsoft Entra application authentication policies (require additional licensing) - https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy 
- Ensure you have a process to triage and monitor applications. 
- Use federated identity for service accounts (Github Actions and Kubernetes Clusters, or any entity that can sign a JWT) - https://learn.microsoft.com/graph/api/resources/federatedidentitycredentials-overview 
- Create a least-privileged custom role to rotate application credentials: https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create 
<!--- Results --->
%TestResult%


