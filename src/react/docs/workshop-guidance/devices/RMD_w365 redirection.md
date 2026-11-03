# Windows 365: Redirections

**Implementation Effort:** Medium  
**User Impact:** Medium

## Overview

Device redirection controls determine whether local resources such as clipboards, printers, drives, audio devices, webcams, and smart cards are available inside a Windows 365 session. These settings directly affect both productivity and data-exfiltration risk, so they should be designed intentionally rather than left at defaults.

In a Zero Trust model, redirection policy should follow least privilege. Allow only the local-device features required for business tasks, and review exceptions for privileged users or highly sensitive workloads separately.

## Implementation Guidance

1. Begin with workload analysis. Knowledge workers may need audio, webcam, and limited clipboard support, while regulated or admin workloads may justify blocking clipboard, local drive, printer, or USB redirection entirely.
2. Configure the desired settings through the supported Windows policy path for your environment, typically Microsoft Intune Settings Catalog or Group Policy for the Cloud PC session host, depending on the join model and management approach. Keep redirection settings grouped logically so they can be audited later.
3. Create separate policies for different risk tiers instead of a single global setting set. For example, allow microphone and camera for collaboration users, but restrict drive and clipboard redirection for privileged-access or sensitive-data groups.
4. Validate the current Microsoft defaults before documenting your standard. If Microsoft changes baseline behavior for clipboard, drive, printer, or USB redirection, reflect that clearly so the workshop distinguishes default state from recommended hardened state.
5. Pilot with real business workflows. Confirm that print, scan, audio, and conferencing scenarios still function where required, and that blocked redirections produce predictable behavior instead of user confusion.

## Reference

- **[Manage device RDP redirections for Cloud PCs.](https://learn.microsoft.com/en-us/windows-365/enterprise/manage-rdp-device-redirections)** — Explains how to configure and manage RDP device redirections for Cloud PCs.
- **[Create a policy using settings catalog in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/)** — Shows how to use Intune Settings Catalog policies to configure Windows devices.
- **[RemoteDesktopServices Policy CSP](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-remotedesktopservices)** — Provides the Policy CSP guidance for Remote Desktop Services session settings.
