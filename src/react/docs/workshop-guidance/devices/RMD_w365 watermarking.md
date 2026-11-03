# Windows 365: Watermarking

**Implementation Effort:** Medium  
**User Impact:** Medium

## Overview

Watermarking helps deter and investigate data leakage from Windows 365 sessions by overlaying identifying information on the displayed session. It does not block all forms of exfiltration, but it makes screenshots or recordings less anonymous and can discourage casual capture of sensitive material.

For workshop purposes, watermarking should be described as a detective and deterrent control, not as a full prevention control. It is most effective when paired with screen capture protection, strong access control, and clear acceptable-use expectations.

## Implementation Guidance

1. Confirm the supported Windows 365 client and session scenarios for watermarking before rollout. Unsupported clients may not display the watermark correctly or may need to be excluded from the approved connection standard.
2. Enable watermarking through the supported Windows or remote session policy surface exposed through Microsoft Intune or equivalent management tooling. Keep policy scope narrow during pilot so you can observe usability impact before tenant-wide deployment.
3. Prioritize high-sensitivity groups first. Finance, legal, HR, developers handling source code, and privileged operations staff often benefit most from early deployment.
4. Validate visibility and readability. The watermark should be obvious enough to deter capture without making normal work unusable, especially for long sessions or detailed applications.
5. Update user communication and investigative procedures. Users should know why the watermark exists, and security teams should know what session identifiers or metadata can be correlated if an image is later discovered outside approved channels.

## Reference

- **[Watermarking in Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/watermarking)** — Explains how watermarking works for Windows 365 Cloud PC sessions.
- **[Accessing Cloud PCs](https://learn.microsoft.com/en-us/windows-365/end-user-access-cloud-pc)** — Lists the supported clients and access methods for Windows 365 Cloud PCs.
- **[Managing Cloud PCs with Microsoft Intune](https://learn.microsoft.com/en-us/windows-365/enterprise/device-management-overview)** — Describes how Cloud PCs are managed through Microsoft Intune.
