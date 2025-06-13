
# MDM_03: Enrollment Restrictions for MDM for iOS and Android in Intune

**Implementation Effort:** Low  
IT admins only need to configure policies in the Intune admin center; no user-side deployment or ongoing maintenance is required.

**User Impact:** Low  
Users are not directly affected unless their device is blocked from enrollment due to policy restrictions.

---

## Overview

Enrollment restrictions in Microsoft Intune allow organizations to control which devices can enroll in MDM based on platform, OS version, manufacturer, and ownership type. These restrictions help enforce organizational standards and reduce risk from unsupported or non-compliant devices.

There are two main types of restrictions:

### 1. Device Platform Restrictions

These policies restrict enrollment based on:
- **Platform**: Android (Work Profile, Fully Managed), iOS/iPadOS, macOS, Windows
- **OS Version**: Minimum and maximum supported versions
- **Manufacturer**: Block or allow specific device brands
- **Ownership Type**: Block personally owned (BYOD) devices if needed

> Example: Block Android Device Administrator enrollments and allow only Android Enterprise Work Profile for BYOD users [1](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/enrollment-restrictions-set).

### 2. Device Limit Restrictions

These policies limit how many devices a user can enroll. The default range is **1 to 15 devices per user** [2](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/device-limit-intune-azure).

> Example: Limit users to 5 enrolled devices to reduce management overhead and potential abuse.

### Policy Behavior

- A **default policy** applies to all users unless overridden by a higher-priority custom policy.
- Restrictions are **not security features**; they are best-effort controls to prevent accidental or unsupported enrollments [1](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/enrollment-restrictions-set).

### Zero Trust Fit
This supports the **"Assume breach"** principle by reducing the attack surface—only known, supported, and policy-compliant devices can access corporate resources.

---

## Reference

- [Overview of enrollment restrictions - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/enrollment-restrictions-set)  
- [Create device platform restrictions](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/create-device-platform-restrictions)  
- [Understand Intune and Microsoft Entra device limit restrictions](https://learn.microsoft.com/en-us/intune/intune-service/enrollment/device-limit-intune-azure)
