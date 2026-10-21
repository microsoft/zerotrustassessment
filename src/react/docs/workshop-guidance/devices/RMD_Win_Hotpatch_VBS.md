# Windows Hotpatch & Virtualization-Based Security (VBS)

**Implementation Effort:** Low – Hotpatching is enabled by default for eligible devices in Windows Autopatch starting May 2026; requires Windows 11 Enterprise E3/E5 and Virtualization-Based Security (VBS) enabled.

**User Impact:** Low – Significantly improves user productivity by applying monthly Windows security updates in memory without requiring a device restart for most months of the year.

## Overview

**Windows Hotpatching** installs monthly Windows security quality updates by patching the in-memory code of running processes without requiring the device to reboot. Because hotpatching relies on **Virtualization-Based Security (VBS)**, enabling VBS is both a core Zero Trust hardware isolation control and a prerequisite for rebootless patching.

Key 2026 updates include:
- **Hotpatching Enabled by Default in Windows Autopatch (April/May 2026):** Starting with the May 2026 Windows security update, hotpatch updates are enabled by default for all eligible Windows 11 devices managed through Windows Autopatch.
- **Granular Opt-Out Controls:** Organizations can manage hotpatch behavior either through a **Tenant-level setting** in the Intune admin center or per-group via a **Windows quality update policy** (which overrides the tenant-level setting).
- **Faster Patch Compliance:** Reduces reboot deferral delays so endpoints are protected against newly disclosed vulnerabilities faster.

This supports *Assume breach* and *Verify explicitly* by combining VBS memory isolation with rapid, low-friction security update deployment.

## Key Configuration Steps

1. Ensure Windows 11 devices have **Virtualization-Based Security (VBS)** and Secure Boot enabled via Intune Endpoint Security / Security Baselines.
2. Onboard eligible Windows 11 Enterprise devices to **Windows Autopatch** / Intune Windows Quality Update policies.
3. Verify the tenant-level hotpatch setting and quality update policies in the Intune admin center (`Devices > Windows updates > Quality updates`).
4. Monitor patch compliance and risk classification (*Current*, *Exposed*, *Critical*) using the **Autopatch update risk visibility report**.

## Reference

- [Hotpatch updates in Windows Autopatch](https://aka.ms/HotpatchByDefault)
- [Protect your estate: Reassess your Windows update policies (Autopatch update risk visibility)](https://aka.ms/ReassessProtect)
- [Manage Windows quality updates in Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-updates/windows/manage-quality-updates)
