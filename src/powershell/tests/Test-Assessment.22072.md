Allowing security questions as a self-service password reset (SSPR) method weakens the password reset process because answers are frequently guessable, reused across sites, or discoverable through open-source intelligence (OSINT). Threat actors enumerate or phish users, derive likely responses (family names, schools, and locations), and then trigger password reset flows to bypass stronger methods by exploiting the weaker knowledge-based gate. After they successfully reset a password on an account that isn't protected by multifactor authentication they can: gain valid primary credentials, establish session tokens, and laterally expand by registering more durable authentication methods, add forwarding rules, or exfiltrate sensitive data.

Eliminating this method removes a weak link in the password reset process. Some organizations might have specific business reasons for leaving security questions enabled, but this isn't recommended.

**Remediation action**

- [Disable security questions in SSPR policy](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-security-questions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Select authentication methods and registration options](https://learn.microsoft.com/entra/identity/authentication/tutorial-enable-sspr?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#select-authentication-methods-and-registration-options)
<!--- Results --->
%TestResult%

