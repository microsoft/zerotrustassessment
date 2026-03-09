OAuth applications configured with URLs that include wildcards, or URL shorteners increase the attack surface for threat actors. Insecure redirect URIs (reply URLs) might allow adversaries to manipulate authentication requests, hijack authorization codes, and intercept tokens by directing users to attacker-controlled endpoints. Wildcard entries expand the risk by permitting unintended domains to process authentication responses, while shortener URLs might facilitate phishing and token theft in uncontrolled environments. 

Without strict validation of redirect URIs, attackers can bypass security controls, impersonate legitimate applications, and escalate their privileges. This misconfiguration enables persistence, unauthorized access, and lateral movement, as adversaries exploit weak OAuth enforcement to infiltrate protected resources undetected.

**Remediation action**

- [Check the redirect URIs for your application registrations.](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) Make sure the redirect URIs don't have *.azurewebsites.net, wildcards, or URL shorteners.
<!--- Results --->
%TestResult%

