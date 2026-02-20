When administrators use Microsoft Entra Private Access to reach domain controllers via Remote Desktop Protocol (RDP), they authenticate through Microsoft Entra ID before the Global Secure Access client tunnels their connection to the on-premises network. If this authentication step relies solely on password-based or standard multifactor authentication, threat actors can intercept credentials during phishing campaigns or adversary-in-the-middle attacks, replay stolen session tokens, and establish persistent RDP connections to domain controllers.

Once connected, the threat actor can execute DCSync attacks to harvest all password hashes in the domain, create golden tickets for indefinite domain persistence, modify Group Policy Objects to deploy ransomware or backdoors across all domain-joined machines, and extract DPAPI master keys that decrypt enterprise secrets. Domain controllers hold the cryptographic keys to the entire Active Directory forest; compromising one domain controller typically means compromising every identity and resource in the organization.

By requiring phishing-resistant authentication—FIDO2 security keys, Windows Hello for Business, or certificate-based multifactor authentication—organizations ensure that even if users are successfully phished, threat actors cannot replay credentials because these methods require cryptographic proof of possession that is bound to the legitimate sign-in session and cannot be intercepted or forwarded.

**Remediation action**

- [Create a Private Access application for domain controller RDP access with appropriate application segments](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-per-app-access)
- [Configure authentication strength policies to require phishing-resistant MFA](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)
- [Create a Conditional Access policy targeting Private Access applications with authentication strength grant control](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-grant#require-authentication-strength)
- [Deploy FIDO2 security keys or configure Windows Hello for Business for administrators](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-passwordless-security-key)
- [Configure certificate-based authentication for phishing-resistant access](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-certificate-based-authentication)

<!--- Results --->
%TestResult%
