When an iOS update policy is not created and assigned, threat actors can exploit unpatched vulnerabilities in outdated operating systems on managed devices. The absence of enforced updates and patches allows attackers to leverage known exploits to gain initial access, escalate privileges, and move laterally within the environment. Without timely updates, devices remain susceptible to exploits that have already been addressed by Apple, enabling threat actors to bypass security controls, deploy malware, or exfiltrate sensitive data. This kill chain begins with device compromise through an unpatched vulnerability, followed by persistence and potential data breach, impacting both organizational security and compliance posture. Enforcing update policies disrupts this chain by ensuring devices are consistently protected against known threats.

**Remediation action**

Create and assign iOS update policies: 
- [Manage iOS/iPadOS software updates using MDM-based policies in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/software-updates-ios) 
- [DDM software updates with the settings catalog in Microsoft Intune](https://learn.microsoft.com/intune/intune-service/protect/managed-software-updates-ios-macos)

<!--- Results --->
%TestResult%
