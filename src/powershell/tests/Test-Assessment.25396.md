When Conditional Access policies don't protect Private Access applications by requiring strong authentication, threat actors can use phishing attacks, credential stuffing, or password spraying to get user credentials and sign in to private applications with just a compromised password.

Without strong authentication:

- Threat actors gain initial access to internal resources that should be protected by stronger controls.
- If multifactor authentication is missing or phishable methods like SMS or voice are used, adversary-in-the-middle attacks can happen where threat actors intercept authentication tokens and session cookies.
- Threat actors can move laterally from the initially compromised private application to other internal resources.

Microsoft recommends enforcing phishing-resistant authentication methods such as FIDO2 security keys, Windows Hello for Business, or certificate-based authentication for access to private applications, with multifactor authentication as the minimum acceptable baseline.

**Remediation action**

- [Configure Conditional Access policies to require phishing-resistant authentication](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

