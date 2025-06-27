# SafetyNet / Hardware Backed Key

**Implementation Effort:** Low  
This setting is available as a built-in option in Android app protection policies and can be enabled with minimal configuration.

**User Impact:** Low  
Users are not impacted unless their device fails the integrity check, in which case access to corporate data is silently blocked or wiped.

## Overview

**SafetyNet** and **Hardware Backed Key** are Android security features used in Microsoft Intune App Protection Policies (APP) to verify the integrity of a device before allowing access to corporate data. SafetyNet provides a software-based attestation, while the **Hardware Backed Key** option enhances this by using a hardware-based evaluation to detect more advanced rooting methods that software checks may miss.

When enabled, Intune uses these checks to determine whether a device has been tampered with or compromised. If the device fails the attestation, Intune can automatically block access to corporate data or wipe it from the app. This is especially important in BYOD scenarios where devices are not enrolled in Intune but still need to meet security standards.

This feature supports the **Zero Trust principle of "Assume Breach"** by enforcing strong, hardware-level verification of device integrity before granting access to sensitive organizational resources.

## Reference

- [Data protection framework using app protection policies - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-framework)
- [App protection policies overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)
