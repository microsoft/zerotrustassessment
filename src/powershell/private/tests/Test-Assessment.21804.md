When weak authentication methods like SMS and voice calls remain enabled in Microsoft Entra ID, threat actors can exploit these vulnerabilities through multiple attack vectors. Initially, attackers often conduct reconnaissance to identify organizations using these weaker authentication methods through social engineering or technical scanning. They then execute initial access through credential stuffing attacks, password spraying, or phishing campaigns targeting user credentials. Once basic credentials are compromised, threat actors leverage the inherent weaknesses in SMS and voice-based authentication - SMS messages can be intercepted through SIM swapping attacks, SS7 network vulnerabilities, or malware on mobile devices, while voice calls are susceptible to voice phishing (vishing) and call forwarding manipulation. With these weak second factors bypassed, attackers achieve persistence by registering their own authentication methods. This enables privilege escalation as compromised accounts can be used to target higher-privileged users through internal phishing or social engineering. Finally, threat actors achieve their objectives through data exfiltration, lateral movement to critical systems, or deployment of additional malicious tools, all while maintaining stealth by using legitimate authentication pathways that appear normal in security logs.

**Remediation action**

Implement registration campaigns:
- [Deploy authentication method registration campaigns to encourage stronger methods](https://learn.microsoft.com/entra/identity/authentication/how-to-mfa-registration-campaign)

Disable Authentication Methods:
- [Update authentication method configuration to set state to "disabled"](https://learn.microsoft.com/graph/api/authenticationmethodspolicy-update?view=graph-rest-1.0&tabs=http)

Configure legacy MFA settings:
- [Disable phone-based methods in legacy MFA service settings](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-mfasettings)

Deploy Conditional Access Policies using Authentication Strength:
- [Ensure SMS and Voice are not accepted for authentication](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strength-how-it-works#how-authentication-strength-works-with-the-authentication-methods-policy)
<!--- Results --->
%TestResult%
