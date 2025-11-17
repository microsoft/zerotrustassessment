# Understand Sentinel Security Coverage by the MITRE ATT&CK® Framework

**Implementation Effort:** Medium  
Microsoft Sentinel requires configuration of data connectors, scheduled query rules, and permissions to enable MITRE ATT&CK coverage visualization.

**User Impact:** Low  
This feature is used by security administrators and analysts; end users are not impacted or required to take action.

## Overview

Microsoft Sentinel integrates with the MITRE ATT&CK® framework to help security teams understand how well their environment is covered against known adversary tactics and techniques. The MITRE ATT&CK framework is a globally accessible knowledge base of adversary behavior, and Sentinel maps its analytics rules (detections) to this framework. Through the MITRE page in Sentinel (currently in preview), security teams can visualize which techniques are actively being monitored, which are covered by available but inactive rules, and which are not covered at all.

This capability supports the **"Assume Breach"** principle of Zero Trust by helping organizations identify gaps in detection coverage and proactively improve their threat detection posture. Without this visibility, organizations risk blind spots in their security monitoring, leaving them vulnerable to undetected attacks.

## Reference
- [View MITRE coverage for your organization from Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/mitre-coverage)  
