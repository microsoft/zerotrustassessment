Every enterprise has security-relevant log sources that no Microsoft- or partner-authored connector covers: bespoke line-of-business applications, internal authentication services, custom proxies, internally developed APIs, mainframe security exits, and homegrown SaaS. When these sources have no detection coverage, threat actor activity that touches them — credential reuse against an internal application, exploitation of a custom API, data staging from a homegrown SaaS prior to exfiltration — is silently absent from Sentinel's incident graph. Sentinel exposes three documented mechanisms for shipping these logs into the workspace and registering them as connectors: the Codeless Connector Framework (GenericUI / APIPolling kinds) for REST API sources, the Logs Ingestion API plus Data Collection Rules for arbitrary HTTP-shipped logs, and Logstash/Function App connectors. Building at least one custom connector is the documented best practice when an in-scope source has no existing connector — without it, the only alternative is to drop the source entirely (no detection) or run a parallel logging pipeline that bypasses the SIEM (no correlation). This check confirms that the Sentinel workspace contains at least one codeless connector whose publisher matches the customer's organization. Connectors published by another organization remain unresolved because the API does not distinguish partner-authored connectors from customer-authored connectors.

**Remediation action**

- [Create a codeless data connector for Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/create-codeless-connector)
- [Send data to Microsoft Sentinel using the Logs ingestion API](https://learn.microsoft.com/azure/azure-monitor/logs/logs-ingestion-api-overview)
- [Use Azure Functions to connect Microsoft Sentinel to your data source](https://learn.microsoft.com/azure/sentinel/connect-azure-functions-template)

<!--- Results --->
%TestResult%
