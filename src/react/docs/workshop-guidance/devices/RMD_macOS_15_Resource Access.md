# Resource Access (Certificates, VPN, Network Config)

**Implementation Effort:** Medium
**User Impact:** Low — when designed correctly, certificates and profiles are mostly transparent to users.

## Overview
Resource access profiles let Intune-managed Macs connect to protected Wi-Fi, VPN, and certificate-backed services without relying on insecure shared secrets or manual configuration. The design should start with certificate trust, then layer network profiles and Conditional Access so the device, user, and network path are all validated appropriately.

## Implementation Guidance
1. Start with PKI design: trusted roots, issuing method, certificate lifecycle, and whether SCEP, PKCS, or Microsoft Cloud PKI-backed profiles are in scope.
2. Deploy trusted root and issuing certificates first in the Microsoft Intune admin center and validate subject naming before assigning Wi-Fi or VPN profiles.
3. Create separate Wi-Fi and VPN profiles by device role or ownership where access needs differ and use certificate-based authentication wherever possible.
4. Pilot profile application and connection success from new enrollment, existing devices, and off-network scenarios, including certificate renewal behavior.
5. Monitor both Intune deployment state and actual connection outcomes with the network team so certificate or RADIUS issues are found quickly.

## Reference
- **[Create trusted certificate profiles in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/certificates/trusted-root-profiles)** — Explains how to deploy trusted root certificates to devices managed by Intune.
- **[Use SCEP certificate profiles with Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/certificates/scep-profiles)** — Explains how to create and assign SCEP certificate profiles in Intune.
- **[Configure VPN settings for Apple devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/templates/ref-vpn-settings-apple)** — Covers configuring VPN settings for Apple devices, including macOS, in Intune.
