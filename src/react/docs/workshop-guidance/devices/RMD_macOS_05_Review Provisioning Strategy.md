# Review Provisioning Strategy

**Last Updated:** May 2025  
**Implementation Effort:** Medium – Reviewing and implementing a macOS provisioning strategy requires project-level planning, coordination across teams, and configuration of multiple enrollment and management components.  
**User Impact:** Medium – Depending on the chosen provisioning method (e.g., BYOD vs. corporate-owned), some users may need to follow enrollment steps or install the Company Portal manually.

## Introduction

Provisioning is the first step in establishing trust in a macOS device. Whether you're onboarding new corporate devices or enabling secure access for BYOD users, your provisioning strategy determines how devices are enrolled, configured, and made compliant. This section helps macOS administrators evaluate their provisioning approach using **native Intune macOS capabilities**, with a focus on Zero Trust alignment from the start.

This guidance applies to both new deployments and organizations that have already enrolled their macOS fleet and are now re-evaluating their provisioning strategy through a Zero Trust lens.

## Why This Matters

- **Establishes device trust** at the earliest stage of the lifecycle.
- **Reduces manual setup** and ensures consistent configuration across devices.
- **Improves compliance posture** by enforcing baseline policies during provisioning.
- **Supports Zero Trust** by ensuring only properly provisioned, compliant devices can access corporate resources.
- **Minimizes risk** by automating certificate deployment, security settings, and app installation.

## Key Considerations

### Enrollment Methods

- **Automated Device Enrollment (ADE)** via **Apple Business Manager (ABM)** or **Apple School Manager (ASM)** is the recommended method for corporate macOS devices.
  - Enables zero-touch provisioning and supervision.
  - Devices are automatically enrolled into Intune during Setup Assistant.
  - Supports enforcement of MDM enrollment and skips unnecessary setup screens.

- **User-initiated enrollment** is typically used for BYOD scenarios.
  - Requires users to manually enroll via the Company Portal.
  - Offers less control and does not support supervision.

### ABM/ASM Integration

- Ensure your organization is connected to ABM or ASM and that devices are assigned to the correct Intune MDM server.
- Use enrollment profiles to define the Setup Assistant experience and enforce MDM enrollment.
- Assign profiles based on device type, ownership, or user group.

### Initial Configuration

Use **device configuration profiles** to deploy:

- Security settings (e.g., FileVault, password policies)  
- Certificates (SCEP/PKCS)  
- Wi-Fi and VPN profiles  
- System preferences and restrictions  

Use **app deployment policies** to install required apps during provisioning.  
Apply **Intune compliance policies** immediately to enforce security baselines.

### Automation and Group Targeting

- **Dynamic Microsoft Entra groups** can be used to assign policies and apps based on device attributes (e.g., ownership, OS version, enrollment profile).  
  ⚠️ **Note**: Dynamic group membership updates can have **latency**, which may delay policy or app deployment during provisioning.

**Alternatives**:

- **Static groups** for known devices in pilot or lab environments.  
- **Enrollment profile-based targeting** to differentiate BYOD and corporate flows.  
- **Intune filters** to refine assignments based on device properties like ownership.

### Provisioning Validation

Regularly test provisioning flows to validate that:

- Devices receive the correct profiles and apps.  
- Compliance policies are enforced immediately.  
- Resource access (e.g., VPN, Wi-Fi) is functional post-enrollment.

### Reviewing Already-Enrolled Devices

- Audit how devices were enrolled (ADE vs. manual) and whether they received the correct configurations.
- Reassess **BYOD vs. corporate device strategy**: ensure BYOD devices are not over-permissioned.
- Use **filters** or **enrollment profiles** to apply differentiated controls and limit access to only what’s necessary.
- Consider **re-enrollment** for devices missing critical configurations or enrolled without supervision.
- Establish a **recurring review process** to ensure provisioning remains aligned with Zero Trust principles.

## Zero Trust Considerations

Provisioning is the foundation of Zero Trust for macOS:

- **Verify explicitly**: Devices are enrolled and evaluated for compliance before being granted access.
- **Assume breach**: Provisioning enforces security controls from the start, reducing exposure.
- **Least privilege**: Devices receive only the apps and configurations they need based on role and ownership.
- **Continuous trust evaluation**: Compliance policies and Conditional Access ensure that trust is maintained post-provisioning.

## Recommendations
- **Use ADE with ABM or ASM** for all corporate macOS devices to enable zero-touch, supervised enrollment.
- **Define separate provisioning flows** for BYOD and corporate devices to apply appropriate controls.
- **Automate initial configuration** using device configuration profiles, app deployments, and compliance policies.
- **Deploy certificates early** to support secure access to Wi-Fi, VPN, and internal services.
- **Use dynamic groups** for automation, but be aware of latency—consider filters or enrollment profile targeting for time-sensitive scenarios.
- **Audit already-enrolled devices** to ensure they meet current provisioning and compliance standards.
- **Re-enroll devices** where necessary to bring them up to Zero Trust expectations.
- **Establish a recurring review cycle** to ensure provisioning remains aligned with your Zero Trust strategy.

## References

- [Automated Device Enrollment for macOS](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enroll-macos)  
- [Apple Business Manager and Apple School Manager Integration](https://learn.microsoft.com/en-us/mem/intune/enrollment/apple-business-manager-enrollment)  
- [Configure Enrollment Profiles](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enrollment-profile)  
- [Create and Assign Configuration Profiles](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profile-create)  
- [Use Filters in Microsoft Intune](https://learn.microsoft.com/en-us/mem/intune/fundamentals/filters)
