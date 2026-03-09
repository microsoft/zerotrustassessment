# Review the Device Health Report to Ensure All Devices Are Fully Protected; Update Devices That Are Out of Compliance (Daily)

**Implementation Effort:** Low — This is a targeted daily action where IT/SecOps reviews existing reports without needing long-term programs.  
**User Impact:** Low — All health checks and remediation decisions are performed by administrators, and end users are not required to take action.

## Overview
The Device Health report in Microsoft Defender for Endpoint helps security teams understand whether devices are properly onboarded, protected, and reporting as expected. It shows sensor health, antivirus status, OS versions, Defender AV update versions, and other indicators that reflect device protection levels. Daily review ensures that devices with misconfigured or inactive sensors, outdated antivirus signatures, or missing updates are quickly identified and fixed. If this review is not done, devices can become unmonitored, fall behind on security updates, and create blind spots that attackers can exploit.  
This aligns with the Zero Trust principle **Verify Explicitly**, because all devices must continuously report healthy sensor and security status before they can be trusted within the environment.

### Where to view and configure
You can view device health and compliance in the following areas of the Microsoft Defender portal:

- **Reports → Device health**  
  Shows sensor health, antivirus status, OS platform distribution, Windows version coverage, and Defender AV update versions.  
  (No images were available in the referenced Learn article.)  
  [Device health reports in Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/device-health-reports)

- **Assets → Devices**  
  Displays risk level, exposure level, onboarding status, sensor health state, mitigation status, and more.  
  [Device inventory](https://learn.microsoft.com/en-us/defender-endpoint/machines-view-overview)

- **Reports → Sensor health**  
  Helps identify devices with inactive, misconfigured, or nonreporting sensors.  
  [Check sensor status](https://learn.microsoft.com/en-us/defender-endpoint/check-sensor-status)

## Reference
- [Device health reports in Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/device-health-reports)  
- [Device inventory in Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/machines-view-overview)  
- [Check sensor status in Microsoft Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/check-sensor-status)
