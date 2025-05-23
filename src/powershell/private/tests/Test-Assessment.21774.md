When Microsoft services applications (service principals with the owner organization ID "f8cdef31-a31e-4b4a-93e4-5f571e91255a") have credentials configured in your tenant, it might create potential attack vectors that threat actors can exploit. If credentials were added by administrator and no longer needed, they become a major target of attackers; similarly, credentials can be added maliciously by threat actors. In either case, threat actors can use these credentials to authenticate as the service principal, gaining the same permissions and access rights as the Microsoft service application. This initial access can lead to privilege escalation if the application has high-level permissions, allowing lateral movement across the tenant. Attackers can then proceed to data exfiltration or persistence establishment through creating additional backdoor credentials. Since these are Microsoft-owned applications, credential configuration should typically be managed by Microsoft itself rather than your organization, making any tenant-configured credentials suspicious and potentially indicative of malicious activity. While Microsoft has safeguards in place to prevent adding credentials to Microsoft Services applications, finding credentials for Microsoft-owned service principals in your tenant might be an indicator that a threat actor attempted or is currently attempting attacks.

**Remediation action**

Remove credentials from Microsoft service applications to reduce security risk.
 
<!--- Results --->
%TestResult%
