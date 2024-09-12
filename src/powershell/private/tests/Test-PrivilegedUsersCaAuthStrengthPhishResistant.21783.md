Without phishing-resistant methods, privileged user credentials are more vulnerable to phishing attacks, where attackers can trick users into revealing their credentials, gaining unauthorized access. If non-phishing-resistant multi-factor authentication (MFA) is used, attackers may intercept MFA tokens or codes, especially through methods like adversary-in-the-middle attacks, undermining the security of the privileged account. 

Once a privileged account or session is compromised due to weak authentication, attackers can manipulate the account to maintain long-term access, such as by creating additional backdoors or modifying user permissions. Attackers can also leverage the compromised privileged account to escalate their access even further, potentially gaining control over more.

#### Remediation action

- Enforce usage of phishing resistant authentication methods with conditional access policies.
- [Require phishing-resistant multifactor authentication for Microsoft Entra administrator roles](https://learn.microsoft.com/en-us/entra/identity/conditional-access/how-to-policy-phish-resistant-admin-mfa)

#### Related links

* [Conditional Access authentication strength](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths)
* [Common Conditional Access policy: Require phishing-resistant multifactor authentication for administrators](https://learn.microsoft.com/entra/identity/conditional-access/how-to-policy-phish-resistant-admin-mfa)

<!--- Results --->
%TestResult%
