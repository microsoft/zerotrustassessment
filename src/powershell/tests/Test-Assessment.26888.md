Azure Application Gateway Web Application Firewall (WAF) protects web applications from common exploits and vulnerabilities such as SQL injection, cross-site scripting, and other OWASP Top 10 threats. When diagnostic logging is not enabled, security operations teams lose visibility into blocked attacks, rule matches, access patterns, and firewall events. A threat actor attempting to exploit web application vulnerabilities would go undetected because no WAF logs are being captured or analyzed. The absence of logging prevents correlation of WAF events with other security telemetry, eliminating the ability to construct attack timelines during incident investigations. Furthermore, compliance frameworks such as PCI-DSS, HIPAA, and SOC 2 require organizations to maintain audit logs of web application security events, and the lack of WAF diagnostic logging creates audit failures. Azure Application Gateway WAF provides multiple log categories including Application Gateway Access Logs, Performance Logs, and Firewall Logs, all of which must be routed to a destination such as Log Analytics, Storage Account, or Event Hub to enable security monitoring and forensic analysis.

**Remediation action**

Create a Log Analytics workspace for storing Application Gateway WAF logs
- [Create a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/quick-create-workspace)

Configure diagnostic settings for Application Gateway to enable log collection
- [Create diagnostic settings in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/create-diagnostic-settings)

Enable WAF logging to capture firewall events and rule matches
- [Application Gateway WAF logs and metrics](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-metrics)

Monitor Application Gateway using diagnostic logs and metrics
- [Monitor Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-diagnostics)

Use Azure Monitor Workbooks for visualizing and analyzing WAF logs
- [Azure Monitor Workbooks](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview)

<!--- Results --->
%TestResult%
