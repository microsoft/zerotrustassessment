When Internet Access policies are applied only through the Baseline Profile without Conditional Access integration, traffic filtering operates without identity or context awareness. Threat actors who compromise user credentials can exploit this gap because policy enforcement lacks the ability to differentiate between normal and risky sign-in sessions. Without Conditional Access linking security profiles to users, the organization cannot apply stricter filtering rules based on user risk level, device compliance state, or location context.

A compromised account operating from an anomalous location or exhibiting risky behavior receives the same network access as a legitimate user operating from a compliant device. This uniform policy application prevents adaptive security controls from restricting access during active compromise, allowing threat actors to reach malicious destinations, exfiltrate data, or establish command-and-control channels without triggering user-aware security enforcement. Integrating security profiles with Conditional Access enables identity-aware web content filtering that can block access to high-risk categories for risky sessions while allowing broader access for verified, compliant users.

**Remediation action**

- Create a security profile in Global Secure Access to group web content filtering policies:[How to configure Global Secure Access web content filtering](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering)

- Create a Conditional Access policy targeting users or groups and link the security profile through Session controls: [Conditional Access: Session controls](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-session#use-global-secure-access-security-profile)

<!--- Results --->
%TestResult%
