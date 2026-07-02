Microsoft Defender for Cloud Apps includes anomaly detection policies that baseline each user's behavior and surface deviations such as impossible travel, activity from an infrequent country, activity performed by a terminated user, and unusual file download, share, or delete volume. When no anomaly detection policy is producing alerts, a threat actor who compromises a credential and exfiltrates from a software-as-a-service app operates in the same telemetry surface as the legitimate user, and the security team has no signal that the behavior is anomalous. This check confirms that anomaly detection is active and producing alerts so credential-based attacks against cloud apps surface in the incident queue rather than completing silently.

**Remediation action**

- [Get behavioral analytics and anomaly detection](https://learn.microsoft.com/en-us/defender-cloud-apps/anomaly-detection-policy)
- [Tune anomaly detection policies](https://learn.microsoft.com/en-us/defender-cloud-apps/anomaly-detection-policy#tune-anomaly-detection-policies)
- [Connect apps to get visibility and control](https://learn.microsoft.com/en-us/defender-cloud-apps/enable-instant-visibility-protection-and-governance-actions-for-your-apps)
- [Best practices for protecting your organization with Microsoft Defender for Cloud Apps](https://learn.microsoft.com/en-us/defender-cloud-apps/best-practices)

<!--- Results --->
%TestResult%
