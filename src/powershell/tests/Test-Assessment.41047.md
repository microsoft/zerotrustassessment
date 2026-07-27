Microsoft Defender Antivirus is the next-generation antimalware engine on Windows that performs signature, heuristic, behavioral, and cloud-delivered scanning of files, processes, and scripts. The engine operates in one of three modes: active, where it provides full real-time protection and automated remediation; passive, where it scans but does not remediate because a third-party antivirus product is primary; and disabled. When the engine is not in active mode and no equivalent third-party product is enforcing, the local execution-prevention layer is absent: a threat actor who delivers a payload can run malicious code, harvest credentials, and encrypt files without any on-device control intervening to quarantine or block the activity. Active mode is also the prerequisite for several downstream platform capabilities including real-time cloud protection, behavioral blocking, EDR in block mode, and attack surface reduction enforcement. Disabling it therefore degrades not just the antivirus layer but every control that depends on the engine being present, creating a compounding gap that extends well beyond the individual endpoint.

**Remediation action**

- [Turn on Microsoft Defender Antivirus](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-windows)
- [Microsoft Defender Antivirus compatibility with other security products](https://learn.microsoft.com/en-us/defender-endpoint/microsoft-defender-antivirus-compatibility)
- [Manage Microsoft Defender Antivirus with Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/ref-antivirus-defender-settings-windows)

<!--- Results --->
%TestResult%
