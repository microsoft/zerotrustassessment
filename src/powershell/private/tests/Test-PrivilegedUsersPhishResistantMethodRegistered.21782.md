Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks, where attackers might trick users into revealing their credentials and gain unauthorized access. If non-phishing-resistant authentication methods are used, attackers might intercept MFA tokens or codes, especially through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.

Once a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, by creating other backdoors or modifying user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.

#### Remediation

- Disable privileged Service Principals  
  - [Update serviceprincipal - Microsoft Graph v1.0](https://learn.microsoft.com/graph/api/serviceprincipal-update?view=graph-rest-1.0&tabs=http)
- Investigate if the application has legitimate use cases. If so, analyze if a OAuth2 permission is a better fit.
- If service principal does not have legitimate usage, delete it
  - [Delete servicePrincipal - Microsoft Graph v1.0](https://learn.microsoft.com/graph/api/serviceprincipal-delete?view=graph-rest-1.0&tabs=http)

<!--- Results --->
%TestResult%
