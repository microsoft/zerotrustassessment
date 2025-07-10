Microsoft Entra seamless single sign-on (Seamless SSO) is a legacy authentication feature designed to provide passwordless access for domain-joined devices that are not hybrid Microsoft Entra ID joined. Seamless SSO relies on Kerberos authentication and is primarily beneficial for older operating systems like Windows 7 and Windows 8.1, which do not support Primary Refresh Tokens (PRT). If these legacy systems are no longer present in the environment, continuing to use Seamless SSO introduces unnecessary complexity and potential security exposure. Threat actors could exploit misconfigured or stale Kerberos tickets, or compromise the `AZUREADSSOACC` computer account in Active Directory, which holds the Kerberos decryption key used by Microsoft Entra ID. Once compromised, attackers could impersonate users, bypass modern authentication controls, and gain unauthorized access to cloud resources. Disabling Seamless SSO in environments where it is no longer needed reduces the attack surface and enforces the use of modern, token-based authentication mechanisms that offer stronger protections. 

**Remediation action**

- [Review how Seamless SSO works](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sso-how-it-works?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Disable Seamless SSO](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sso-faq?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-can-i-disable-seamless-sso-)
- [Clean up stale devices in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/devices/manage-stale-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

