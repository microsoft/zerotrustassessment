If policies for Windows Firewall aren't configured and assigned, threat actors can exploit unprotected endpoints to gain unauthorized access, move laterally, and escalate privileges within the environment. Without enforced firewall rules, attackers can bypass network segmentation, exfiltrate data, or deploy malware, increasing the risk of widespread compromise.

Enforcing Windows Firewall policies ensures consistent application of inbound and outbound traffic controls, reducing exposure to unauthorized access and supporting Zero Trust through network segmentation and device-level protection.

**Remediation action**

Configure and assign firewall policies for Windows in Intune to block unauthorized traffic and enforce consistent network protections across all managed devices:

- [Configure firewall policies for Windows devices](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci). Intune uses two complementary profiles to manage firewall settings:
  - **Windows Firewall** - Use this profile to configure overall firewall behavior based on network type.
  - **Windows Firewall rules** - Use this profile to define traffic rules for apps, ports, or IPs, tailored to specific groups or workloads. This Intune profile also supports use of [reusable settings groups](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#add-reusable-settings-groups-to-profiles-for-firewall-rules) to help simplify management of common settings you use for different profile instances.
- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)

For more information, see:  
- [Available Windows Firewall settings](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-firewall-profile-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#windows-firewall-profile)
<!--- Results --->
%TestResult%

