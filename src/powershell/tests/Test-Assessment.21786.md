A threat actor can intercept or extract authentication tokens from memory, local storage on a legitimate device, or by inspecting network traffic. The attacker might replay those tokens to bypass authentication controls on users and devices, get unauthorized access to sensitive data, or run further attacks. Because these tokens are valid and time bound, traditional anomaly detection often fails to flag the activity, which might allow sustained access until the token expires or is revoked.

Token protection, also called token binding, helps prevent token theft by making sure a token is usable only from the intended device. Token protection uses cryptography so that without the client device key, no one can use the token.

**Remediation action**

- [Deploy a Conditional Access policy to require token protection](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

