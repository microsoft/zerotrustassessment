When App Protection Policies (MAM) do not block managed-app access on jailbroken or rooted devices, the entire MAM data-protection model is compromised. A jailbroken iPhone or rooted Android device has broken the OS sandbox — the user, or any malware running with elevated privileges, can read every other app's data including cached corporate email attachments, OneDrive working copies, Teams chat history, copy-paste buffers, and encryption keys stored in the system keychain. Every other MAM control the organisation depends on (cut/copy/paste restrictions, "save to org locations only", per-app encryption, conditional launch checks) silently fails on these devices because they all assume the OS sandbox is intact. Threat actors who compromise such a device — or users who deliberately root their personal device to bypass IT controls — gain a clean exfiltration path for corporate data with no signal back to the tenant, because the device is not MDM-enrolled and produces no Intune compliance telemetry.

iOS and Android expose different conditional-launch APIs for jailbreak/root detection, so this check evaluates the two platforms asymmetrically:

- **iOS / iPadOS**: There is no dedicated jailbreak property on `iosManagedAppProtection`. Jailbreak detection is performed internally by the Intune MAM SDK and surfaces as a `deviceComplianceRequired` trigger. The check therefore requires `deviceComplianceRequired` = `true` AND `appActionIfDeviceComplianceRequired` ∈ {`block`, `wipe`}.
- **Android**: `androidManagedAppProtection` exposes dedicated SafetyNet / Play Integrity properties. Simply setting `appActionIfAndroidSafetyNetDeviceAttestationFailed` to `block` is not sufficient on its own — if `requiredAndroidSafetyNetDeviceAttestationType` is `none`, no attestation is requested at app launch and the "block" action never fires. The check therefore requires BOTH `requiredAndroidSafetyNetDeviceAttestationType` ∈ {`basicIntegrity`, `basicIntegrityAndDeviceCertification`} AND `appActionIfAndroidSafetyNetDeviceAttestationFailed` ∈ {`block`, `wipe`}.

Without these settings, jailbroken / rooted personal devices remain free conduits for corporate data exfiltration.

## Remediation resources

- [App protection policies overview](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy)
- [iOS app protection policy settings: Conditional launch](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-ios)
- [Android app protection policy settings: Conditional launch](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android)
- [Create and assign app protection policies](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policies)
- [Android device integrity: Play Integrity API](https://learn.microsoft.com/en-us/intune/intune-service/apps/app-protection-policy-settings-android#conditional-launch)

<!--- Results --->
%TestResult%
