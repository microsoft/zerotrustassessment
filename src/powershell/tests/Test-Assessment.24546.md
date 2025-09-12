If Windows Automatic Enrollment is not enabled, unmanaged devices can become an entry point for attackers. Threat actors may use these devices to access corporate data, bypass compliance policies, and introduce vulnerabilities into the environment. 

Without automatic enrollment, devices can remain unmanaged while still establishing an Entra Join trust. This creates blind spots in the security posture, as unmanaged devices communicating with Entra may expose weaknesses in the operating system or misconfigured applications that attackers can exploit. 

Enabling automatic enrollment closes these gaps by ensuring every device is brought under management as soon as it joins the network. This enforces compliance, reduces risk, and strengthens the organization’s Zero Trust model by guaranteeing all devices are secured from the start.

**Remediation action**

Configure automatic device enrollment in Intune: 
- [Enroll devices in Microsoft Intune](https://learn.microsoft.com/mem/intune/enrollment/windows-enrollment-methods)
- [Set up automatic enrollment for Windows devices](https://learn.microsoft.com/intune/intune-service/enrollment/windows-enroll)

<!--- Results --->
%TestResult%
