Initial sign-in multifactor authentication is no longer sufficient against adversary-in-the-middle phishing kits and token theft, which let a threat actor replay an authenticated cloud app session hours or days later without ever facing another prompt. Closing that gap takes two products: Microsoft Defender for Cloud Apps routes sensitive sessions through Conditional Access App Control and applies a session policy that recognizes a risky in-session action, and Microsoft Entra Conditional Access enforces the resulting step-up challenge with a risk condition plus a phishing-resistant authentication strength such as passkey, FIDO2, or Windows Hello for Business. This check verifies the Entra enforcement leg: that at least one enabled Conditional Access policy combines an identity risk condition with an authentication strength grant control. The Defender for Cloud Apps session policy that triggers the challenge is configured in the Defender portal and is not exposed through Microsoft Graph, so confirm it manually.

**Remediation action**

- [Common Conditional Access policy: Sign-in risk-based multifactor authentication](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-risk-based-sign-in)
- [Configure and enable risk policies](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies)
- [Conditional Access authentication strength](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths)
- [Risk-based access policies](https://learn.microsoft.com/en-us/entra/id-protection/concept-identity-protection-policies)
- [Protect apps with Microsoft Defender for Cloud Apps Conditional Access App Control](https://learn.microsoft.com/en-us/defender-cloud-apps/proxy-intro-aad)

<!--- Results --->
%TestResult%
