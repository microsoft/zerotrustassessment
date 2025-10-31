Threat actors frequently target legacy management interfaces such as the Azure AD PowerShell module (AzureAD and AzureADPreview), which don't support modern authentication, Conditional Access enforcement, or advanced audit logging. Continued use of these modules exposes the environment to risks including weak authentication, bypass of security controls, and incomplete visibility into administrative actions. Attackers can exploit these weaknesses to gain unauthorized access, escalate privileges, and perform malicious changes. 

Block the Azure AD PowerShell module and enforce the use of Microsoft Graph PowerShell or Microsoft Entra PowerShell to ensure that only secure, supported, and auditable management channels are available, which closes critical gaps in the attack chain. 

**Remediation action**

- [Disable user sign-in for application](https://learn.microsoft.com/entra/identity/enterprise-apps/disable-user-sign-in-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

