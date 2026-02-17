Without compliant network controls in Conditional Access policies, organizations cannot enforce that users connect to corporate resources through the Global Secure Access service, leaving authentication traffic vulnerable to interception and replay attacks from arbitrary network locations. A threat actor who has obtained valid user credentials through phishing or credential theft can authenticate from any internet location, bypassing Global Secure Access network controls. Once authenticated, the actor can access Microsoft Entra ID-integrated applications and services, exfiltrate data, or establish persistence by creating additional credentials or modifying user permissions. The compliant network check addresses this by requiring that authentication traffic originates from the Global Secure Access service, which tags authentication requests with tenant-specific network identity signals. This enables Microsoft Entra ID Conditional Access to verify that users are connecting through the organization's secured network path before granting access. 

**Remediation actions**

1. Enable Global Secure Access signaling for Conditional Access:
- [Enable compliant network check with Conditional Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-compliant-network#enable-global-secure-access-signaling-for-conditional-access)

2. Create a Conditional Access policy that requires compliant network for access:
- [Protect your resources behind the compliant network](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-compliant-network#protect-your-resources-behind-the-compliant-network)

3. Deploy Global Secure Access clients on devices:
- [Global Secure Access clients overview](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-clients)

4. Understand compliant network enforcement:
- [Compliant network check enforcement](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-compliant-network#compliant-network-check-enforcement)

<!--- Results --->
%TestResult%
