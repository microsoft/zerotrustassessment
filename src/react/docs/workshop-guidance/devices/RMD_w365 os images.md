# Windows 365: Operating System Images

**Implementation Effort:** Medium  
Admins must choose between default gallery images or create, validate, and upload custom images that meet strict technical requirements.

**User Impact:** Low  
Users receive Cloud PCs with preconfigured OS images; no action or awareness is required from them.

## Overview

Windows 365 uses operating system images to provision Cloud PCs. Admins can select from Microsoft-provided **gallery images** or upload **custom images** stored in Azure. Gallery images are preconfigured with Windows 10/11 Enterprise, Microsoft 365 Apps, and Teams optimizations, and are updated monthly with security patches and performance improvements. Custom images allow organizations to tailor the OS environment but must meet specific requirements, such as being generalized, Gen2, and not previously enrolled in Intune or Active Directory.

Using outdated or misconfigured images can lead to provisioning failures, degraded performance, or security vulnerabilities. This capability supports the Zero Trust principle of "**Verify explicitly"**, as image integrity and configuration directly affect the security posture of the Cloud PC environment.

## Reference

- [Device images in Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/device-images)

- [Add or delete custom device images for Windows 365](https://learn.microsoft.com/en-us/windows-365/enterprise/add-device-images)
