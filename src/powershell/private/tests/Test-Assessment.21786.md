A threat actor can intercept or extract authentication tokens from memory, local storage on a legitimate device, or through inspection of network traffic. They may attempt to replay those tokens to bypass the authentication controls on user and devices and gain unauthorized access to sensitive data or execute further attacks. Since these tokens are valid and time-bound, traditional anomaly detection might not flag the activity and allow sustained access until the token expires or is revoked.

Token protection, also known as token binding, helps to mitigate token theft by ensuring a token is usable only from the intended device. Token protection uses cryptography to ensure that without the client device key, the token cannot be used.

**Remediation action**

Implement Token Protection using Conditional Access policies following the best practices here:
- [Microsoft Entra Conditional Access: Token protection](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection)
<!--- Results --->
%TestResult%
