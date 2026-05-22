Without network content filtering policies configured in Global Secure Access, threat actors can exfiltrate data to unsanctioned destinations through browsers, applications, and APIs. File sharing services, cloud storage providers, and peer-to-peer transfer sites remain unrestricted when you don't implement network content filtering policies.

Without this protection:

- Threat actors can upload files containing intellectual property, credentials, or customer data to external services without detection.
- Unmanaged cloud applications and generative AI tools become exfiltration channels for sensitive information.
- The network layer lacks real-time data protection enforcement, allowing threat actors to bypass endpoint-based controls.
- Threat actors can disguise malicious payloads or sensitive data within common file formats and transfer them across the network perimeter undetected.

**Remediation action**

- [Configure Global Secure Access web content filtering](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-web-content-filtering?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci), including file policies to monitor and control file transfers.
- [Enable and manage the Microsoft traffic forwarding profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-microsoft-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) that group filtering policies for enforcement through Conditional Access.
- [Link security profiles to Conditional Access policies](https://learn.microsoft.com/entra/identity/conditional-access/concept-conditional-access-session?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) for user-aware and context-aware enforcement of network security policies.
- [Install the Global Secure Access client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-windows-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) on end-user devices to enable traffic acquisition and policy enforcement.
<!--- Results --->
%TestResult%

