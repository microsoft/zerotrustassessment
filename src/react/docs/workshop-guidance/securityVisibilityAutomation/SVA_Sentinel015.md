# Custom Data Ingestion and Transformation in Microsoft Sentinel

**Implementation Effort:** High  
This requires IT and Security Operations teams to design, configure, and maintain Data Collection Rules (DCRs), custom tables, and ingestion pipelines, often involving coordination across multiple data sources and tools.

**User Impact:** Low  
All actions are handled by administrators and engineers; end users are not impacted or required to take action.

## Overview

Custom data ingestion and transformation in Microsoft Sentinel allows organizations to bring in data from virtually any source and shape it before it’s stored in the Log Analytics workspace. This is achieved using **Data Collection Rules (DCRs)**, which define how data is collected, transformed, and routed. Transformations can filter, enrich, or mask data using **Kusto Query Language (KQL)** before it’s ingested. Sentinel supports ingestion through the **Logs Ingestion API**, **Logstash**, and other connectors, enabling full control over schema, formatting, and data flow.

This capability is essential for organizations with unique log formats or compliance needs, allowing them to normalize and secure data at the point of ingestion. If not implemented, organizations risk ingesting irrelevant, unstructured, or sensitive data, which can lead to increased costs, compliance violations, and reduced detection accuracy.

This aligns with the **Zero Trust principle of "Verify explicitly"**, as it ensures only validated, structured, and relevant data is ingested and used for threat detection and analytics.

## Reference

- [Custom data ingestion and transformation](https://learn.microsoft.com/en-us/azure/sentinel/data-transformation)

