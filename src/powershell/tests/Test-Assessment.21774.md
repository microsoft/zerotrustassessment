Microsoft services applications that operate in your tenant are identified as service principals with the owner organization ID "f8cdef31-a31e-4b4a-93e4-5f571e91255a." When these service principals have credentials configured in your tenant, they might create potential attack vectors that threat actors can exploit. If an administrator added the credentials and they're no longer needed, they can become a target for attackers. Although less likely when proper preventive and detective controls are in place on privileged activities, threat actors can also maliciously add credentials. In either case, threat actors can use these credentials to authenticate as the service principal, gaining the same permissions and access rights as the Microsoft service application. This initial access can lead to privilege escalation if the application has high-level permissions, allowing lateral movement across the tenant. Attackers can then proceed to data exfiltration or persistence establishment through creating other backdoor credentials.

When credentials (like client secrets or certificates) are configured for these service principals in your tenant, it means someone - either an administrator or a malicious actor - enabled them to authenticate independently within your environment. These credentials should be investigated to determine their legitimacy and necessity. If they're no longer needed, they should be removed to reduce the risk. 

If this check doesn't pass, the recommendation is to "investigate" because you need to identify and review any applications with unused credentials configured.

**Remediation action**

- Confirm if the credentials added are still valid use cases. If not, remove credentials from Microsoft service applications to reduce security risk. 
    - In the Microsoft Entra admin center, browse to **Entra ID** > **App registrations** and select the affected application.
    - Go to the **Certificates & secrets** section and remove any credentials that are no longer needed.<!--- Results --->
%TestResult%

