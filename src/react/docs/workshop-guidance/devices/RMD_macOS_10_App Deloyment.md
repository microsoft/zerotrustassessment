# App Deployments

**Implementation Effort:** Medium
**User Impact:** Medium — users may see installs, restarts, or self-service availability changes depending on assignment type.

## Overview
Application management on macOS in Microsoft Intune should balance user productivity with software trust, packaging quality, and operational simplicity. The recommended approach is to standardize approved app sources, minimize duplicate packaging models, and tie required app delivery to provisioning and compliance needs.

## Implementation Guidance
1. Create an app decision tree: Microsoft 365 apps where supported, vendor-supplied signed PKG apps where appropriate, internally packaged line-of-business apps when needed, and web links only for lightweight access scenarios.
2. Validate every app source and signing chain and download installers from the vendor or a controlled internal repository.
3. In the Microsoft Intune admin center, define required versus available assignments carefully and keep only essential apps in the day-zero path.
4. Test install behavior on each supported macOS version, especially for system extensions, network extensions, PPPC permissions, and Apple silicon dependencies.
5. Monitor install failures, stale versions, and duplicate app records and retire old packages promptly.

## Reference
- **[Add the Company Portal for macOS App - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/deployment/add-company-portal-macos)** — Covers adding and deploying a macOS app in Intune, including the Company Portal app.
- **[Add Microsoft 365 Apps to macOS Devices with Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/deployment/add-microsoft-365-macos)** — Explains how to assign and deploy Microsoft 365 Apps to managed macOS devices using Intune.
- **[Add an Unmanaged macOS PKG App to Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/deployment/add-unmanaged-pkg-macos)** — Covers uploading and deploying unmanaged PKG apps to macOS devices from Intune.
