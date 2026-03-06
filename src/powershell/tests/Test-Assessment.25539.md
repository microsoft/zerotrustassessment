Azure Firewall Premium provides signature-based intrusion detection and prevention (IDPS) that identifies attacks by detecting specific patterns in network traffic, such as byte sequences and known malicious instruction sequences used by malware. IDPS applies to inbound, east-west (spoke-to-spoke), and outbound traffic across Layers 3-7. When IDPS isn't configured in `Alert and deny` mode, Azure Firewall only logs detected threats without blocking them.

Without IDPS enabled in `Alert and deny` mode:

- Threat actors can send traffic that matches known attack signatures without being blocked.
- Organizations running IDPS in `Alert only` mode gain visibility into threats but can't prevent intrusion attempts from reaching their workloads.
- Lateral movement and exfiltration traffic that matches known attack signatures passes through the firewall without active intervention.

**Remediation action**

- [Enable IDPS in Alert and Deny mode in Azure Firewall Premium](https://learn.microsoft.com/azure/firewall/premium-features?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) by configuring the intrusion detection mode to `Alert and deny` in the firewall policy.
<!--- Results --->
%TestResult%

