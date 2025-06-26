# Backup to iCloud

**Implementation Effort:** Low – IT administrators only need to configure a single setting within the iOS/iPadOS App Protection Policy in Microsoft Intune.

**User Impact:** Medium – A subset of users may notice changes in how their work or school data is backed up, especially if backup to iCloud is blocked or restricted.

## Overview

In Microsoft Intune, administrators can control whether organizational data within managed apps on iOS/iPadOS devices is allowed to be backed up to **iCloud** or **iTunes**. This setting is part of the **App Protection Policy (APP)** configuration and is critical for protecting sensitive corporate data on both BYOD and corporate-enrolled Apple devices.

The setting **“Backup Org data to iTunes and iCloud backups”** offers two options:
- **Allow** – Enables backup of work or school data to iCloud and iTunes.
- **Block** – Prevents backup of organizational data, reducing the risk of data leakage through Apple’s cloud services.

Blocking backup aligns with the Zero Trust principle of **assume breach**, as it minimizes the risk of sensitive data being stored in personal cloud environments that are outside the organization’s control. This is especially important for regulated industries or organizations with strict data residency and compliance requirements.

If not configured properly, corporate data could be unintentionally stored in personal iCloud backups, potentially violating internal policies or external regulations.

## Reference

- [iOS/iPadOS app protection policy settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-ios)  
- [Back up and restore iOS/iPadOS - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/backup-restore-ios)  
- [Create and deploy app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policies)
