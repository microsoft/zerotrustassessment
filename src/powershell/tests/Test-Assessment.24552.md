Without a centrally managed firewall policy, macOS devices might rely on default or user-modified settings, which often fail to meet corporate security standards. This exposes devices to unsolicited inbound connections, enabling threat actors to exploit vulnerabilities, establish outbound command-and-control (C2) traffic for data exfiltration, and move laterally within the network—significantly escalating the scope and impact of a breach.

Enforcing macOS Firewall policies ensures consistent control over inbound and outbound traffic, reducing exposure to unauthorized access and supporting Zero Trust through device-level protection and network segmentation.

**Remediation action**

Configure and assign **macOS Firewall** profiles in Intune to block unauthorized traffic and enforce consistent network protections across all managed macOS devices:

- [Configure the built-in firewall on macOS devices](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)

For more information, see:  
-  [Available macOS firewall settings](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-profile-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#macos-firewall-profile)<!--- Results --->
%TestResult%

