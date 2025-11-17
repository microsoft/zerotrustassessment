# Integrate MDTI Feeds to Microsoft Sentinel

**Implementation Effort:** Medium  
This requires IT and security teams to configure data connectors, manage content from the Content Hub, and potentially purchase and manage premium API access.

**User Impact:** Low  
The integration is handled by administrators and does not require action or awareness from end users.

## Overview

Integrating Microsoft Defender Threat Intelligence (MDTI) with Microsoft Sentinel allows organizations to ingest high-fidelity indicators of compromise (IOCs) from both public and Microsoft-curated sources directly into their Sentinel workspace. This is done through the Defender Threat Intelligence data connectors, available in both standard and premium tiers. Once connected, the threat intelligence data becomes available for use in analytics rules, hunting queries, and dashboards, enhancing threat detection and response capabilities.

This integration supports the **"Assume Breach"** principle of Zero Trust by enabling proactive threat detection using real-time threat intelligence, helping security teams identify and respond to threats faster. If not implemented, organizations risk missing early indicators of compromise, reducing their ability to detect and mitigate threats effectively.

## Reference

- [Enable the Microsoft Defender Threat Intelligence data connector](https://learn.microsoft.com/en-us/azure/sentinel/connect-mdti-data-connector)  
- [Threat intelligence integration in Microsoft Sentinel](https://learn.microsoft.com/en-us/Azure/sentinel/threat-intelligence-integration)  
- [Use matching analytics to detect threats](https://learn.microsoft.com/en-us/azure/sentinel/use-matching-analytics-to-detect-threats)
