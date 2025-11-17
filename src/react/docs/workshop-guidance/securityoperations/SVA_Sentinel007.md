# Set up third-party data connectors in Microsoft Sentinel

**Implementation Effort:** Medium – Setting up third-party connectors typically requires IT or SecOps teams to configure ingestion pipelines using Syslog, CEF, REST APIs, or custom connectors, which involves moderate project work and coordination with external systems.

**User Impact:** Low – This setup is handled by administrators and security teams; end users are not affected or required to take action.

## Overview

Microsoft Sentinel allows integration of third-party data sources through built-in connectors or custom configurations. These connectors enable ingestion of security data from non-Microsoft products using methods like Syslog, Common Event Format (CEF), REST APIs, or custom-built connectors using Azure Functions or Logic Apps. This integration enhances threat detection and investigation by centralizing logs and telemetry from across the security ecosystem. If not implemented, organizations risk blind spots in their threat landscape, reducing visibility into potential breaches or anomalies. This activity supports the **"Assume breach"** principle of Zero Trust by ensuring comprehensive data collection for threat detection and response.

## Reference

- [Microsoft Sentinel data connectors](https://learn.microsoft.com/en-us/azure/sentinel/connect-data-sources)
- [Configure data connectors in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/configure-data-connector)
