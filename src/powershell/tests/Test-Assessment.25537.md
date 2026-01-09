Azure Firewall Threat intelligence-based filtering alerts and denies traffic from/to known malicious IP addresses, FQDNs, and URLs. The IP addresses, domains, and URLs are sourced from the Microsoft Threat Intelligence feed, which includes multiple sources including the Microsoft Cyber Security team. When threat intelligence-based filtering is enabled, Azure Firewall evaluates traffic against the threat intelligence rules before applying NAT, network, or application rules.

This check verifies that Threat Intelligence feature is enabled in “Alert and Deny” mode in the Azure Firewall policy configuration. The check will fail if Threat Intelligence is either “Disabled” or if it is not configured in “Alert and Deny” mode, in the firewall policy attached to the firewall.

**Remediation action**

Please check this article for guidance on how to enable Threat Intelligence in “Alert and Deny” mode in the Azure Firewall Policy:
- [Azure Firewall threat intelligence configuration | Microsoft Learn](https://learn.microsoft.com/en-us/azure/firewall-manager/threat-intelligence-settings)

<!--- Results --->
%TestResult%
