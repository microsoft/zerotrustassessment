Azure Firewall supports web category filtering that allows administrators to control outbound access based on website classification. Categories are organized into groups including Liability, High Bandwidth, Business Use, and General Surfing. The Liability group contains inherently dangerous categories such as CriminalActivity, Hacking, IllegalSoftware, Malware, Phishing, and Violence that pose direct security and compliance risks.

Without web category deny rules, users behind the firewall can reach malware distribution sites, phishing pages, command-and-control infrastructure, and other high-risk destinations. Threat actors routinely host payloads on compromised sites in these categories, and blocking them at the network layer provides defense-in-depth that complements endpoint protection and threat intelligence (Test 25537) controls.

This check verifies that every Azure Firewall Policy attached to a firewall has at least one application rule in a Deny rule collection that targets web categories. Both Standard and Premium SKUs support web category filtering — Premium adds full-URL matching for HTTPS traffic when TLS inspection is enabled (Test 25550).

**Remediation action**

- [Azure Firewall web categories overview](https://learn.microsoft.com/en-us/azure/firewall/web-categories)
- [Configure Azure Firewall application rules with web categories](https://learn.microsoft.com/en-us/azure/firewall/tutorial-firewall-deploy-portal)
- [Azure Firewall Premium features (full-URL filtering with TLS inspection)](https://learn.microsoft.com/en-us/azure/firewall/premium-features)

<!--- Results --->
%TestResult%
