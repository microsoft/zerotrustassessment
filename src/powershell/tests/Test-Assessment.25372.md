When the Global Secure Access client is not deployed to managed endpoints, those devices operate outside the organization's Security Service Edge controls. Threat actors can exploit unprotected endpoints to establish initial access through phishing or drive-by downloads, then move laterally or exfiltrate data without triggering network-level security policies.

Devices lacking the Global Secure Access client cannot benefit from compliant network checks in Conditional Access policies, source IP restoration for accurate sign-in logging, or tenant restrictions that prevent unauthorized access to external organizations. Credential theft and token replay attacks become more difficult to detect when traffic from these endpoints bypasses the security perimeter. Organizations with incomplete client deployment create a fragmented security posture where protected and unprotected devices coexist, allowing threat actors to identify and target the weakest links.

The gap between Intune-managed device counts and Global Secure Access active device counts represents the attack surface that remains unmonitored. Managed endpoints that lack the client also cannot access private applications through Microsoft Entra Private Access, potentially driving users to insecure workarounds. Ensuring comprehensive client deployment is foundational to achieving Zero Trust network security—without the client, the security controls cannot be enforced regardless of how well policies are configured.

**Remediation action**

Deploy the GSA client on Windows endpoints
- [Install the Global Secure Access client for Windows](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-install-windows-client)

Deploy the GSA client on macOS endpoints
- [Install the Global Secure Access client for macOS](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-install-macos-client)

Deploy on iOS
- [Install the Global Secure Access client for iOS](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-install-ios-client)

Deploy on Android
- [Install the Global Secure Access client for Android](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-install-android-client)

Monitor client health
- [Global Secure Access dashboard](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-traffic-dashboard)

<!--- Results --->
%TestResult%
