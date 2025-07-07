# Apple Business Manager / Apple School Manager

**Last Updated:** May 2025  
**Implementation Effort:** Medium – Setting up integration with Apple Business Manager (ABM) or Apple School Manager (ASM) requires coordination between Intune and Apple portals, token management, and device assignment workflows.  
**User Impact:** Low – End users are not directly involved in the setup or maintenance; devices are pre-configured before reaching users.

## Introduction

Apple Business Manager (ABM) and Apple School Manager (ASM) are Apple’s web-based portals for managing device assignments and enabling Automated Device Enrollment (ADE). Integrating ABM/ASM with Intune is essential for establishing a secure, scalable, and Zero Trust-aligned provisioning process for macOS devices.

This guidance applies to both new deployments and organizations that have already integrated ABM/ASM and want to evaluate their setup through a Zero Trust lens.

## Why This Matters

- **Enables zero-touch provisioning** for corporate macOS devices via ADE.
- **Ensures device supervision**, which unlocks additional management capabilities.
- **Prevents device removal from management**, reducing the risk of unmanaged endpoints.
- **Supports Zero Trust** by enforcing enrollment and configuration at the hardware level.
- **Simplifies lifecycle management** by automating device assignment and enrollment.

## Key Considerations

### ABM/ASM Integration with Intune

- Link ABM or ASM to Intune by uploading the MDM server token in the Intune admin center.
- Assign devices to the Intune MDM server in ABM/ASM to enable ADE.
- Renew the MDM server token annually to maintain connectivity.

This integration ensures that only devices acquired through trusted channels are eligible for enrollment, establishing a hardware-rooted trust foundation.

### Device Assignment

- Devices purchased through Apple or authorized resellers can be automatically added to ABM/ASM.
- Assign devices to the correct MDM server before they are powered on to ensure zero-touch enrollment.
- Use serial numbers or order numbers to manually add devices if needed.
- For existing environments, audit device assignments to confirm all corporate devices are properly scoped and enrolled.

### Enrollment Profiles
- Create and assign enrollment profiles in Intune to define the Setup Assistant experience.
- Configure profiles to:
  - Skip unnecessary setup screens.
  - Enforce MDM enrollment (non-removable).
  - Assign default configuration and compliance policies.
- Use different profiles for BYOD and corporate devices if needed.
- Profiles can also be scoped based on device role (e.g., kiosk, developer, standard user) to ensure that only the necessary configurations are applied, supporting least privilege access.

### Supervision and Security

- Devices enrolled via ADE are automatically supervised.
- Supervision enables additional restrictions (e.g., blocking system preferences, enforcing FileVault).
- Prevents users from removing MDM management from System Settings.
- Supervision also allows for tighter control over system-level settings and extensions, reducing the attack surface on managed macOS devices.

### Operational Best Practices

- Use a dedicated Apple ID for ABM/ASM administration.
- Document and restrict access to ABM/ASM to authorized personnel.
- Regularly audit device assignments and enrollment profile mappings to ensure they reflect current device roles and risk levels.

## Zero Trust Considerations

- **Verify explicitly**: ABM/ASM ensures that only trusted, corporate-owned devices are enrolled and evaluated.
- **Assume breach**: Supervision and enforced MDM enrollment reduce the risk of tampering or unmanaged access.
- **Least privilege**: Enrollment profiles can be scoped to apply only the necessary configurations based on device type or role.
- **Hardware-rooted trust**: Devices must originate from trusted sources to be eligible for management.
- **Continuous trust**: Devices remain under management throughout their lifecycle, supporting ongoing compliance and access control.

## Recommendations

- **Integrate ABM or ASM with Intune** early in your deployment to enable secure, automated enrollment.
- **Assign devices to the Intune MDM server** before deployment to ensure zero-touch provisioning.
- **Use enrollment profiles** to enforce supervision, skip unnecessary setup steps, and apply default policies.
- **Renew the MDM server token annually** to maintain ABM/ASM connectivity.
- **Audit device assignments and profile mappings regularly** to ensure alignment with your provisioning and Zero Trust strategy.
- **Restrict ABM/ASM access** and use a dedicated Apple ID for administrative tasks.
- **For existing environments**, review whether all corporate devices are assigned and enrolled via ADE, and adjust profile scoping to reflect current risk levels and device roles.

## References

- [Set up ABM/ASM with Intune](https://learn.microsoft.com/en-us/mem/intune/enrollment/apple-business-manager-enrollment)  
- [Create and Assign Enrollment Profiles](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enrollment-profile)  
- [Apple Business Manager](https://business.apple.com)  
- [Apple School Manager](https://school.apple.com)
