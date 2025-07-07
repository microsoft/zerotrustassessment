# Scripts

**Last Updated:** May 2025  
**Implementation Effort:** Medium – IT admins need to write, test, and deploy shell scripts, and ensure they are scoped correctly to device groups and executed securely.  
**User Impact:** Low – Scripts run silently in the background; users are not required to take action or be notified unless the script affects visible settings.

## Introduction

Scripts are a powerful tool for macOS administrators using Intune. They allow IT teams to automate configuration, enforce settings not natively exposed in Intune, and remediate issues at scale. Scripts are especially valuable in macOS environments where MDM capabilities may be limited compared to other platforms. From a Zero Trust perspective, scripts help enforce **device integrity**, **configuration consistency**, and **least privilege** by automating secure baselines.

## Why This Matters

- **Extends Intune’s native capabilities** for macOS management.
- **Automates secure configuration** and remediation tasks.
- **Supports Zero Trust** by enforcing consistent, policy-driven device states.
- **Reduces manual intervention** and human error.
- **Improves visibility and control** over device posture.

## Key Considerations

### Supported Script Types

- Intune supports **shell scripts** for macOS devices.
- Scripts can be written in `sh`, `bash`, or `zsh`, as long as the appropriate shebang (e.g., `#!/bin/bash`, `#!/usr/bin/env zsh`) is included and the shell is available on the device.
- **Scripts are executed by the Intune Management Agent**, which is **automatically installed** on macOS devices during Intune enrollment.

From a Zero Trust perspective: Scripts allow enforcement of **custom security controls** that align with organizational policy.

### Common Use Cases

- Demote local admin accounts to standard users.
- Create or manage hidden IT admin accounts.
- Enforce system settings not available in the Intune UI (e.g., disabling Siri, configuring login window text).
- Rotate FileVault recovery keys and re-escrow them to Intune.
- Audit or remove unauthorized apps.

From a Zero Trust perspective: These use cases support **least privilege**, **device hardening**, and **continuous trust enforcement**.

### Assignment and Targeting

- Scripts can be assigned to **device groups**.
- Use **dynamic groups** to target based on OS version, ownership, or compliance state.

From a Zero Trust perspective: Targeting ensures that scripts are applied **only where needed**, reducing risk and maintaining control.

### Execution Behavior

- Scripts run as **root** by default and execute once per device unless configured otherwise.
- You can configure retry behavior and output logging.

From a Zero Trust perspective: Running as root requires **strict control and auditing** to avoid privilege misuse.

### Monitoring and Logging

- Script output is available in the **Intune admin center** for each device.
- Use logs to verify execution success or troubleshoot failures.

From a Zero Trust perspective: Logging supports **auditable enforcement** and **posture validation**.

### Security Best Practices

- Always **review and test scripts** before deployment.
- Avoid hardcoding credentials or sensitive data.
- Store scripts securely and maintain version control.

From a Zero Trust perspective: Scripts must be treated as **privileged automation** and managed with the same rigor as other security controls.

## Zero Trust Considerations

- **Verify explicitly**: Scripts enforce device configurations that can be validated and monitored.
- **Assume breach**: Scripts help remediate misconfigurations and enforce secure baselines.
- **Least privilege**: Scripts can remove unnecessary admin rights and enforce role-based access.
- **Continuous trust**: Scripts can be used to reapply or validate settings over time.
- **Defense in depth**: Scripts complement compliance policies, configuration profiles, and Conditional Access.

## Recommendations

- **Use scripts to extend Intune’s capabilities** for macOS where native settings are limited.
- **Automate security baselines** such as admin demotion, FileVault key rotation, and system hardening.
- **Target scripts carefully** using dynamic or static groups.
- **Monitor script execution** and review logs regularly.
- **Treat scripts as privileged tools**—review, test, and secure them accordingly.
- **Document and audit script usage** as part of your Zero Trust governance model.

## References

- [Use Shell Scripts on macOS with Intune](https://learn.microsoft.com/en-us/mem/intune/apps/macos-shell-scripts)  
- [Monitor Script Execution](https://learn.microsoft.com/en-us/mem/intune/apps/macos-shellults  
- [Assign Scripts Using Filters (not supported for shell scripts)](https://learn.microsoft.com/en-us/mem/intune/fundamentals/filters)
