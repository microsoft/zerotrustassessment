# Scripts

**Implementation Effort:** Medium
**User Impact:** Low — scripts generally run silently, but bad scripts can create visible device issues quickly.

## Overview
Shell scripts remain important in macOS management because some controls still require custom automation beyond standard Intune settings. They should be treated as privileged code: minimized, version-controlled, tested, and used only where native Intune configuration or supported app packaging cannot meet the requirement cleanly.

## Implementation Guidance
1. Start with a control decision: use settings catalog, a configuration profile, an app deployment, or a script only when the other options cannot meet the need.
2. Write scripts to be idempotent and safe to rerun, with logging, exit codes, and guardrails so support teams can understand outcomes.
3. In the Microsoft Intune admin center, scope scripts narrowly to device groups and pilot on representative hardware and macOS versions.
4. Assume scripts may run with high privilege and review them accordingly; ban embedded secrets and require peer review for sensitive changes.
5. Retire scripts when the required setting becomes natively available in Intune or Apple declarative management.

## Reference
- **[Use Shell Scripts on macOS Devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-management/tools/run-shell-scripts-macos)** — Explains how to deploy and run shell scripts on managed macOS devices.
- **[Create a policy using settings catalog in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/settings-catalog/)** — Describes creating and assigning settings catalog profiles in Intune.
- **[Add custom settings to Apple devices in Microsoft Intune - Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/templates/configure-custom-settings-apple)** — Covers using custom profiles to configure Apple device settings, including macOS, in Intune.
