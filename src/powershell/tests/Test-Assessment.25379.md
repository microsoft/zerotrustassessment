Without compliant network controls in Conditional Access policies, organizations can't enforce that users connect to corporate resources through the Global Secure Access service. This limitation leaves authentication traffic vulnerable to interception and replay attacks from arbitrary network locations. 

A threat actor who obtains valid user credentials through phishing or credential theft can authenticate from any internet location, bypassing Global Secure Access network controls. Once authenticated, the threat actor can access Microsoft Entra ID-integrated applications and services, exfiltrate data, or establish persistence by creating additional credentials or modifying user permissions. 

The compliant network check reduces this risk by requiring that authentication traffic originates from the Global Secure Access service, which tags authentication requests with tenant-specific network identity signals. This requirement enables Microsoft Entra ID Conditional Access to verify that users connect through the organization's secured network path before granting access.

**Remediation action**
- Enable Global Secure Access signaling for Conditional Access. For more information, see [Enable compliant network check with Conditional Access](https://learn.microsoft.com/entra/global-secure-access/how-to-compliant-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-global-secure-access-signaling-for-conditional-access).
- Create a Conditional Access policy that requires compliant network for access. For more information, see [Protect your resources behind the compliant network](https://learn.microsoft.com/entra/global-secure-access/how-to-compliant-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#protect-your-resources-behind-the-compliant-network).
- Deploy Global Secure Access clients on devices. For more information, see [Global Secure Access clients overview](https://learn.microsoft.com/entra/global-secure-access/concept-clients?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Understand compliant network enforcement. For more information, see [Compliant network check enforcement](https://learn.microsoft.com/entra/global-secure-access/how-to-compliant-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#compliant-network-check-enforcement).
<!--- Results --->
%TestResult%

