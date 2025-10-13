# Prevent users from seeing or interacting with the Microsoft Defender Antivirus user interface


**Implementation Effort:** low: This feature can be enabled through targeted configuration changes using Group Policy or Intune, without requiring a broader program or ongoing resource commitment.

**User Impact:** Low: The feature is designed to operate in the background, enforcing security policies without disrupting or involving users in the process.

## Overview

This feature allows administrators to hide the Microsoft Defender Antivirus interface from users, including notifications and the Virus & threat protection tile in the Windows Security app. It can be configured using Group Policy by enabling "headless UI mode" or via PowerShell with `Set-MpPreference -UILockdown $true`. Preventing user interaction helps reduce the risk of users pausing scans, disabling protections, or misinterpreting security alerts. It also ensures that antivirus settings remain consistent and enforced across endpoints. If not deployed, users may inadvertently interfere with protection mechanisms, weakening the organization's security posture. This supports the **Assume breach** principle of Zero Trust by minimizing the chance of user-driven configuration changes that could be exploited during an attack.

## Reference
https://learn.microsoft.com/en-us/defender-endpoint/prevent-end-user-interaction-microsoft-defender-antivirus
