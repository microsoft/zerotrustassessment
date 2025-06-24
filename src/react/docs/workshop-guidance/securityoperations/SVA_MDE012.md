# Prevent users from locally modifying Microsoft Defender Antivirus policy settings

**Implementation Effort:** Low  
This setting is configured via Group Policy and does not require ongoing maintenance once deployed.

**User Impact:** Low  
End users are not notified or required to take any action; changes are enforced silently through policy.

## Overview

This configuration ensures that users cannot override Microsoft Defender Antivirus settings on their local devices. By default, when antivirus settings are deployed using Group Policy, local changes are blocked. However, administrators can explicitly configure override permissions for specific settings if needed (e.g., for security researchers). To enforce strict control, administrators should ensure all override policies are set to **Disabled**. This prevents users from using the Windows Security app, local Group Policy, or PowerShell to modify antivirus behavior.

This setting supports the **Zero Trust principle of "Use least privilege access"** by ensuring that only authorized administrators can change security configurations, reducing the risk of misconfiguration or intentional tampering by end users. If not implemented, users could weaken endpoint protection by disabling real-time scanning or cloud-delivered protection, increasing the risk of malware infections.

## Reference

- [Prevent or allow users to locally modify Microsoft Defender Antivirus policy settings – Microsoft Learn](https://learn.microsoft.com/en-us/defender-endpoint/configure-local-policy-overrides-microsoft-defender-antivirus)  
- [Configure Microsoft Defender Antivirus with Group Policy](https://learn.microsoft.com/en-us/defender-endpoint/use-group-policy-microsoft-defender-antivirus)  
- [Prevent users from seeing or interacting with Microsoft Defender Antivirus](https://learn.microsoft.com/en-us/defender-endpoint/prevent-end-user-interaction-microsoft-defender-antivirus)
