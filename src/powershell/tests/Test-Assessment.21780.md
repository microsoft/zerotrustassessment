Microsoft ended all support and security fixes for ADAL on June 30, 2023. Each ADAL token request represents a deliberate bypass of modern protections available only in MSAL-based implementations—such as continuous resilience improvements, modern protocol feature uptake, conditional access enforcement edge-cases coverage, and advanced token protection scenarios. Persisting ADAL traffic extends the attack surface: threat actors monitor for weaker legacy libraries, abuse older refresh patterns, and exploit dependency chains that still pull ADAL transitively. Maintaining any ADAL activity increases lateral movement opportunity because those apps frequently also call deprecated Azure AD Graph endpoints rather than Microsoft Graph, compounding technical debt and obscuring audit visibility. Continued reliance on ADAL delays adoption of hardened flows (like CAE, PoP tokens, and improved brokered authentication) and raises the probability that a future security advisory cannot be mitigated without emergency rewrites.

**Remediation action**

* [Migrate ADAL applications to MSAL](https://learn.microsoft.com/en-us/entra/identity-platform/msal-migration)

<!--- Results --->
%TestResult%
