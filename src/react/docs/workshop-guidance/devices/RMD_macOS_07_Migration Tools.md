# Migration Tool

**Implementation Effort:** Medium
**User Impact:** Medium — migration affects downtime, app readiness, and trust reset behavior.

## Overview
Migrating Macs from another management platform to Microsoft Intune requires a deliberate decision between in-place migration and wipe-and-redeploy. Community tooling and scripts can accelerate the transition, but the organization still owns testing, rollback planning, user communication, and verification that migrated devices meet the same standards as newly provisioned Macs.

## Implementation Guidance
1. Segment the migration population into devices eligible for in-place migration, devices that must be wiped, and devices that should be retired instead of migrated.
2. If using a community migration script or Microsoft sample, treat it as a starting point, review the code, and test MDM profile removal, Company Portal launch, reenrollment, and cleanup.
3. Define prerequisites before migration begins: local admin availability, FileVault handling, network connectivity, app compatibility, and restart communication.
4. Pilot the process with support-ready users and capture timing, failure modes, and the exact post-migration validation steps.
5. Use wipe-and-redeploy for devices with uncertain state, unsupported macOS versions, or excessive legacy tooling that makes in-place migration too risky.

## Reference
- **[Use Shell Scripts on macOS Devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-management/tools/run-shell-scripts-macos)** — Explains how to deploy and run custom shell scripts on managed macOS devices in Intune.
- **[Set up enrollment for macOS devices - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/apple/methods-macos)** — Describes the supported Intune enrollment paths to use during macOS migration and reenrollment.
- **[Add the Company Portal for macOS App - Microsoft Intune](https://learn.microsoft.com/en-us/intune/app-management/deployment/add-company-portal-macos)** — Explains how to deploy Company Portal for macOS and support user sign-in and post-enrollment access.
