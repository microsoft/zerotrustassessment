# Backup to Android Backup Services

**Implementation Effort:** Low – IT administrators only need to configure a single setting within the Android App Protection Policy in Microsoft Intune.

**User Impact:** Medium – Users may experience restrictions on backup behavior for work or school data within managed apps, especially if backup is blocked.

## Overview

In Microsoft Intune, administrators can control whether organizational data within managed apps on Android devices is allowed to be backed up to Android Backup Services. This setting is part of the **App Protection Policy (APP)** configuration for Android and is critical for protecting sensitive corporate data on both BYOD and corporate-enrolled devices.

The setting **“Backup org data to Android backup services”** offers two options:
- **Allow** – Enables backup of work or school data to Android Backup Services.
- **Block** – Prevents backup of organizational data, reducing the risk of data leakage through cloud-based backup mechanisms not controlled by the organization [1](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android).

Blocking backup aligns with the Zero Trust principle of **assume breach**, as it minimizes the risk of sensitive data being exposed through third-party backup services that may not meet enterprise compliance standards.

If this setting is not configured properly, there is a risk that corporate data could be unintentionally stored in personal cloud backups, potentially violating data protection policies or regulatory requirements.

## Reference

- [Android app protection policy settings - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)  
