Auditing and health monitoring populates the SentinelAudit and SentinelHealth tables in the Sentinel workspace and is the documented mechanism for detecting two classes of failure: detection-pipeline degradation (a data connector that has stopped ingesting, an analytics rule whose query is failing, an automation rule that is unable to trigger its playbook, a playbook that is throwing errors) and SOC tampering (a threat actor or insider modifying or disabling analytics rules, automation rules, or data connectors to blind the SIEM). The risk of operating Sentinel without health and audit enabled is direct: a connector silently drops, the relevant analytics rules produce no results, the SOC believes the absence of alerts means absence of threats, and the threat actor's persistence and lateral-movement activity completes undetected during the outage. The audit risk is also direct: a Microsoft Sentinel Contributor whose account is taken over can disable rules or modify their KQL to exclude the IPs they are operating from (defense evasion, Impair Defenses), and only the audit table records the change with actor identity, timestamp, before/after content. Auditing and health monitoring is enabled by configuring an Azure Monitor diagnostic setting on the Microsoft Sentinel solution that streams the Sentinel log categories to the same workspace (or another workspace), and the same diagnostic setting can be authored through the Sentinel Settings > Auditing and health monitoring UI. The check confirms a diagnostic setting exists for the Sentinel solution that includes the documented Sentinel categories.

**Remediation action**

- [Turn on auditing and health monitoring for Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/enable-monitoring)
- [Auditing and health monitoring in Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/health-audit)
- [SentinelHealth table reference](https://learn.microsoft.com/azure/sentinel/health-table-reference)
- [SentinelAudit table reference](https://learn.microsoft.com/azure/sentinel/audit-table-reference)

<!--- Results --->
%TestResult%
