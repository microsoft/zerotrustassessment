Azure Firewall threat intelligence-based filtering alerts on and denies traffic to and from known malicious IP addresses, fully qualified domain names (FQDNs), and URLs sourced from the Microsoft Threat Intelligence feed. When you don't enable threat intelligence in `Alert and deny` mode, Azure Firewall doesn't actively block traffic to known malicious destinations.

If you don't enable threat intelligence in `Alert and deny` mode:

- Threat actors can communicate with known malicious infrastructure, enabling data exfiltration and command-and-control communication without active blocking.
- Organizations that use `Alert only` mode can see threat activity in logs but can't prevent connections to known bad destinations.
- All firewall policy tiers remain exposed to threats that the Microsoft Threat Intelligence feed already identified.

**Remediation action**

- [Configure threat intelligence settings in Azure Firewall Manager](https://learn.microsoft.com/azure/firewall-manager/threat-intelligence-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to set the threat intelligence mode to `Alert and deny` in the firewall policy.
<!--- Results --->
%TestResult%

