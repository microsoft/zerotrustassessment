# Windows 365: Link

**Implementation Effort:** Medium  
**User Impact:** Low

## Overview

Windows 365 Link is intended to provide a simple, dedicated endpoint experience for accessing a Windows 365 Cloud PC with minimal local footprint. In a Zero Trust design, that value comes from reducing local data persistence, simplifying the endpoint role, and standardizing how users reach their Cloud PC.

Because it is a purpose-built access device, the deployment focus is less about local productivity configuration and more about identity, network readiness, Intune management, and supportability. Administrators should confirm how the device fits into their broader Cloud PC access model before rollout.

## Implementation Guidance

1. Confirm the supported Windows 365 Link hardware, licensing, and management prerequisites for your tenant. Validate commercial availability, regional support, and any Windows 365 edition requirements before designing a broad deployment plan.
2. Plan enrollment using the [Windows 365 Link management guidance](https://learn.microsoft.com/en-us/windows-365/link/device-management-overview). Configure only supported CSPs and compliance settings, and use device filters to exclude Link devices from unsupported application assignments.
3. Validate the device's built-in security posture and supported update and sign-in policies. Applicable security baselines and restrictions on local administrator access are built in; do not treat Link as a general-purpose Windows workstation.
4. Test connectivity to Windows 365 from representative networks, including home, branch, and remote-office scenarios. Validate sign-in, Cloud PC launch behavior, audio/video performance, and support workflows when connection quality is poor.
5. Document break-glass and replacement procedures. If a dedicated device fails, users should know the approved alternate way to reach their Cloud PC without resorting to unmanaged or unapproved endpoints.

## Reference

- **[What is Windows 365 Link?](https://learn.microsoft.com/en-us/windows-365/link/overview)** — Introduces Windows 365 Link and its role in accessing Cloud PCs.
- **[Deployment guide for Windows device management - Microsoft Intune](https://learn.microsoft.com/en-us/intune/fundamentals/platform-guide-windows)** — Provides the main guidance for managing Windows devices with Intune.
- **[Windows 365 requirements](https://learn.microsoft.com/en-us/windows-365/enterprise/requirements)** — Lists the technical, licensing, and configuration prerequisites for Windows 365.
