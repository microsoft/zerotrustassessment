Microsoft ended support and security fixes for ADAL on June 30, 2023. Continued ADAL usage bypasses modern security protections available only in MSAL, including Conditional Access enforcement, Continuous Access Evaluation (CAE), and advanced token protection. ADAL applications create security vulnerabilities by using weaker legacy authentication patterns, often calling deprecated Azure AD Graph endpoints, and preventing adoption of hardened authentication flows that could mitigate future security advisories. 

**Remediation action**

- [Migrate applications to the Microsoft Authentication Library (MSAL)](https://learn.microsoft.com/entra/identity-platform/msal-migration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

