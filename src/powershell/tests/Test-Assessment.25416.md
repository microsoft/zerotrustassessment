When remote networks are connected to Global Secure Access via IPsec tunnels but lack cloud firewall policies, all internet-bound traffic from branch offices passes through the Security Service Edge (SSE) without egress filtering controls. A threat actor who gains initial access to a branch office workstation through phishing or exploitation can establish outbound connections to command-and-control infrastructure without network-layer inspection blocking suspicious traffic patterns. The compromised system can then exfiltrate sensitive data over standard ports such as TCP/443 or TCP/80, bypassing traditional perimeter defenses that assume all egress is legitimate. Without cloud firewall rules that explicitly allow or block traffic based on source IP, destination IP, ports, and protocols, the organization cannot enforce a deny-by-default posture or restrict lateral movement from branch networks to unauthorized internet destinations. Threat actors can leverage this gap to stage data for exfiltration, download additional malicious payloads, or pivot to cloud resources accessible from the branch network. Cloud Firewall policies linked to the baseline profile (priority 65000) provide centralized egress control for all remote network traffic, enabling administrators to define granular 5-tuple filtering rules that restrict unauthorized outbound communications and detect anomalous traffic patterns before damage occurs.

**Remediation action**

1. [Configure remote networks for internet access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-create-remote-networks)
2. [Create a cloud firewall policy with appropriate filtering rules](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-cloud-firewall)
3. [Link the cloud firewall policy to the baseline profile for remote networks](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-cloud-firewall#link-a-cloud-firewall-policy-to-the-baseline-profile-for-the-remote-network)
4. [Define 5-tuple firewall rules based on source IP, destination IP, ports, and protocols](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-cloud-firewall#add-or-update-a-cloud-firewall-rule-assign-priority-and-enable-or-disable)

This remediation requires the Global Secure Access Administrator role and should be performed after remote networks are configured and before production traffic is routed through Global Secure Access.
Configuration is done in the Microsoft Entra admin center under Global Secure Access > Secure > Cloud firewall policies and Security Profiles > Baseline Profile.

<!--- Results --->
%TestResult%
