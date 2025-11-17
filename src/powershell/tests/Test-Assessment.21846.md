When Temporary Access Pass (TAP) is configured to allow multiple uses, threat actors who compromise the credential can reuse it repeatedly during its validity period, extending their unauthorized access window beyond the intended single bootstrapping event. This situation creates an extended opportunity for threat actors to establish persistence by registering additional strong authentication methods under the compromised account during the credential lifetime. A reusable TAP that falls into the wrong hands lets threat actors conduct reconnaissance activities across multiple sessions, gradually mapping the environment and identifying high-value targets while maintaining legitimate-looking access patterns. The compromised TAP can also serve as a reliable backdoor mechanism, allowing threat actors to maintain access even if other compromised credentials are detected and revoked, since the TAP appears as a legitimate administrative tool in security logs.

**Remediation action**

- [Configure Temporary Access Pass for one-time use in authentication methods policy](https://learn.microsoft.com/entra/identity/authentication/howto-authentication-temporary-access-pass?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-the-temporary-access-pass-policy) 
<!--- Results --->
%TestResult%

