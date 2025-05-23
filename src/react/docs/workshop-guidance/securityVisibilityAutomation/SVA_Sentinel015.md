# Custom data ingestion and transformation in Microsoft Sentinel

**Implementation Effort:** High: Implementing DCRs requires configuring and managing data collection rules, which involves project-level efforts by IT and Security Operations teams.

**User Impact:** Low: Actions related to DCRs are primarily handled by administrators, and non-privileged users do not need to be notified.

## Overview
Data Collection Rules (DCRs) in Microsoft Sentinel allow administrators to control and manipulate data ingestion before it is stored in the Log Analytics workspace. This feature is used to filter, enrich, or mask data, ensuring that only relevant and secure information is ingested, aligning with the Zero Trust framework by minimizing exposure and enhancing data security.

## Reference
[Custom data ingestion and transformation in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/data-transformation)
