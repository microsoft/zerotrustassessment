# Windows 365: Screen Capture Protection

**Implementation Effort:** Medium  
**User Impact:** Medium

## Overview

Screen capture protection reduces the risk that sensitive information displayed in a Windows 365 session can be captured through supported screenshot or screen-sharing mechanisms on the client device. This is especially relevant for privileged workflows, regulated data, and scenarios where Cloud PCs are accessed from endpoints the organization does not fully trust.

It is important to position the control accurately: it can reduce digital capture opportunities, but it does not stop a user from photographing a screen with another device. As part of Zero Trust, it is best combined with watermarking, least-privilege access, and deliberate client support standards.

## Implementation Guidance

1. Confirm client support before enabling the feature broadly. Review Microsoft documentation for supported Windows 365 connection clients and operating systems, because unsupported clients may not enforce the setting and may need to be blocked or redirected to an approved connection method.
2. Configure screen capture protection through the supported Windows management path for Cloud PCs, typically via Microsoft Intune policy settings or the equivalent session-host policy surfaced in Intune or Group Policy. Standardize one approved deployment path to avoid conflicting settings.
3. Scope the control by sensitivity tier. High-risk or regulated data users may require protection by default, while broad populations might first need impact assessment because some collaboration or support workflows can change.
4. Pilot on Windows, macOS, iOS, and Android clients actually used in your organization. Validate user behavior for screenshots, screen sharing, and Teams-based collaboration where Microsoft documentation notes platform-specific differences.
5. Update support documentation. Users and help desk teams should understand why capture is blocked, which client is approved, and what alternative sharing methods are acceptable.

## Reference

- **[Screen capture protection in Azure Virtual Desktop - Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/screen-capture-protection)** — Explains screen capture protection for Azure Virtual Desktop and Windows 365 Cloud PCs.
- **[Accessing Cloud PCs](https://learn.microsoft.com/en-us/windows-365/end-user-access-cloud-pc)** — Lists the supported clients and access methods for Windows 365 Cloud PCs.
- **[Create a policy using settings catalog in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/)** — Shows how to configure Windows settings in Intune by using Settings Catalog policies.
