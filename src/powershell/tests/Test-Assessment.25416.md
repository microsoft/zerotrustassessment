When you connect remote networks to Global Secure Access through IPsec tunnels but don't set up cloud firewall policies, all internet-bound traffic from branch offices goes through the Security Service Edge without egress filtering controls. If a threat actor gains access to a branch office workstation, they can make outbound connections to command-and-control infrastructure, exfiltrate data over standard ports, or download malicious payloads without network-layer inspection.

Without Global Secure Access cloud firewall:

- You can't enforce a deny-by-default posture or restrict outbound communications from branch networks to unauthorized internet destinations.
- Threat actors can stage data for exfiltration, pivot to cloud resources, or move laterally without detection.
- Traditional perimeter defenses might assume all egress is legitimate, resulting in gaps in security coverage.

Cloud firewall policies linked to the baseline profile provide centralized egress control for all remote network traffic. Administrators can use these policies to define granular filtering rules that restrict unauthorized outbound communications.

**Remediation action**

- As a prerequisite for cloud firewall, [configure remote networks for internet access](https://learn.microsoft.com/entra/global-secure-access/how-to-create-remote-networks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Follow the steps in [Configure Global Secure Access cloud firewall](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-cloud-firewall?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to:
    - Create a cloud firewall policy with appropriate filtering rules.
    - Add or update firewall rules based on source IP, destination IP, ports, and protocols.
    - Link the cloud firewall policy to the baseline profile for remote networks.
<!--- Results --->
%TestResult%

