Attackers might exploit valid but inactive applications that still have high privileges. These applications can be used to gain initial access without raising alarm because they're legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.

**Remediation action**

- [Disable inactive privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update)
- Investigate if the application has legitimate use cases. If so, [analyze if a OAuth2 permission is a better fit](https://learn.microsoft.com/entra/identity-platform/v2-app-types)
- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete)
<!--- Results --->
%TestResult%


