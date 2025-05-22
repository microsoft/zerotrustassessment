# Prevent or allow users to locally modify Microsoft Defender Antivirus policy settings

**Implementation Effort:** Medium: Enabling local policy overrides requires IT and Security Operations teams to coordinate with specific user groups (e.g., researchers or analysts), define exceptions, and manage policy scope, which constitutes a project-level effort.

**User Impact:** Medium: A subset of non-privileged users—typically those in specialized roles—must be informed and trained on how to use the override capability responsibly.

## Overview

By default, Microsoft Defender Antivirus settings that are deployed via a Group Policy Object to the endpoints in your network will prevent users from locally changing the settings.
Local policy overrides allow specific users to modify Microsoft Defender Antivirus settings on their devices, even when centralized policies are in place.

## Reference
https://learn.microsoft.com/en-us/defender-endpoint/configure-local-policy-overrides-microsoft-defender-antivirus
