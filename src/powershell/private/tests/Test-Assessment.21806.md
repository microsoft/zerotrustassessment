Without Conditional Access policies protecting security information registration, threat actors can exploit unprotected registration flows to compromise authentication methods. When users register multifactor authentication and self-service password reset methods without proper controls, threat actors can intercept these registration sessions through adversary-in-the-middle attacks or exploit unmanaged devices accessing registration from untrusted locations. Once threat actors gain access to an unprotected registration flow, they can register their own authentication methods, effectively hijacking the target's authentication profile. This enables them to maintain persistent access by controlling the victim's MFA methods, allowing them to bypass security controls and potentially escalate privileges throughout the environment. The compromised authentication methods then become the foundation for lateral movement as threat actors can authenticate as the legitimate user across multiple services and applications.

**Remediation action**

Create Conditional Access policy for security info registration
- [Protect security info registration with Conditional Access policy](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-security-info-registration)

Configure trusted network locations
- [What is the location condition in Microsoft Entra Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/concept-assignment-network)

Enable combined security information registration
- [Enable combined security information registration](https://learn.microsoft.com/entra/identity/authentication/howto-registration-mfa-sspr-combined)
<!--- Results --->
%TestResult%
