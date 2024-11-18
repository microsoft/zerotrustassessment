Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks, where attackers might trick users into revealing their credentials and gain unauthorized access. If non-phishing-resistant authentication methods are used, attackers might intercept MFA tokens or codes, especially through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.

Once a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, by creating other backdoors or modifying user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.

**Remediation action**

- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication)
- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths#authentication-strengths)
- [Deploy Conditional Access policy to target privileged accounts to require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa)
- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report#authentication-methods-activity)
<!--- Results --->
%TestResult%

