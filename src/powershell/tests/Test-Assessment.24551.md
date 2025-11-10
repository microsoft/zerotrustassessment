If policies for Windows Hello for Business (WHfB) aren't configured and assigned to all users and devices, threat actors can exploit weak authentication mechanisms—like passwords—to gain unauthorized access. This can lead to credential theft, privilege escalation, and lateral movement within the environment. Without strong, policy-driven authentication like WHfB, attackers can compromise devices and accounts, increasing the risk of widespread impact.

Enforcing WHfB disrupts this attack chain by requiring strong, multifactor authentication, which helps reduce the risk of credential-based attacks and unauthorized access.

**Remediation action**

Deploy Windows Hello for Business in Intune to enforce strong, multifactor authentication:  
- [Configure a tenant-wide Windows Hello for Business policy](https://learn.microsoft.com/intune/intune-service/protect/windows-hello?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-windows-hello-for-business-policy-for-device-enrollment) that applies at the time a device enrolls with Intune.
- After enrollment, [configure Account protection profiles](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-account-protection-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#account-protection-profiles) and [assign](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups) different configurations for Windows Hello for Business to different groups of users and devices. <!--- Results --->
%TestResult%

