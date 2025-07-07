# Await Configuration

**Last Updated:** May 2025  
**Implementation Effort:** Low – Admins only need to enable a setting in the automated device enrollment (ADE) profile in Intune.  
**User Impact:** Low – Users are temporarily held at the Setup Assistant screen, but no action is required from them.

---

## Introduction

The **Await Configuration** setting in Intune for macOS devices allows administrators to delay user access to the desktop until essential configurations—such as compliance policies, security settings, and required apps—have been applied. This feature is available for devices enrolled via **Automated Device Enrollment (ADE)** and helps ensure that devices are fully provisioned before users begin interacting with them.

This section helps administrators evaluate whether they are using Await Configuration effectively to support Zero Trust principles during the provisioning process.

---

## Why This Matters

- **Ensures devices are configured and compliant** before users can access them.  
- **Reduces risk** by preventing premature access to unmanaged or misconfigured devices.  
- **Supports Zero Trust** by enforcing policy application before trust is granted.  
- **Improves provisioning consistency** by ensuring baseline settings are applied at first login.  
- **Enhances user experience** by reducing post-enrollment configuration delays.  

---

## Key Considerations

### How It Works

- Await Configuration is available for **macOS devices enrolled via ADE**.  
- During Setup Assistant, the device pauses at the “awaiting final configuration” screen.  
- The user cannot proceed to the desktop until Intune confirms that required configurations have been applied.  

### What Is Applied During Await

- **Required** device configuration profiles (e.g., FileVault, password policies, certificates)  
- **Required** compliance policies  
- **Required** apps  
- Scripts and baseline settings  
- Network configurations (e.g., Wi-Fi, VPN)  

### Scoping Configuration

- Only **required apps and policies** assigned to the device at the time of enrollment are enforced during Await Configuration.  
- Use **Intune filters** or **dynamic groups** to scope only essential configurations to the Await phase.  
- Optional apps and post-enrollment configurations are applied after the user reaches the desktop.  

### Monitoring and Troubleshooting

- Await Configuration is enforced by **Apple Setup Assistant**, and Intune does not provide real-time visibility into this screen.  
- After enrollment completes, use the **Intune admin center** to:  
  - Review device compliance and configuration status.  
  - Confirm that required apps and policies were successfully applied.  
- For advanced troubleshooting, logs can be collected from the device post-enrollment.  

---

## Applicability

- Only available for **ADE-enrolled macOS devices**.  
- Not applicable to user-initiated or BYOD enrollment scenarios.  

---

## Zero Trust Considerations

- **Verify explicitly**: Await Configuration ensures that trust is not granted until the device meets defined security and compliance baselines.  
- **Assume breach**: Preventing access to the desktop until configuration is complete reduces the risk of exposure from misconfigured or non-compliant devices.  
- **Least privilege**: Users gain access only after the device is provisioned with the minimum required controls.  
- **Continuous trust**: This feature reinforces the principle that trust is established through policy enforcement—not assumed at enrollment.  

---

## Recommendations

- **Enable Await Configuration** for all ADE-enrolled macOS devices to enforce secure provisioning.  
- **Limit initial assignments** to essential policies and apps to streamline provisioning.  
- **Use filters or dynamic groups** to scope Await Configuration payloads appropriately.  
- **Monitor post-enrollment status** in the Intune admin center to confirm successful configuration.  
- **Communicate expectations to users** so they understand the purpose of the delay during setup.  

---

## References

- [Configure Await Configuration for macOS](https://learn.microsoft.com/en-us/mem/intune/enrollment/macos-automated-device-enrollment)  
- [ADE Setup Assistant Options](https://learn.microsoft.com/en-us/mem/intune/enrollment/device-enrollment-program-enrollment-profile)  
- [Monitor Device Enrollment and Provisioning](https://learn.microsoft.com/en-us/mem/intune/fundamentals/intune-monitoring)
