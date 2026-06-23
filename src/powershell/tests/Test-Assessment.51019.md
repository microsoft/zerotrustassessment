Mobile Application Management (MAM) app protection policies protect corporate data inside managed apps even when the device itself is not enrolled. If protected apps can remain open indefinitely without rechecking access requirements, a lost, shared, or unattended mobile device can continue exposing corporate data through already-open apps and cached sessions. Enforcing a short app access recheck window requires the app to re-evaluate access requirements after the configured period, such as app PIN, biometric-backed app PIN, or organizational credentials. This reduces the window in which an attacker can use an unattended app session to read, copy, or exfiltrate corporate data.

This check verifies that Intune App Protection Policies for both Android and iOS/iPadOS are assigned and require access requirements to be rechecked within 30 minutes while the device is online.

**Remediation action**

- [Create and assign app protection policies](https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-policy)
- [Data protection framework using app protection policies](https://learn.microsoft.com/en-us/mem/intune/apps/app-protection-framework)
- [Android managed app protection resource type](https://learn.microsoft.com/en-us/graph/api/resources/intune-mam-androidmanagedappprotection?view=graph-rest-1.0)
- [iOS managed app protection resource type](https://learn.microsoft.com/en-us/graph/api/resources/intune-mam-iosmanagedappprotection?view=graph-rest-1.0)

<!--- Results --->
%TestResult%
