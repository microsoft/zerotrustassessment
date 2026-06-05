Organizations with extensive user-facing password surfaces expose multiple entry points for credential-based attacks. Threat actors often begin with credential stuffing using compromised credentials from data breaches, followed by password spraying to test common passwords across multiple accounts. Once initial access is gained, they conduct credential discovery by examining browser password stores, cached credentials in memory, and credential managers to harvest additional authentication materials. These stolen credentials enable lateral movement to more systems and applications, often escalating privileges by targeting administrative accounts that still rely on password authentication.

Without passwordless methods like Windows Hello for Business, FIDO2 security keys, and Microsoft Authenticator deployed broadly, every password prompt is an opportunity for interception and exploitation. Reducing the password surface area limits these attack vectors and reduces the overall exposure to credential-based threats.

**Remediation action**

- [Plan a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- [Enable passkeys (FIDO2)](https://learn.microsoft.com/entra/identity/authentication/how-to-enable-passkey-fido2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- [Configure Windows Hello for Business](https://learn.microsoft.com/windows/security/identity-protection/hello-for-business/?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

