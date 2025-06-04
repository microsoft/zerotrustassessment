# Prioritize data connectors for Microsoft Sentinel

**Implementation Effort:** Medium: Customer IT and Security Operations teams need to drive projects to determine which data connectors are relevant and set up custom and partner connectors.

**User Impact:** Low: Action can be taken by administrators, users don’t have to be notified.

## Overview
Prioritizing data connectors in Microsoft Sentinel is a key step in planning an effective security information and event management (SIEM) deployment. The process involves identifying which data sources are most critical to your organization’s security posture and determining the order in which to onboard them. 

Microsoft recommends starting with free connectors to gain immediate value, followed by first party, third party, then custom and partner connectors—especially those using CEF/Syslog for Linux-based systems. This prioritization ensures that the most valuable and cost-effective data is ingested first, helping manage budget and performance. 

If not done, organizations risk ingesting low-value or redundant data, leading to unnecessary costs and reduced visibility into critical threats. This aligns with the Zero Trust principle of **"Assume breach"**, as it ensures visibility into the most relevant data sources to detect and respond to threats quickly.

## Reference
[Prioritize data connectors for Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/prioritize-data-connectors)
