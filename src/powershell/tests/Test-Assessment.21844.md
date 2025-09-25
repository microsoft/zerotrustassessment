
## Overview

Threat actors frequently target legacy management interfaces such as the Azure AD PowerShell module (AzureAD and AzureADPreview), which do not support modern authentication, Conditional Access enforcement, or advanced audit logging. Continued use of these modules exposes the environment to risks including weak authentication, bypass of security controls, and incomplete visibility into administrative actions. Attackers can exploit these weaknesses to gain unauthorized access, escalate privileges, and perform malicious changes without triggering modern security controls.

Legacy PowerShell modules lack support for modern authentication methods like multi-factor authentication (MFA) and certificate-based authentication, making them vulnerable to credential-based attacks. These modules also bypass Conditional Access policies, allowing attackers to circumvent location-based restrictions, device compliance requirements, and risk-based access controls. The limited audit logging capabilities of legacy modules provide attackers with the opportunity to perform administrative actions with reduced detection risk.

Blocking the Azure AD PowerShell module and enforcing the use of Microsoft Graph PowerShell or Microsoft Entra PowerShell ensures that only secure, supported, and auditable management channels are available, closing critical gaps in the attack chain.

**Remediation action**

- [Disable user sign-in for the Azure Active Directory PowerShell Enterprise Application](https://learn.microsoft.com/entra/identity/enterprise-apps/disable-user-sign-in-portal?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Action required: MSOnline and AzureAD PowerShell retirement - 2025 info and resources | Microsoft Community Hub](https://techcommunity.microsoft.com/blog/microsoft-entra-blog/action-required-msonline-and-azuread-powershell-retirement---2025-info-and-resou/4364991)

<!--- Results --->
%TestResult%
