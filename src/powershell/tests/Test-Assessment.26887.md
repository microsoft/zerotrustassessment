Azure Firewall processes all inbound and outbound network traffic for protected workloads, making it a critical control point for network security monitoring. When diagnostic logging is not enabled, security operations teams lose visibility into traffic patterns, denied connection attempts, threat intelligence matches, and IDPS signature detections. A threat actor who gains initial access to an environment can move laterally through the network without detection because no firewall logs are being captured or analyzed. The absence of logging prevents correlation of network events with other security telemetry, eliminating the ability to construct attack timelines during incident investigations. Furthermore, compliance frameworks such as PCI-DSS, HIPAA, and SOC 2 require organizations to maintain audit logs of network security events, and the lack of firewall diagnostic logging creates audit failures. Azure Firewall provides multiple log categories including application rule logs, network rule logs, NAT rule logs, threat intelligence logs, IDPS signature logs, and DNS proxy logs, all of which must be routed to a destination such as Log Analytics, Storage Account, or Event Hub to enable security monitoring and forensic analysis.

**Remediation action**

Create a Log Analytics workspace for storing Azure Firewall logs
- [Create a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/quick-create-workspace)

Configure diagnostic settings for Azure Firewall to enable log collection
- [Create diagnostic settings in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/create-diagnostic-settings)

Enable structured logs (resource-specific mode) for improved query performance and cost optimization
- [Azure Firewall structured logs](https://learn.microsoft.com/en-us/azure/firewall/monitor-firewall#structured-azure-firewall-logs)

Use Azure Firewall Workbook for visualizing and analyzing firewall logs
- [Azure Firewall Workbook](https://learn.microsoft.com/en-us/azure/firewall/firewall-workbook)

Monitor Azure Firewall metrics and logs for security operations
- [Monitor Azure Firewall](https://learn.microsoft.com/en-us/azure/firewall/monitor-firewall)

<!--- Results --->
%TestResult%
