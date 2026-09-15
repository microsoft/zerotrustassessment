Microsoft Defender Antivirus policy can be weakened when local administrator settings merge with centrally managed settings, especially exclusions and other list preferences. Microsoft Learn documents the Intune Antivirus setting Defender local admin merge, backed by the Defender CSP Configuration/DisableLocalAdminMerge, and states that selecting Yes means only management-defined items are used in the resulting effective policy. This matters because threat actors who gain local administrator rights can try to evade defense by adding exclusions for malware paths, tools, or processes instead of turning Defender Antivirus off. If local merge remains allowed, that defense-evasion step can reduce scanning while execution, credential access, lateral movement, and impact continue. Microsoft also states that DisableLocalAdminMerge must be enabled for tamper protection to protect antivirus exclusions from being merged with local settings. This control does not replace tamper protection, least privilege, or monitoring for suspicious exclusions, and emergency local changes may need a managed exception process. The check reads Intune Endpoint Security Antivirus Settings Catalog policies for the defender_disablelocaladminmerge / DisableLocalAdminMerge setting.

## Remediation action

- [Windows Antivirus policy settings for Microsoft Defender Antivirus for Intune](https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/ref-antivirus-defender-settings-windows)
- [Manage antivirus settings with endpoint security policies in Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-configuration/endpoint-security/antivirus)
- [Defender CSP — Configuration/DisableLocalAdminMerge](https://learn.microsoft.com/en-us/windows/client-management/mdm/defender-csp#configurationdisablelocaladminmerge)
- [Manage tamper protection for your organization using Microsoft Intune](https://learn.microsoft.com/en-us/defender-endpoint/manage-tamper-protection-intune)

<!--- Results --->
%TestResult%
