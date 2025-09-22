When on-premises password protection isn’t enabled or enforced, threat actors can use low-and-slow password spray with common variants (season+year+symbol, local terms) to gain initial access to AD DS accounts. Domain Controllers (DC) without the agent, or with the tenant setting disabled or in audit-only mode, accept weak passwords; when no policy is cached, the agent accepts all passwords and logs this condition. With valid on-prem credentials, attackers laterally move by reusing passwords across endpoints, escalate to domain admin through local admin reuse or service accounts, and persist by adding backdoors, while weak or disabled enforcement produces fewer blocking events and predictable signals. Microsoft’s design requires a proxy that brokers policy from Entra ID and a DC agent that enforces the combined global and tenant custom banned lists on password change/reset; consistent enforcement requires DC agent coverage on all DCs in a domain and using Enforced mode after audit evaluation.  

**Remediation action**

* [Deploy on-premises Microsoft Entra Password Protection - Microsoft Entra ID](https://learn.microsoft.com/entra/identity/authentication/howto-password-ban-bad-on-premises-deploy)

<!--- Results --->
%TestResult%
