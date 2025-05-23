# Understand and plan Sentinel costs

**Implementation Effort:** High: Customer IT and Security Operations teams need to drive projects to understand and optimize costs using the pricing calculator and other methods.

**User Impact:** Low: Action can be taken by administrators, and users don’t have to be notified.

## Overview
Microsoft Sentinel is billed for the volume of data analyzed in Microsoft Sentinel and stored in Azure Monitor Log Analytics workspace. 
There are two competing aspects of log collection and retention that are critical to a successful threat detection program. On the one hand, you want to maximize the number of log sources that you collect, so that you have the most comprehensive security coverage possible. On the other hand, you need to minimize the costs incurred by the ingestion of all that data.
These competing needs require a log management strategy that balances data accessibility, query performance, and storage costs.
### Step 1: Categorize your data
Microsoft recommends classifying data ingested into Microsoft Sentinel into two general categories:

* [**Primary security data**](https://learn.microsoft.com/en-us/azure/sentinel/log-plans#primary-security-data) is data that contains critical security value. This data is used for real-time proactive monitoring, scheduled alerts, and analytics to detect security threats. The data needs to be readily available to all Microsoft Sentinel experiences in near real time.

* [**Secondary security data**](https://learn.microsoft.com/en-us/azure/sentinel/log-plans#secondary-security-data) is supplemental data, often in high-volume, verbose logs. This data is of limited security value, but it can provide added richness and context to detections and investigations, helping to draw the full picture of a security incident. It doesn't need to be readily available but should be accessible on-demand as needed and in appropriate doses.
### Step 2: Select your log management plans
Microsoft Sentinel provides two different log storage plans, or types, to accommodate these categories of ingested data.

* The **Analytics logs** plan is designed to store primary security data and make it easily and constantly accessible at high performance.

* The **Auxiliary logs** plan is designed to store secondary security data at very low cost for long periods of time, while still allowing for limited accessibility.

* A third plan, **Basic logs**, is the predecessor of the auxiliary logs plan, and can be used as a substitute for it while the auxiliary logs plan remains in preview.
### Step 3: Understand Retention
Each of these plans preserves data in two different states:

* The **interactive retention** state is the initial state into which the data is ingested. This state allows different levels of access to the data, depending on the plan, and costs for this state vary widely, depending on the plan.

* The **long-term retention** state preserves older data in its original tables for up to 12 years, at extremely low cost, regardless of the plan.



## Reference

* [Plan costs and understand Microsoft Sentinel pricing and billing](https://learn.microsoft.com/en-us/azure/sentinel/billing)
* [Manage and monitor costs for Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/billing-monitor-costs)
* Sign in to the [Azure pricing calculator](https://azure.microsoft.com/en-us/pricing/calculator/) to see pricing based on your current program/offer with Microsoft.

