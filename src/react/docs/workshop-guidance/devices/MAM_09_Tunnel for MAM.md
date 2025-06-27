# Tunnel for MAM

**Implementation Effort:** Medium – IT and Security Operations teams must deploy the Microsoft Tunnel Gateway, configure VPN profiles, and ensure apps are integrated with the Intune App SDK and Microsoft Authentication Library (MSAL).

**User Impact:** Medium – A subset of users on BYOD devices will need to use specific apps and may experience VPN auto-launch behavior or restrictions when accessing corporate resources.

## Overview

**Tunnel for MAM** extends the Microsoft Tunnel VPN Gateway to support **unmanaged Android and iOS devices**—those not enrolled in Intune. It enables secure, per-app VPN access to on-premises resources using **modern authentication**, **Conditional Access**, and **single sign-on**, without requiring full device management. This is ideal for BYOD scenarios where users want to keep personal and work data separate.

### Key Capabilities:
- **Per-App VPN**: VPN is scoped to specific managed apps, not the entire device.
- **Auto-launch**: VPN starts automatically when a protected app is opened.
- **Strict Tunnel Mode (Edge)**: Blocks internet access if VPN is not connected when using a work account.
- **No device enrollment required**: Users retain control over their personal devices.

### Platform Requirements:
- **Android**: Requires Company Portal (sign-in not needed), Defender for Endpoint, Intune App SDK, and MSAL integration.
- **iOS**: Requires Tunnel for MAM SDK, Intune App SDK, MSAL, and Entra app registration [1](https://learn.microsoft.com/en-us/intune/intune-service/protect/microsoft-tunnel-mam).

This solution supports the Zero Trust principle of **assume breach** by ensuring that only trusted apps on unmanaged devices can securely access corporate resources, while minimizing the attack surface and avoiding full device control.

## Reference

- [Microsoft Tunnel for Mobile Application Management](https://learn.microsoft.com/en-us/intune/intune-service/protect/microsoft-tunnel-mam)  
- [Microsoft Tunnel VPN overview](https://learn.microsoft.com/en-us/intune/intune-service/protect/microsoft-tunnel-overview)  
- [Tunnel for MAM iOS SDK developer guide](https://learn.microsoft.com/en-us/intune/intune-service/developer/tunnel-mam-ios-sdk)
