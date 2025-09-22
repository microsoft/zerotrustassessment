When on-premises password protection isn’t enabled or enforced, threat actors can use low-and-slow password spray with common variants, such as season+year+symbol or local terms, to gain initial access to Active Directory Domain Services accounts. Domain Controllers (DCs) can accept weak passwords when either of the following statements are true:

- Microsoft Entra Password Protection DC agent isn't installed
- The password protection tenant setting is disabled or in audit-only mode

With valid on-premises credentials, attackers laterally move by reusing passwords across endpoints, escalate to domain admin through local admin reuse or service accounts, and persist by adding backdoors, while weak or disabled enforcement produces fewer blocking events and predictable signals. Microsoft’s design requires a proxy that brokers policy from Microsoft Entra ID and a DC agent that enforces the combined global and tenant custom banned lists on password change/reset; consistent enforcement requires DC agent coverage on all DCs in a domain and using Enforced mode after audit evaluation.

**Remediation action**

- [Deploy Microsoft Entra password protection](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-password-ban-bad-on-premises-deploy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

