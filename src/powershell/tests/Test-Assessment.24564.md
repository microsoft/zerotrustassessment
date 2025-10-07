Without a properly configured and assigned Local Users and Groups policy in Intune, threat actors can exploit unmanaged or misconfigured local accounts on Windows devices. This can lead to unauthorized privilege escalation, persistence, and lateral movement within the environment. If local administrator accounts aren't controlled, attackers can create hidden accounts or elevate privileges, bypassing compliance and security controls. This gap increases the risk of data exfiltration, ransomware deployment, and regulatory noncompliance.

Ensuring that Local Users and Groups policies are enforced on managed Windows devices, by using account protection profiles, is critical to maintaining a secure and compliant device fleet.


**Remediation action**

Configure and deploy a **Local user group membership** profile from Intune account protection policy to restrict and manage local account usage on Windows devices:  
- Create an [Account protection policy for endpoint security in Intune](https://learn.microsoft.com/intune/intune-service/protect/endpoint-security-account-protection-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#account-protection-profiles)
- [Assign policies in Intune](https://learn.microsoft.com/intune/intune-service/configuration/device-profile-assign?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assign-a-policy-to-users-or-groups)
<!--- Results --->
%TestResult%

