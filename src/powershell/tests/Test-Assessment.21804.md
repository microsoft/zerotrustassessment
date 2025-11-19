When weak authentication methods like SMS and voice calls remain enabled in Microsoft Entra ID, threat actors can exploit these vulnerabilities through multiple attack vectors. Initially, attackers often conduct reconnaissance to identify organizations using these weaker authentication methods through social engineering or technical scanning. Then they can execute initial access through credential stuffing attacks, password spraying, or phishing campaigns targeting user credentials.

Once basic credentials are compromised, threat actors use these weaknesses in SMS and voice-based authentication. SMS messages can be intercepted through SIM swapping attacks, SS7 network vulnerabilities, or malware on mobile devices, while voice calls are susceptible to voice phishing (vishing) and call forwarding manipulation. With these weak second factors bypassed, attackers achieve persistence by registering their own authentication methods. Compromised accounts can be used to target higher-privileged users through internal phishing or social engineering, allowing attackers to escalate privileges within the organization. Finally, threat actors achieve their objectives through data exfiltration, lateral movement to critical systems, or deployment of other malicious tools, all while maintaining stealth by using legitimate authentication pathways that appear normal in security logs. 

**Remediation action**

- [Deploy authentication method registration campaigns to encourage stronger methods](https://learn.microsoft.com/graph/api/authenticationmethodspolicy-update?view=graph-rest-beta&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Disable authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Disable phone-based methods in legacy MFA settings](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-mfa-mfasettings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Deploy Conditional Access policies using authentication strength](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strength-how-it-works?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

