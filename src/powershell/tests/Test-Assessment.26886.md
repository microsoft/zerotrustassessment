When Azure DDoS Protection is enabled for public IP addresses, diagnostic logging provides critical visibility into attack patterns, mitigation actions, and traffic flow data. Without diagnostic logs enabled, security teams lack the observability needed to understand attack characteristics, validate mitigation effectiveness, and perform post-incident analysis. Azure DDoS Protection generates three categories of diagnostic logs: DDoSProtectionNotifications (alerts when attacks are detected and when mitigation starts/stops), DDoSMitigationFlowLogs (detailed flow-level information during active attack mitigation), and DDoSMitigationReports (comprehensive attack summaries with traffic statistics and mitigation actions). These logs are essential for security operations to detect ongoing attacks, investigate incidents, meet compliance requirements, and tune protection policies. The absence of logging prevents correlation of network events with other security telemetry, eliminating the ability to construct attack timelines during incident investigations. Furthermore, compliance frameworks such as PCI-DSS, HIPAA, and SOC 2 require organizations to maintain audit logs of network security events, and the lack of DDoS diagnostic logging creates audit failures.

**Remediation action**

Configure diagnostic settings for DDoS-protected public IP addresses
- [Configure Azure DDoS Protection diagnostic logging](https://learn.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging)

View and configure DDoS diagnostic logs in the Azure portal
- [View and configure DDoS diagnostic logging](https://learn.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging#configure-ddos-diagnostic-logs)

Create a Log Analytics workspace for storing DDoS Protection logs
- [Create a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/quick-create-workspace)

Monitor and analyze DDoS attack telemetry
- [Azure DDoS Protection monitoring and logging](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview#monitoring-and-logging)

View and analyze DDoS logs for incident investigation
- [Tutorial: View and analyze DDoS logs](https://learn.microsoft.com/en-us/azure/ddos-protection/view-logs)

<!--- Results --->
%TestResult%
