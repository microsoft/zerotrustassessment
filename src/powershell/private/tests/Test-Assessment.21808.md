The OAuth device code flow is used when signing into devices that might lack local input devices like shared devices. This flow introduces a risk where threat actors can intercept or manipulate the authentication process to gain unauthorized access from unmanaged devices. Once authenticated, attackers inherit the permissions of the compromised account, allowing them to exfiltrate data, or move laterally.

**Remediation action**

- Implement the recommended conditional access policy per [Block authentication flows with Conditional Access policy - Microsoft Entra ID | Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-block-authentication-flows)

<!--- Results --->
%TestResult%
