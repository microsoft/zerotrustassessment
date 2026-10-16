The Entra ID data connector brings identity logs from Microsoft Entra into Microsoft Sentinel. For AI workloads, this covers authentication activity for agent service principals and managed identities, permission changes to AI workload app registrations, and API access events. All available log categories should be enabled — a workspace with incomplete coverage has blind spots into how agent identities are behaving.

When the Entra ID data connector is not enabled, Sentinel has no record of how agent service principal identities are authenticating or what permission changes are being made to AI workload app registrations. Threat actors who steal agent service principal credentials can exploit this blind spot because their sign-in and audit activity exists only in the Entra portal, never reaching the SIEM where analytics rules and automated responses would fire. Without this connector, the organization cannot correlate a compromised agent identity's authentication with the API calls and data access that follow it.

 **Source:** [Send data to Microsoft Sentinel using the Microsoft Entra ID data connector](https://learn.microsoft.com/azure/sentinel/connect-azure-active-directory)

**Remediation action**

- [Connect Microsoft Entra ID to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/connect-azure-active-directory)
- [Integrate Microsoft Entra logs with Azure Monitor logs (creating this diagnostic setting auto-enables the Sentinel Entra ID data connector and the Content Hub solution)](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs)
- [Managed identity sign-in logs in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/monitoring-health/concept-managed-identity-sign-ins)

<!--- Results --->
%TestResult%
