# Set Microsoft Defender Antivirus to Active Mode

**Implementation Effort:** Medium – This requires IT or Security Operations teams to configure Group Policy, Microsoft Intune, or other management tools to enforce Defender Antivirus as the primary AV solution.

**User Impact:** High – A large number of users may experience changes in system behavior, such as new threat notifications, performance impacts during scans, or removal of previously installed third-party antivirus software.

## Overview

Setting Microsoft Defender Antivirus to **active mode** ensures it functions as the primary antivirus solution on a device. In this mode, Defender actively scans files, remediates threats, and reports detections to the Windows Security app and Microsoft Defender for Endpoint (if integrated). This is essential for organizations that rely on Microsoft’s native security stack or want to ensure consistent threat protection across endpoints.

Active mode is automatically enabled if no other antivirus solution is installed. However, if a third-party antivirus is present, Defender may switch to **passive** or **disabled** mode. To enforce active mode, administrators must ensure no conflicting AV is installed and configure policies via Group Policy, Intune, or Configuration Manager.

Failing to set Defender to active mode can leave endpoints unprotected or inconsistently monitored, especially in hybrid environments. This configuration supports the **Zero Trust principle of "Assume Breach"** by ensuring continuous, real-time threat detection and remediation.

## Reference

- [Microsoft Defender Antivirus in Windows Overview](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-windows)
- [Microsoft Defender Antivirus compatibility with other security products](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility)  
