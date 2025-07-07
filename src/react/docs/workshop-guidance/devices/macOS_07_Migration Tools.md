# Migration Tool

**Last Updated:** May 2025  
**Implementation Effort:** Medium – The script requires customization, testing, and coordination between IT and security teams to align with existing macOS management and enrollment processes.  
**User Impact:** Low – The migration is handled by IT; users typically do not need to take action or may only need to restart or sign in post-migration.

## Introduction

Migrating macOS devices from a third-party MDM to Intune can be complex—especially when trying to preserve user data, minimize downtime, and avoid full device resets. Microsoft provides a community-supported macOS Migration Tool that helps streamline this process. The tool is designed to **remove the existing MDM profile**, **trigger Intune enrollment**, and **preserve the user’s local account and data**.

This section helps macOS administrators understand how to use the migration tool effectively and how it supports a Zero Trust-aligned migration strategy.

## Why This Matters

- **Avoids full device wipe** during MDM migration.
- **Preserves user data and local account**, reducing disruption.
- **Supports Zero Trust** by ensuring devices are re-enrolled and re-evaluated under new compliance policies.
- **Reduces IT overhead** by automating the transition process.
- **Improves user experience** by enabling in-place migration.

## Key Considerations

### Tool Overview

- The migration tool is a shell script hosted in Microsoft’s shell-intune-samples GitHub repository.
- It removes the existing MDM profile (if permitted), initiates Intune Company Portal enrollment, and optionally triggers a restart.
- It is designed to be **adaptable to any third-party MDM**, not just Jamf or Workspace ONE.

### Use Cases

- Migrate corporate-owned macOS devices from a legacy MDM to Intune.
- Standardize device management under a unified Microsoft 365 and Zero Trust architecture.
- Avoid the need for users to back up and restore their data manually.

### Benefits Over Full Reset

A full device wipe is disruptive, time-consuming, and often unnecessary.  
The migration tool enables **in-place re-enrollment**, preserving:

- User data  
- Local account  
- FileVault encryption state  

From a Zero Trust perspective: This allows devices to be **re-evaluated under new compliance and Conditional Access policies** without compromising user productivity.

### Deployment and Execution

- The script can be deployed via the existing MDM or run manually by IT or the user.
- It requires admin privileges to remove the existing MDM profile.
- Logging and user prompts can be customized to fit your environment.

### Security and Trust Implications

- Devices migrated using this tool must still go through **Intune compliance evaluation** and **Conditional Access enforcement**.
- From a Zero Trust perspective: Migration is not a trust shortcut—devices must meet all current policy requirements post-enrollment.

## Zero Trust Considerations

- **Verify explicitly**: Devices are re-enrolled and re-evaluated under Intune’s compliance and access policies.
- **Assume breach**: Migration does not bypass security controls—devices must meet current standards to regain access.
- **Least privilege**: The tool does not elevate user rights or bypass enrollment restrictions.
- **Continuous trust**: Devices are continuously monitored and must remain compliant after migration.
- **Operational resilience**: Enables secure, scalable migration without compromising user experience or data integrity.

## Recommendations

- **Use the migration tool** for in-place transitions from third-party MDMs to Intune.
- **Avoid full device wipes** unless absolutely necessary.
- **Customize the script** to match your environment and user experience goals.
- **Ensure post-migration compliance policies** are enforced immediately.
- **Communicate clearly with users** about what to expect during the migration.
- **Audit migrated devices** to confirm successful enrollment and policy application.

## References

- [macOS Migration Tool (GitHub)](https://github.com/microsoft/shell-intune-samples/blob/master/macOS/Tools/Migration/readme.md)  
- [Intune Enrollment Methods for macOS](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment)  
- [Intune Compliance Policies Overview](https://learn.microsoft.com/en-us/mem/intune/protect/compliance-policy-create)
