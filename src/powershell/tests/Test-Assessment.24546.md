If Windows automatic enrollment isn't enabled, unmanaged devices can become an entry point for attackers. Threat actors might use these devices to access corporate data, bypass compliance policies, and introduce vulnerabilities into the environment. Devices joined to Microsoft Entra without Intune enrollment create gaps in visibility and control. These unmanaged endpoints can expose weaknesses in the operating system or misconfigured applications that attackers can exploit.

Enforcing automatic enrollment ensures Windows devices are managed from the start, enabling consistent policy enforcement and visibility into compliance. This supports Zero Trust by ensuring all devices are verified, monitored, and governed by security controls.

**Remediation action**

Enable automatic enrollment for Windows devices using Intune and Microsoft Entra to ensure all domain-joined or Entra-joined devices are managed:  
- [Enable Windows automatic enrollment](https://learn.microsoft.com/intune/intune-service/enrollment/windows-enroll?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-windows-automatic-enrollment)

For more information, see:  
- [Deployment guide - Enrollment for Windows](https://learn.microsoft.com/intune/intune-service/fundamentals/deployment-guide-enroll?tabs=work-profile%2Ccorporate-owned-apple%2Cautomatic-enrollment&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enrollment-for-windows)
<!--- Results --->
%TestResult%

