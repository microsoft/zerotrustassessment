When privileged users are allowed to maintain long-lived sign-in sessions without periodic reauthentication, threat actors can gain extended windows of opportunity to exploit compromised credentials or hijack active sessions. Once a privileged account is compromised through techniques like credential theft, phishing, or session fixation, extended session timeouts allow threat actors to maintain persistence within the environment for prolonged periods. With long-lived sessions, threat actors can perform lateral movement across systems, escalate privileges further, and access sensitive resources without triggering another authentication challenge. The extended session duration also increases the window for session hijacking attacks, where threat actors can steal session tokens and impersonate the privileged user. Once a threat actor is established in a privileged session, they can:

- Create backdoor accounts
- Modify security policies
- Access sensitive data
- Establish more persistence mechanisms

The lack of periodic reauthentication requirements means that even if the original compromise is detected, the threat actor might continue operating undetected using the hijacked privileged session until the session naturally expires or the user manually signs out.

**Remediation action**

- [Learn about Conditional Access adaptive session lifetime policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-session-lifetime?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Configure sign-in frequency for privileged users with Conditional Access policies ](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-session-lifetime?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

