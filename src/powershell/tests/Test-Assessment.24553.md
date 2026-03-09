If Windows Update policies aren't enforced across all corporate Windows devices, threat actors can exploit unpatched vulnerabilities to gain unauthorized access, escalate privileges, and move laterally within the environment. The attack chain often begins with device compromise via phishing, malware, or exploitation of known vulnerabilities, and is followed by attempts to bypass security controls. Without enforced update policies, attackers leverage outdated software to persist in the environment, increasing the risk of privilege escalation and domain-wide compromise.

Enforcing Windows Update policies ensures timely patching of security flaws, disrupting attacker persistence, and reducing the risk of widespread compromise.

**Remediation action**

Start with [Manage Windows software updates in Intune](https://learn.microsoft.com/intune/device-updates/windows/configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to understand the available Windows Update policy types and how to configure them.

Intune includes the following Windows update policy type: 
- [Windows quality updates policy](https://learn.microsoft.com/intune/device-updates/windows/quality-updates?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to install the regular monthly updates for Windows.*
- [Expedite updates policy](https://learn.microsoft.com/intune/device-updates/windows/expedite-updates?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to quickly install critical security patches.*
- [Feature updates policy](https://learn.microsoft.com/intune/device-updates/windows/feature-updates?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Update rings policy](https://learn.microsoft.com/intune/device-updates/windows/update-rings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to manage how and when devices install feature and quality updates.*
- [Windows driver updates](https://learn.microsoft.com/intune/device-updates/windows/driver-updates?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - *to update hardware components.*
<!--- Results --->
%TestResult%

