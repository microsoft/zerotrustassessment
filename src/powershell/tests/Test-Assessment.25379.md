Without compliant network controls in Conditional Access policies, organizations cannot enforce that users connect to corporate resources through the Global Secure Access service, leaving authentication traffic vulnerable to interception and replay attacks from arbitrary network locations. A threat actor who has obtained valid user credentials through phishing or credential theft can authenticate from any internet location, bypassing Global Secure Access network controls. Once authenticated, the actor can access Microsoft Entra ID-integrated applications and services, exfiltrate data, or establish persistence by creating additional credentials or modifying user permissions. The compliant network check addresses this by requiring that authentication traffic originates from the Global Secure Access service, which tags authentication requests with tenant-specific network identity signals. This enables Microsoft Entra ID Conditional Access to verify that users are connecting through the organization's secured network path before granting access. 

**Remediation action**

- [Global Secure Access > Session Management > Adaptive Access](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/SessionManagementMenu.ReactView/menuId~/null/sectionId~/null)
- [Conditional Access > Named Locations](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations)
- [Conditional Access Policies](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies) 
- [Enable compliant network check with Conditional Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-compliant-network#enable-global-secure-access-signaling-for-conditional-access)
- [Protect your resources behind the compliant network](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-compliant-network#protect-your-resources-behind-the-compliant-network)
- [Global Secure Access clients overview](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-clients)
- [Compliant network check enforcement](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-compliant-network#compliant-network-check-enforcement)

<!--- Results --->
%TestResult%
