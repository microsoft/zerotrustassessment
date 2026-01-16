When Private Access applications are not protected by Conditional Access policies requiring strong authentication, organizations undermine the security benefits of their Zero Trust Network Access implementation.  

Threat actors who obtain user credentials through phishing attacks, credential stuffing, or password spraying can authenticate to private applications using only a compromised password, gaining initial access to internal resources that should be protected by stronger controls. Once authenticated, threat actors can establish persistence by accessing sensitive internal systems, downloading data, or creating additional access mechanisms. The absence of multifactor authentication—or worse, the use of phishable MFA methods such as SMS or voice—enables adversary-in-the-middle attacks where threat actors intercept authentication tokens and session cookies, facilitating credential access to additional systems.  

Threat actors can then perform lateral movement by pivoting from the initially compromised private application to other internal resources accessible through the Private Access infrastructure.  

Microsoft recommends enforcing phishing-resistant authentication methods such as FIDO2 security keys, Windows Hello for Business, or certificate-based authentication for access to private applications, with multifactor authentication as the minimum acceptable baseline. The authentication strength feature in Conditional Access allows organizations to require specific combinations of authentication methods, enabling granular enforcement aligned with the Microsoft passwordless strategy. 

**Remediation action**

- [Apply Conditional Access policies to Private Access applications requiring MFA or authentication strength from within Global Secure Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-target-resource-private-access-apps)

- [Configure authentication strength policies to require phishing-resistant methods for high-value private applications](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)

- [Deploy phishing-resistant authentication methods including FIDO2 security keys, Windows Hello for Business, or certificate-based authentication](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication)
<!--- Results --->
%TestResult%
