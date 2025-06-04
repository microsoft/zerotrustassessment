# Set up analytics rules in Microsoft Sentinel

**Implementation Effort:** Medium – Setting up analytics rules requires IT and security teams to design KQL queries, configure rule logic, and manage rule lifecycle, but it doesn’t require ongoing user involvement.

**User Impact:** Low – These rules are configured and managed by administrators; end users are not directly affected or required to take action.

## Overview

Analytics rules in Microsoft Sentinel are used to detect suspicious behavior and potential threats by analyzing data ingested from various sources. These rules can be created from templates or built from scratch using the Analytics Rule Wizard, which allows security teams to define custom logic using Kusto Query Language (KQL). Rules can trigger alerts and incidents based on specific patterns or anomalies in the data. This capability is essential for proactive threat detection and response.

If analytics rules are not set up, Sentinel will not generate alerts or incidents, significantly reducing its effectiveness as a SIEM/SOAR solution. This increases the risk of undetected threats and delayed responses.

This feature supports the **"Assume breach"** principle of Zero Trust by continuously monitoring for anomalies and enabling rapid detection and investigation of potential intrusions.

## Reference

- [Threat detection in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/threat-detection)

