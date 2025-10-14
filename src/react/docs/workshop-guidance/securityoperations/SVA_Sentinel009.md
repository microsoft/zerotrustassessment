
# Configure Interactive and Long-Term Data Retention in Microsoft Sentinel

**Implementation Effort:** Medium – Customer IT and Security Operations teams need to drive configuration projects across multiple tables and connectors, including optional onboarding to the data lake.

**User Impact:** Low – All actions are performed by administrators; end users are not affected or required to take action.

## Overview
Microsoft Sentinel allows organizations to configure data retention across two tiers: the **analytics tier** for interactive use (real-time alerting, hunting, dashboards) and the **data lake tier** for long-term, low-cost storage (up to 12 years). This setup helps balance performance, cost, and compliance needs. Administrators can manage retention settings per table, switch tiers, and use connectors to mirror or isolate data. If not configured properly, organizations risk losing valuable historical data or incurring unnecessary costs. This capability supports the Zero Trust principle of **Assume breach** by enabling deep visibility and long-term threat detection through scalable analytics and secure data storage.

## Reference
- [Configure interactive and long-term data retention in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/configure-data-retention-archive)
- [Manage data tiers and retention in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/manage-data-overview)
- [Configure table settings in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/manage-table-tiers-retention)
- [Log retention tiers in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/log-plans)
- [Set up connectors for the Microsoft Sentinel data lake](https://learn.microsoft.com/en-us/azure/sentinel/datalake/sentinel-lake-connectors)
- [Manage data retention in a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-retention-configure)
- [Connect Data Sources to Microsoft Sentinel Using Data Connectors](https://learn.microsoft.com/en-us/azure/sentinel/configure-data-connector)
- [Microsoft Sentinel data lake overview](https://learn.microsoft.com/en-us/azure/sentinel/datalake/sentinel-lake-overview)
- [Onboarding to Microsoft Sentinel data lake](https://learn.microsoft.com/en-us/azure/sentinel/datalake/sentinel-lake-onboarding)
