Unmaintained or orphaned redirect URIs in Microsoft Entra ID app registrations introduce a significant security vulnerability. When a redirect URI references a domain or subdomain that no longer points to an active resource—commonly referred to as a "dangling" DNS entry—threat actors can exploit this by provisioning a resource at that domain, effectively taking control of the subdomain. This allows them to intercept authentication tokens and user credentials during the OAuth 2.0 authorization process. The attack sequence typically involves the threat actor identifying a dangling redirect URI, registering a service (e.g., an Azure App Service) at that domain, and then capturing tokens or credentials redirected to their controlled endpoint. Such exploitation can lead to unauthorized access to sensitive resources, session hijacking, and the potential for broader compromise within the organization's environment. To mitigate this risk, regularly audit and remove unused or obsolete redirect URIs from app registrations and ensure that all active redirect URIs point to valid, controlled domains. 

**Remediation action**

- [Redirect URI (reply URL) best practices and limitations](https://learn.microsoft.com/en-us/entra/identity-platform/reply-url)

<!--- Results --->
%TestResult%
