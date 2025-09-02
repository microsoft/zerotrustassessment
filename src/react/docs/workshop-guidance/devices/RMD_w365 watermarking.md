# Windows 365: Watermarking

**Implementation Effort:** Medium  
Enabling watermarking requires configuring policies via Intune or Group Policy and ensuring client compatibility, which involves coordination between IT and security teams.

**User Impact:** Medium  
Users may notice visible QR code overlays during Cloud PC sessions, and unsupported clients will be blocked from connecting, which may require user communication and support.

## Overview

Windows 365 watermarking is a security feature that overlays QR code watermarks on Cloud PC remote desktop sessions to discourage unauthorized screen captures and data leakage. Each watermark includes session-specific metadata such as the connection ID, device ID, and timestamp, allowing administrators to trace activity if sensitive data is exposed.

This feature cannot prevent physical photography of the screen. However, it supports the Zero Trust principle of **\"Assume breach\"** by helping trace and deter data exfiltration attempts.

If watermarking is not deployed, organizations risk untraceable data leaks from screen captures, especially in high-sensitivity environments.

## Reference

- [Watermarking in Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/watermarking)