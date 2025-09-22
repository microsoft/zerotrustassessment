Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.

Attackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.

**Remediation action**

- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Deploy a Conditional Access policy to require phishing-resistant MFA for all users](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)
<!--- Results --->
%TestResult%

