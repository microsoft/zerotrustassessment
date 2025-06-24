# Set up Microsoft Sentinel Workbooks

**Implementation Effort:** Medium  
Setting up Microsoft Sentinel Workbooks requires IT teams to configure data sources, install templates or solutions from the Content Hub, and optionally customize dashboards, which involves a project-level effort.

**User Impact:** Low  
Workbooks are primarily used by security analysts and administrators; end users are not affected or required to take action.

---

## Overview

Microsoft Sentinel Workbooks are interactive dashboards that help visualize and monitor security data collected from connected sources. These workbooks are built on Azure Monitor Workbooks and allow teams to use prebuilt templates or create custom visualizations using Kusto Query Language (KQL). Workbooks can be installed from the Content Hub or created from scratch, and they support role-based access control (RBAC) to manage visibility and editing rights.

They are essential for threat detection, investigation, and response workflows, enabling security teams to gain insights into incidents, alerts, and data trends. If not set up, organizations risk reduced visibility into security telemetry, slower incident response, and missed threat indicators.

This setup supports the **"Assume Breach"** principle of Zero Trust by enabling continuous monitoring and visibility into potential threats across the environment.

---

## Reference

- [Visualize your data using workbooks in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/monitor-your-data)  
- [Create Workbooks for Microsoft Sentinel Solutions](https://learn.microsoft.com/en-us/azure/sentinel/sentinel-workbook-creation)  
- [Commonly used Microsoft Sentinel workbooks](https://learn.microsoft.com/en-us/azure/sentinel/top-workbooks)

