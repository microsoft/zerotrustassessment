# Configure Interactive and Long-Term Data Retention in Microsoft Sentinel

**Implementation Effort:** Medium  
Setting up data retention requires IT and Security Operations teams to define policies per table or across multiple tables, and coordinate with compliance and cost management stakeholders.

**User Impact:** Low  
This configuration is handled by administrators and does not require action or awareness from end users.

## Overview

This feature allows organizations to manage how long data is retained in Microsoft Sentinel by configuring **interactive** (frequently accessed) and **long-term** (archived) retention policies. Interactive retention keeps data readily available for active investigation, while long-term retention stores older data at a lower cost for compliance or historical analysis. You can configure retention per table or across multiple tables in your Log Analytics workspace.

Failing to configure appropriate retention settings can lead to increased storage costs, loss of critical historical data, or non-compliance with regulatory requirements. This capability supports the **"Assume Breach"** principle of Zero Trust by ensuring historical data is available for extended threat hunting and forensic analysis, even long after an incident occurs.

## Reference

- [Configure interactive and long-term data retention in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/configure-data-retention-archive)  
- [Log retention plans in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/log-plans)  
- [Manage data retention in a Log Analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-retention-configure)
