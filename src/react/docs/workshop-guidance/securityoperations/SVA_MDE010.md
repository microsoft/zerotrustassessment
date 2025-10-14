# Turn on Tamper Protection

**Implementation Effort:** **Low**- Turning on tamper protection is a targeted action that can be done via the Microsoft Defender portal, Intune, or directly on individual devices

**User Impact:** **Low** – The change is managed by administrators and does not require any action or notification to end users

## Overview

Tamper protection is a Microsoft Defender for Endpoint feature that prevents unauthorized changes to key security settings, such as real-time protection, antivirus configurations, and cloud-delivered protection. It helps block malware or attackers—even those with administrative privileges—from disabling security features during an attack.

To deploy tamper protection, organizations must ensure that Microsoft Defender Antivirus is active and that devices are managed through tools like Microsoft Intune or Configuration Manager. While the feature can be enabled with a few clicks, enterprise-wide rollout requires policy alignment, exception handling, and user education. Without tamper protection, attackers can silently disable endpoint defenses, increasing the risk of compromise and data loss.

This feature supports the **Zero Trust principle of "Assume Breach"** by ensuring that even if attackers gain access to a device, they cannot disable critical security controls.

## Reference

- [Protect security settings with tamper protection – Microsoft Learn](https://learn.microsoft.com/en-us/defender-endpoint/prevent-changes-to-security-settings-with-tamper-protection)
- [Manage tamper protection using Microsoft Defender portal](https://learn.microsoft.com/en-us/defender-endpoint/manage-tamper-protection-microsoft-365-defender)
- [Manage tamper protection using Microsoft Intune](https://learn.microsoft.com/en-us/defender-endpoint/manage-tamper-protection-intune)

