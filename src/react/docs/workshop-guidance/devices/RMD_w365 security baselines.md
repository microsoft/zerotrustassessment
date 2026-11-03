# Windows 365: Security Baselines

**Implementation Effort:** Medium  
**User Impact:** Low

## Overview

Security baselines in Microsoft Intune provide curated starting points for hardening Windows, Microsoft Edge, and Microsoft Defender. For Windows 365, baselines help reduce configuration drift and establish a consistent minimum security posture across Cloud PCs.

A Zero Trust workshop should emphasize that baselines are starting points, not magic defaults. Administrators should review each setting, understand where it conflicts with business workflows, and document any approved deviation rather than assigning a baseline blindly.

## Implementation Guidance

1. In the Microsoft Intune admin center, review the available security baseline templates relevant to Cloud PCs, such as Windows, Microsoft Edge, and Defender baselines. Align each with the Cloud PC personas you actually operate.
2. Create a pilot baseline profile instead of assigning Microsoft defaults directly to every Cloud PC. Compare baseline settings with existing configuration profiles, endpoint security policies, and update policies to avoid overlap and contradictory settings.
3. Use groups to separate general productivity Cloud PCs from privileged or regulated workloads. More restrictive baselines may be justified for administrator jump environments, finance, or engineering enclaves.
4. Track baseline versioning. When Microsoft releases a new baseline version, review the setting deltas, test them, and migrate intentionally rather than leaving old baselines in place indefinitely.
5. Monitor user and operational impact after deployment. Security baselines that silently break browser workflows, remote support, or app compatibility will not remain durable unless those effects are understood and remediated.

## Reference

- **[Default configuration of Intune's Windows security baselines - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/security-baselines/ref-windows-mdm-settings)** — Provides the Windows security baseline settings used in Microsoft Intune.
- **[Managing Cloud PCs with Microsoft Intune](https://learn.microsoft.com/en-us/windows-365/enterprise/device-management-overview)** — Describes how Cloud PCs are managed through Microsoft Intune.
