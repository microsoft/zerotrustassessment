Data Collection Rules (DCRs) are the Azure Monitor primitive that defines what telemetry is collected, how it is parsed and transformed (KQL ingestion-time transforms), and which workspace and table it lands in. Without DCRs, ingestion is uncontrolled: agents collect default Windows Event Log channels and Syslog facilities verbatim, every line is sent to the workspace at the Analytics tier price, and there is no opportunity to filter informational noise, redact sensitive fields, drop high-volume low-value events, or split records between Analytics, Basic, and Auxiliary plans. The security consequences are twofold. First, runaway ingestion drives the customer to lower retention or disable connectors to manage cost — both of which directly degrade detection coverage, so threat actor activity that depends on long-tail telemetry becomes invisible. Second, the absence of ingestion-time transforms means PII, secrets in command lines, and other sensitive payloads land in the workspace where they widen blast radius if a workspace reader account is compromised. DCRs paired with Azure Monitor Agent (AMA) are the documented modern path for collecting Windows Security events, Syslog, CEF, custom text logs, and Logs-Ingestion-API telemetry into Sentinel workspaces. The check confirms at least one data collection rule targets each Sentinel-onboarded workspace and flags rules that have no ingestion-time transform configured.

**Remediation action**

- [Data collection rules in Azure Monitor](https://learn.microsoft.com/azure/azure-monitor/essentials/data-collection-rule-overview)
- [Collect Windows Security Events with the Azure Monitor agent](https://learn.microsoft.com/azure/sentinel/connect-windows-security-events)
- [Ingestion-time transformations in Azure Monitor](https://learn.microsoft.com/azure/azure-monitor/essentials/data-collection-transformations)

<!--- Results --->
%TestResult%
