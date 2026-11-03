# Device Restrictions

**Implementation Effort:** Medium
**User Impact:** Medium — restrictions can affect user workflows, peripherals, collaboration features, and admin flexibility.

## Overview
Device restrictions are one part of the macOS hardening baseline in Microsoft Intune. The goal is not to disable every feature, but to reduce attack surface and data leakage in ways that match device ownership, user role, and risk level while keeping control definitions technically accurate and supportable.

## Implementation Guidance
1. Define restriction tiers based on persona and ownership, such as standard corporate Mac, privileged admin Mac, developer Mac, and any limited BYOD case.
2. Use the Intune settings catalog or supported Apple settings where available before resorting to custom profiles or scripts.
3. Prioritize high-value restrictions such as AirDrop, unmanaged cloud sync behaviors, remote login, screen sharing, and external-media controls where justified.
4. Validate every restriction with the impacted user group because some settings need alternate guardrails instead of blanket disablement.
5. Review the baseline regularly, especially after major macOS releases introduce new manageable settings or retire older profile keys.

## Reference
- **[Create a policy using settings catalog in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/)** — Describes using the settings catalog to configure macOS device settings in Intune.
- **[Add custom settings to Apple devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/templates/configure-custom-settings-apple)** — Covers using custom profiles to configure Apple device settings, including macOS, in Intune.
- **[Configure Microsoft Defender for Endpoint with Intune and onboard devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/microsoft-defender/configure-integration)** — Covers integrating Defender for Endpoint with Intune and onboarding macOS devices.
