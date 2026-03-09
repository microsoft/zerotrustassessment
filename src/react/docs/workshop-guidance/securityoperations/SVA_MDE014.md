
# Enable Application Control

**Implementation Effort:** High: Requires ongoing management and monitoring by IT and Security Operations teams to ensure policies are correctly enforced and updated.

**User Impact:** Medium: A subset of non-privileged users may need to be informed about changes to application control policies, especially if their workflows are affected by new restrictions.

## Overview
Application Control in Microsoft Defender helps prevent malware and untrusted software from running by enforcing a policy that only allows approved code to execute. It works by creating a whitelist of trusted applications, scripts, and installers, and blocks everything else. Administrators can deploy policies in enforcement or audit mode using Configuration Manager or Group Policy. This capability is especially valuable in high-security environments where controlling executable behavior is critical. If not deployed, endpoints may run unauthorized or malicious code, increasing the risk of data breaches or system compromise. Application Control supports the **Assume breach** principle of Zero Trust by limiting the execution of unverified code and reducing the attack surface.

## Reference
[Windows Defender Application Control Deployment Guide](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defenderl-deployment-guide)
