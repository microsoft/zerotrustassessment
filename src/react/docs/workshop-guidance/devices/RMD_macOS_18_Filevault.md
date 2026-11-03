# FileVault

**Implementation Effort:** Low
**User Impact:** Low to Medium — users may see activation prompts or recovery workflows depending on timing and prior state.

## Overview
FileVault is a foundational macOS control because it protects data at rest and serves as an important trust signal in device compliance decisions. A production-quality Intune design must cover enablement timing, recovery-key escrow, key rotation, reporting, and the help-desk process for recovery events.

## Implementation Guidance
1. Create a macOS configuration profile in Microsoft Intune that enables FileVault for the appropriate device populations and align the timing with ADE and Await Configuration decisions.
2. Configure personal recovery key escrow to Intune and verify that support staff know exactly who can retrieve keys, under what approval process, and how retrieval is audited.
3. Pair FileVault enforcement with a macOS compliance policy so unencrypted devices can be surfaced and, where appropriate, blocked from sensitive resources.
4. Pilot activation and escrow on representative devices and validate that the recovery key actually appears where support expects it.
5. Define key-rotation and recovery-event procedures and document exceptions carefully for lab, shared, or legacy devices.

## Video Walkthrough

<iframe width="560" height="315" src="https://www.youtube.com/embed/0lZg1NjJin8?si=V1KSRyemTh9cggXb" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; fullscreen; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Reference
- **[Encrypt macOS devices with FileVault in Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/encrypt-filevault-macos)** — Explains how to configure and manage FileVault encryption on macOS devices with Intune.
- **[Device compliance policies in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-security/compliance/overview)** — Describes compliance policy settings, supported actions, and platform coverage including macOS.
