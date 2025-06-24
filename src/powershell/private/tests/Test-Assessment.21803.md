Legacy multifactor authentication (MFA) and self-service password reset (SSPR) policies in Microsoft Entra ID manage authentication methods separately, leading to fragmented configurations and suboptimal user experience. Moreover, managing these policies independently increases administrative overhead and the risk of misconfiguration.  

Migrating to the combined Authentication Methods policy consolidates the management of MFA, SSPR, and passwordless authentication methods into a single policy framework. This unification allows for more granular control, enabling administrators to target specific authentication methods to user groups and enforce consistent security measures across the organization. Additionally, the unified policy supports modern authentication methods, such as FIDO2 security keys and Windows Hello for Business, enhancing the organization's security posture.

Microsoft announced the deprecation of legacy MFA and SSPR policies, with a retirement date set for September 30, 2025. Organizations are advised to complete the migration to the Authentication Methods policy before this date to avoid potential disruptions and to benefit from the enhanced security and management capabilities of the unified policy.

**Remediation action**

- [Enable combined security information registration](https://learn.microsoft.com/entra/identity/authentication/howto-registration-mfa-sspr-combined?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [How to migrate MFA and SSPR policy settings to the Authentication methods policy for Microsoft Entra ID](https://learn.microsoft.com/entra/identity/authentication/how-to-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

