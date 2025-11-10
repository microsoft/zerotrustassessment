If Microsoft Entra Conditional Access policies don't enforce device compliance, users can connect to corporate resources from devices that don't meet security standards. This exposes sensitive data to risks like malware, unauthorized access, and regulatory noncompliance. Without controls like encryption enforcement, device health checks, and access restrictions, threat actors can exploit noncompliant devices to bypass security measures and maintain persistence.


Requiring device compliance in Conditional Access policies ensures only trusted and secure devices can access corporate resources. This supports Zero Trust by enforcing access decisions based on device health and compliance posture.

**Remediation action**

Configure Conditional Access policies in Microsoft Entra to require device compliance before granting access to corporate resources:  
- [Create a device compliance-based Conditional Access policy](https://learn.microsoft.com/intune/intune-service/protect/create-conditional-access-intune?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)

For more information, see:
- [What is Conditional Access?](https://learn.microsoft.com/entra/identity/conditional-access/overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Integrate device compliance results with Conditional Access](https://learn.microsoft.com/intune/intune-service/protect/device-compliance-get-started?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#integrate-with-conditional-access)<!--- Results --->
%TestResult%

