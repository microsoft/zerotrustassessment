Microsoft Defender Antivirus uses cloud protection, always-on scanning with file and process behavior monitoring and heuristics, and protection updates to detect and block threats. Microsoft defines always-on protection as real-time protection, behavior monitoring, and heuristics that identify malware from known suspicious and malicious activities, such as unusual process changes to files, autostart registry keys, startup locations, and other file-system or file-structure changes. Real-time protection scans files when users open, download, or use them, so disabling these controls reduces endpoint protection before suspicious or malicious activity can be identified locally. Tamper protection helps keep always-on protection and other security settings from being changed, but this check does not evaluate tamper protection. Microsoft Secure Score measures organizational security posture and includes recommendations for Microsoft Defender for Endpoint; this check reads Secure Score control profiles and the latest Secure Score snapshot for the spec-pinned MDATP IDs `scid_2012`, `scid_91`, `scid_92`, `scid_89`, `scid_90`, `scid_5093`, and `scid_6093`.

**Remediation action**

- [Configure behavioral, heuristic, and real-time protection](https://learn.microsoft.com/en-us/defender-endpoint/configure-protection-features-microsoft-defender-antivirus)
- [Enable and configure always-on protection](https://learn.microsoft.com/en-us/defender-endpoint/configure-real-time-protection-microsoft-defender-antivirus)
- [Use Microsoft Intune to manage Defender Antivirus settings](https://learn.microsoft.com/en-us/mem/intune/protect/antivirus-microsoft-defender-settings-windows)

<!--- Results --->
%TestResult%
