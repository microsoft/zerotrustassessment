Without restricted user consent settings, threat actors can exploit permissive application consent configurations to gain unauthorized access to sensitive organizational data. When user consent is unrestricted, attackers can:

- Use social engineering and illicit consent grant attacks to trick users into approving malicious applications.
- Impersonate legitimate services to request broad permissions, such as access to email, files, calendars, and other critical business data.
- Obtain legitimate OAuth tokens that bypass perimeter security controls, making access appear normal to security monitoring systems.
- Establish persistent access to organizational resources, conduct reconnaissance across Microsoft 365 services, move laterally through connected systems, and potentially escalate privileges.

Unrestricted user consent also limits an organization's ability to enforce centralized governance over application access, making it difficult to maintain visibility into which non-Microsoft applications have access to sensitive data. This gap creates compliance risks where unauthorized applications might violate data protection regulations or organizational security policies.

**Remediation action**

-  [Configure restricted user consent settings](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-user-consent?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to prevent illicit consent grants by disabling user consent or limiting it to verified publishers with low-risk permissions only.<!--- Results --->
%TestResult%

