# Windows 365: Screen Capture Protection

**Implementation Effort:** Medium  
Configuration requires policy deployment via Intune or Group Policy and testing across supported platforms, especially for mixed-device environments.

**User Impact:** Medium  
Users may be restricted from using screen sharing or collaboration tools like Teams during Cloud PC sessions, and unsupported platforms may be blocked from connecting.

## Overview

Screen capture protection in Windows 365 prevents sensitive content from being captured through screenshots or screen sharing tools on client devices. When enabled, this feature blocks remote desktop content from being visible in screenshots. Additionally, on MacOS screen capture protection prevents screen sharing within Microsoft Teams. It can be configured to block screen capture either on the client side only or on both the client and session host, depending on the security requirements.

This feature is enforced by the Windows app on Windows, macOS, iOS, and Android. It is not supported on web client. See the below link for details the configuration, as it can vary for different operating systems. Organizations must carefully plan deployment based on the platforms their users connect from. If not implemented, sensitive data displayed in Cloud PC sessions may be exposed through screen capture tools, increasing the risk of data leakage.

Screen capture protection cannot prevent physical photography of the screen. However, it supports the Zero Trust principle of **\"Assume breach\"** by helping trace and deter data exfiltration attempts.

# Reference

- [Enable screen capture protection in Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/screen-capture-protection)
