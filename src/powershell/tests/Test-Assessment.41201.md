Microsoft first-party data connectors (Microsoft Entra ID sign-in and audit logs, Microsoft Defender XDR, Microsoft 365 Defender, Microsoft Defender for Cloud, Office 365 activity, Microsoft Defender for Cloud Apps, Microsoft Threat Intelligence, Azure Activity, and similar) are the highest-fidelity telemetry sources Sentinel can consume because they emit normalized, signed, identity-tagged events directly from the Microsoft control plane with no agent translation. Without these connectors, Sentinel has no visibility into the very platform the customer pays Microsoft to operate: a threat actor performing password spray, MFA fatigue, or token-replay against Microsoft Entra ID generates Entra sign-in events that never reach the workspace and therefore never trigger any built-in analytics rule, fusion correlation, or UEBA baseline. The same gap applies to Microsoft Defender XDR alerts (Defender for Endpoint malware detonations, Defender for Identity DCSync alerts, Defender for Office 365 phish detonation, Defender for Cloud Apps anomalous OAuth grants), which would otherwise stream into Sentinel for cross-product correlation and incident creation. Configuring at least one Microsoft connector is the minimum viable detection surface; production deployments typically enable Microsoft Entra ID, Microsoft Defender XDR, Azure Activity, and Office 365 at a minimum.

**Remediation action**

- [Connect Microsoft service data sources](https://learn.microsoft.com/azure/sentinel/connect-azure-windows-microsoft-services)
- [Connect Microsoft Entra ID to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/connect-azure-active-directory)
- [Connect Microsoft Defender XDR to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/connect-microsoft-365-defender)
- [Connect Azure Activity to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/data-connectors/azure-activity)

<!--- Results --->
%TestResult%
