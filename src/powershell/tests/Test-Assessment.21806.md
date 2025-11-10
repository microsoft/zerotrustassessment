Without Conditional Access policies protecting security information registration, threat actors can exploit unprotected registration flows to compromise authentication methods. When users register multifactor authentication and self-service password reset methods without proper controls, threat actors can intercept these registration sessions through adversary-in-the-middle attacks or exploit unmanaged devices accessing registration from untrusted locations. Once threat actors gain access to an unprotected registration flow, they can register their own authentication methods, effectively hijacking the target's authentication profile. The threat actors can bypass security controls and potentially escalate privileges throughout the environment because they can maintain persistent access by controlling the MFA methods. The compromised authentication methods then become the foundation for lateral movement as threat actors can authenticate as the legitimate user across multiple services and applications.

**Remediation action**

- [Deploy a Conditional Access policy for security info registration](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-security-info-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Configure known network locations](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Enable combined security info registration](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-registration-mfa-sspr-combined?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

