If iOS update policies aren’t configured and assigned, threat actors can exploit unpatched vulnerabilities in outdated operating systems on managed devices. The absence of enforced update policies allows attackers to use known exploits to gain initial access, escalate privileges, and move laterally within the environment. Without timely updates, devices remain susceptible to exploits that have already been addressed by Apple, enabling threat actors to bypass security controls, deploy malware, or exfiltrate sensitive data. This attack chain begins with device compromise through an unpatched vulnerability, followed by persistence and potential data breach that impacts both organizational security and compliance posture.

Enforcing update policies disrupts this chain by ensuring devices are consistently protected against known threats.

**Remediation action**

Configure and assign iOS/iPadOS update policies in Intune to enforce timely patching and reduce risk from unpatched vulnerabilities:  
- [Manage iOS/iPadOS software updates in Intune](https://learn.microsoft.com/intune/intune-service/protect/software-updates-guide-ios-ipados?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)<!--- Results --->
%TestResult%

