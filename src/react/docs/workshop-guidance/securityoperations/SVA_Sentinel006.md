# Connect your first-party data sources to Microsoft Sentinel using data connectors

**Implementation Effort:** Medium – This requires IT and Security Operations teams to install solutions from the Content Hub, configure connectors, and ensure prerequisites are met for each data source.

**User Impact:** Low – This is an administrative task; end users are not impacted or required to take action.

## Overview

Connecting first-party data sources to Microsoft Sentinel using data connectors allows organizations to ingest telemetry and logs from Microsoft services (like Microsoft Entra ID, Microsoft 365, Defender, etc.) into Microsoft Sentinel for centralized monitoring, detection, and response. This is done by installing relevant solutions from the **Content Hub** and enabling the appropriate **data connectors**. Each connector may have specific prerequisites, such as permissions or configurations, and once enabled, data begins streaming into Sentinel tables for analysis.

This activity supports the **"Assume Breach"** principle of Zero Trust by enabling visibility across environments, allowing for advanced threat detection, correlation, and hunting. Without this setup, organizations risk blind spots in their security monitoring, reducing their ability to detect and respond to threats effectively.

## Reference

- [Connect Data Sources to Microsoft Sentinel Using Data Connectors](https://learn.microsoft.com/en-us/azure/sentinel/configure-data-connector)  
- [Microsoft Sentinel Data Connectors Overview](https://learn.microsoft.com/en-us/azure/sentinel/connect-data-sources)  
- [Find Your Microsoft Sentinel Data Connector](https://learn.microsoft.com/en-us/azure/sentinel/data-connectors-reference)

