Without web content filtering policies based on website categories, users can freely access potentially malicious or inappropriate websites regardless of their location. Threat actors often leverage compromised or malicious websites across various categories to distribute malware, launch phishing campaigns, or establish command and control channels. When users navigate to these sites without category-based filtering, their devices can become infected with malware that establishes persistence mechanisms. Threat actors can then use these compromised endpoints to move laterally within the network, escalate privileges, and exfiltrate sensitive organizational data. Additionally, without categorization-based controls, organizations lack visibility into user browsing patterns that could indicate compromised accounts or insider threats. Web content filtering provides defense in depth by blocking entire categories of risky websites at the network edge before traffic reaches user endpoints, preventing initial access and reducing the attack surface across all internet-connected devices whether on or off the corporate network.

**Remediation action**

- [How to configure Global Secure Access web content filtering](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering) - Guide to create and manage web content filtering policies
- [Configure security profiles](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering#create-a-security-profile) - Guide to create and manage security profiles that group filtering policies
- [Link security profiles to Conditional Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-web-content-filtering#create-and-link-conditional-access-policy) - Instructions for delivering security profiles through Conditional Access session controls

<!--- Results --->
%TestResult%
