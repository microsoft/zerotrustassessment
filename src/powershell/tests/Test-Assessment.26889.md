Without diagnostic logging enabled for Azure Front Door WAF, security teams lose visibility into blocked attacks, rule matches, access patterns, and WAF events occurring at the network edge. Threat actors attempting to exploit web application vulnerabilities through SQL injection, cross-site scripting, or other OWASP Top 10 attacks would go undetected because no WAF logs are being captured or analyzed. The absence of logging prevents correlation of WAF events with other security telemetry, eliminating the ability to construct attack timelines during incident investigations. Furthermore, compliance frameworks such as PCI-DSS, HIPAA, and SOC 2 require organizations to maintain audit logs of web application security events, and the lack of WAF diagnostic logging creates audit failures. Azure Front Door WAF provides multiple log categories including Access Logs and WAF Logs, which must be routed to a destination such as Log Analytics, Storage Account, or Event Hub to enable security monitoring and forensic analysis.

**Remediation action**
- Configure diagnostic settings for Azure Front Door to enable WAF log collection
    - [Create diagnostic settings in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/create-diagnostic-settings)
- Enable WAF logging to capture firewall events and rule matches
    - [Azure Front Door WAF monitoring and logging](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-monitor)
- Create a Log Analytics workspace for storing and analyzing WAF logs
    - [Create a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/quick-create-workspace)
- Monitor Azure Front Door using diagnostic logs and metrics
    - [Monitor metrics and logs in Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-diagnostics)
<!--- Results --->
%TestResult%
