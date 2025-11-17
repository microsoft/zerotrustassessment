
# MDM_04: Mobile Threat Defense for iOS and Android MDM in Intune

**Implementation Effort:** Medium  
IT teams must configure MTD connectors, deploy third-party or Microsoft Defender apps, and integrate threat signals into compliance and Conditional Access policies.

**User Impact:** Medium  
Users may need to install and maintain a threat defense app on their mobile devices and respond to alerts or remediation steps.

---

## Overview

Mobile Threat Defense (MTD) in Microsoft Intune enhances mobile security by integrating with third-party MTD vendors or Microsoft Defender for Endpoint. It enables real-time threat detection and response for iOS and Android devices, helping protect corporate data from mobile-specific threats such as malicious apps, unsafe networks, and OS vulnerabilities.

### Key Capabilities

- **Threat Detection**: MTD apps analyze device behavior, network activity, and app integrity to detect threats.
- **Risk-Based Compliance**: Devices are evaluated against risk levels (low, medium, high) reported by the MTD app.
- **Conditional Access Enforcement**: Devices exceeding the allowed risk level are blocked from accessing corporate resources like Exchange, SharePoint, or Teams.
- **Support for Unenrolled Devices**: MTD can also protect BYOD scenarios using Intune App Protection Policies (MAM).

### Integration Workflow

1. **Deploy MTD App**: Users install the MTD app (e.g., Microsoft Defender or a third-party partner).
2. **Connect MTD to Intune**: Admins configure the MTD connector in the Intune admin center.
3. **Define Compliance Policies**: Set risk level thresholds that determine device compliance.
4. **Enforce with Conditional Access**: Block or limit access based on device risk status.

> Example: A device connected to a suspicious Wi-Fi network is flagged as "High Risk" by the MTD app. Intune marks the device non-compliant and blocks access to Microsoft 365 until the issue is resolved [1](https://learn.microsoft.com/en-us/intune/intune-service/protect/mobile-threat-defense).

### Zero Trust Fit

This supports the **"Assume breach"** principle by continuously evaluating device health and blocking access from compromised endpoints, even if they are enrolled and previously compliant.

---

## Reference

- [Mobile Threat Defense with Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/mobile-threat-defense)  
- [Install mobile threat defense app on your mobile device](https://learn.microsoft.com/en-us/intune/intune-service/user-help/set-up-mobile-threat-defense)  
- [Microsoft Defender for Endpoint - Mobile Threat Defense](https://learn.microsoft.com/en-us/defender-endpoint/mtd)
