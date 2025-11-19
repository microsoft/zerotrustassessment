Without enforcing Local Administrator Password Solution (LAPS) policies, threat actors who gain access to endpoints can exploit static or weak local administrator passwords to escalate privileges, move laterally, and establish persistence. The attack chain typically begins with device compromise—via phishing, malware, or physical access—followed by attempts to harvest local admin credentials. Without LAPS, attackers can reuse compromised credentials across multiple devices, increasing the risk of privilege escalation and domain-wide compromise.

Enforcing Windows LAPS on all corporate Windows devices ensures unique, regularly rotated local administrator passwords. This disrupts the attack chain at the credential access and lateral movement stages, significantly reducing the risk of widespread compromise.

**Remediation action**

Use Intune to enforce Windows LAPS policies that rotate strong and unique local admin passwords, and that back them up securely:  
- [Deploy Windows LAPS policy with Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/windows-laps-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-laps-policy)

For more information, see:  
- [Windows LAPS policy settings reference](https://learn.microsoft.com/windows-server/identity/laps/laps-management-policy-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Learn about Intune support for Windows LAPS](https://learn.microsoft.com/intune/intune-service/protect/windows-laps-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

