Microsoft Entra ID Protection generates risk signals for both user accounts and workload identities (service principals). For AI workloads, the workload identity signals are especially important — they detect unusual authentication patterns and suspicious API activity by the service principals that run as AI agents. This check verifies that both user and workload identity risk event categories are enabled on the Entra ID data connector and flowing to the Sentinel workspace.

When Identity Protection risk events are not flowing to Sentinel, the workspace has no risk dimension for the agent service principals that authenticate to AI endpoints. Threat actors who steal or replicate a service principal credential can exploit this gap because their anomalous sign-in and API activity never reaches the SIEM as a risk signal. Without these events, the organization cannot correlate a high-risk service principal identity with the downstream AI workload access that follows it.

**Remediation action**

- [Connect Microsoft Entra ID Protection to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/data-connectors/microsoft-entra-id-protection)
- [Integrate Microsoft Entra logs with Azure Monitor logs](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs)
- [Microsoft Entra ID Protection risk policies](https://learn.microsoft.com/entra/id-protection/concept-identity-protection-risks)

<!--- Results --->
%TestResult%
