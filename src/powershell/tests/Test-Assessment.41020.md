Microsoft Defender for Identity sensor deployment is not a one-time event: domain controllers are added and decommissioned, network adapter configurations change, certificates rotate, group memberships of the gMSA service account drift, and Microsoft Entra Connect is upgraded. A weekly review of the Health Issues page is the documented operational practice that catches these regressions before they create coverage gaps. When the review is skipped, accumulating health issues silently disable detection paths that the security operations team relies on to identify adversary activity across monitored domain controllers and network segments. The risk is not limited to the individual sensor that reports the issue: when a domain controller loses coverage, every authentication and directory operation that transits that controller becomes invisible to the platform, and an attacker who identifies the blind spot can stage activity there with reduced risk of detection. A regular review cadence ensures that health issues are triaged and resolved before they compound into broad coverage gaps that undermine the organization's investment in the platform.

**Remediation action**

- [Microsoft Defender for Identity health issues](https://learn.microsoft.com/en-us/defender-for-identity/health-alerts)
- [Troubleshoot Microsoft Defender for Identity known issues](https://learn.microsoft.com/en-us/defender-for-identity/troubleshooting-known-issues)
- [Microsoft Defender for Identity sensor settings](https://learn.microsoft.com/en-us/defender-for-identity/sensor-settings)

<!--- Results --->
%TestResult%
