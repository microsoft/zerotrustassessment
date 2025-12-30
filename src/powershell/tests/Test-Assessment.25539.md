Azure Firewall Premium offers signature-based IDPS to quickly detect attacks by identifying specific patterns, such as byte sequences in network traffic or known malicious instruction sequences used by malware. These IDPS signatures apply to both application and network-level traffic (Layers 3-7). They are fully managed and continuously updated. IDPS can be applied to inbound, spoke-to-spoke (East-West), and outbound traffic, including traffic to/from an on-premises network.

This check verifies that the Intrusion Detection and Prevention System (IDPS) is enabled in “Alert and deny” mode in the Azure Firewall policy configuration. The check will fail if Intrusion Detection and Prevention System (IDPS) is either Disabled (Off) or if it is configured in “Alert” only mode, in the firewall policy attached to the firewall. 

If this check does not pass, it means that the Intrusion Detection and Prevention System (IDPS) is not analyzing, detecting and actively blocking malicious patterns in legitimate looking traffic.

**Remediation action**
Please check the IDPS section of this article for guidance on how to enable Intrusion Deletion and Prevention System (IDPS) in “Alert and Deny” mode in the Azure Firewall Policy. 

- [Azure Firewall Premium features implementation guide | Microsoft Learn](https://learn.microsoft.com/en-us/azure/firewall/premium-features)
<!--- Results --->
%TestResult%
