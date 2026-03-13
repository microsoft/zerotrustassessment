When the Global Secure Access client is not deployed to managed endpoints, those devices operate outside the organization's Security Service Edge controls. Threat actors can exploit unprotected endpoints to establish initial access through phishing or drive-by downloads, then move laterally or exfiltrate data without triggering network-level security policies.

Devices lacking the Global Secure Access client cannot benefit from compliant network checks in Conditional Access policies, source IP restoration for accurate sign-in logging, or tenant restrictions that prevent unauthorized access to external organizations. Credential theft and token replay attacks become more difficult to detect when traffic from these endpoints bypasses the security perimeter. Organizations with incomplete client deployment create a fragmented security posture where protected and unprotected devices coexist, allowing threat actors to identify and target the weakest links.

The gap between managed device counts (Entra ID joined and Hybrid joined devices) and Global Secure Access active device counts represents the attack surface that remains unmonitored. Managed endpoints that lack the client also cannot access private applications through Microsoft Entra Private Access, potentially driving users to insecure workarounds. Ensuring comprehensive client deployment is foundational to achieving Zero Trust network security—without the client, the security controls cannot be enforced regardless of how well policies are configured.

**Remediation action**
- Install the Global Secure Access client:
    - [Windows client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-windows-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
    - [macOS client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-macos-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
    - [iOS client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-ios-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
    - [Android client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-android-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- Monitor the Global Secure Access client health and connection status by using the [Global Secure Access dashboard](https://learn.microsoft.com/entra/global-secure-access/concept-traffic-dashboard?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%
