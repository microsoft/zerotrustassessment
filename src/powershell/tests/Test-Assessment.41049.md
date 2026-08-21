The Microsoft Defender Antivirus and Windows Security app exposes user-facing controls that allow a local user to add exclusions, pause real-time protection, ignore detections, dismiss notifications, and modify scan behavior. When the UI is visible to standard end users, an adversary who delivers a payload can use social engineering to instruct the user to add an exclusion path, pause protection, or restore a quarantined file, effectively turning the end user into an unwitting accomplice in weakening the endpoint's defenses. The risk is amplified in environments where users have been conditioned to follow instructions from what appears to be technical support, because the Windows Security app presents its controls without requiring administrative credentials for several operations. Hiding the app ensures that antivirus configuration is administrator-only and removes the attack path that depends on user interaction with the security UI. Combined with Tamper Protection, this creates a layered defense where neither the user nor a malicious process can weaken endpoint protection without administrative authority managed through Microsoft Intune.

**Remediation action**

- [Windows Security experience (Antivirus) policy settings for Intune](https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/ref-security-experience-settings-windows)
- [WindowsDefenderSecurityCenter Policy CSP](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-windowsdefendersecuritycenter)
- [Manage endpoint security policies in Intune](https://learn.microsoft.com/en-us/mem/intune/protect/endpoint-security-policy)

<!--- Results --->

%TestResult%
