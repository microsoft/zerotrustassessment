# Recheck Access Requirement

**Implementation Effort:** Low  
This setting is configured within existing Intune App Protection Policies and does not require infrastructure changes or device enrollment.

**User Impact:** Low  
Reauthentication happens in the background or during app use and does not require user training or significant behavior change.

## Overview

The **Recheck Access Requirement** setting in Microsoft Intune App Protection Policies (APP) defines how frequently users must reauthenticate to continue accessing corporate data. Admins can configure this interval in minutes, prompting users to re-enter their app PIN or corporate credentials after a defined period of app usage or inactivity.

This setting is available for both iOS/iPadOS and Android platforms and is part of the broader access requirements configuration. It ensures that even if a device is left unattended or compromised, access to corporate data is not persistent without revalidation.

This feature supports the **Zero Trust principle of "Verify Explicitly"** by enforcing periodic reauthentication based on time, reducing the risk of unauthorized access due to session hijacking or unattended devices.

## Reference

- [Understand app protection access requirements using Microsoft Intune](https://learn.microsoft.com/en-us/microsoft-365/solutions/apps-protect-access-requirements?view=o365-worldwide)
- [App protection policies overview - Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)
