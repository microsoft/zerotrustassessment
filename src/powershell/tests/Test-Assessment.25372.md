Comprehensive deployment of the Global Secure Access client is foundational to achieving Zero Trust network security. If you don't deploy the Global Secure Access client to managed endpoints, those devices operate outside the organization's Security Service Edge controls. Threat actors can exploit unprotected endpoints to establish initial access, move laterally, or exfiltrate data without triggering network-level security policies.

Without the Global Secure Access client:

- Devices can't benefit from compliant network checks in Conditional Access policies, source IP restoration, or tenant restrictions.
- Credential theft and token replay attacks are more difficult to detect when traffic bypasses the security perimeter.
- Managed endpoints can't access private applications through Microsoft Entra Private Access.

**Remediation action**

- Install the Global Secure Access client:
    - [Windows client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-windows-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
    - [macOS client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-macos-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
    - [iOS client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-ios-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
    - [Android client](https://learn.microsoft.com/entra/global-secure-access/how-to-install-android-client?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- Monitor the Global Secure Access client health and connection status by using the [Global Secure Access dashboard](https://learn.microsoft.com/entra/global-secure-access/concept-traffic-dashboard?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%
