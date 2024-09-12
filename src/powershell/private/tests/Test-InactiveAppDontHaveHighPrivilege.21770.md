 Attackers might exploit valid but dormant applications that still have high privileges. These applications can be used to gain initial access without raising alarm because they're legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the dormant application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.

#### Remediation

- Disable privileged Service Principals  
  - [Update serviceprincipal - Microsoft Graph v1.0](https://learn.microsoft.com/graph/api/serviceprincipal-update?view=graph-rest-1.0&tabs=http)
- Investigate if the application has legitimate use cases
- If service principal does not have  legitimate usage, delete it
  - [Delete servicePrincipal - Microsoft Graph v1.0](https://learn.microsoft.com/graph/api/serviceprincipal-delete?view=graph-rest-1.0&tabs=http)

<!--- Results --->
%TestResult%
