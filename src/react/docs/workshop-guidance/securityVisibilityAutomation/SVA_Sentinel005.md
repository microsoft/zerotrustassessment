# Enable Microsoft Sentinel

**Implementation Effort:** Low  
This step involves enabling Microsoft Sentinel on an existing Log Analytics workspace, which is a straightforward administrative action.

**User Impact:** Low  
Only administrators are involved in this setup; no end-user interaction or notification is required.

## Overview

Enabling Microsoft Sentinel is the first step in deploying the cloud-native SIEM and SOAR solution in Azure. This action connects Sentinel to a Log Analytics workspace, allowing it to start collecting and analyzing security data. Administrators can do this via the Azure portal by selecting a workspace and enabling Sentinel on it. This setup is foundational—it doesn’t yet involve data connectors or analytics rules, but it prepares the environment for those next steps.

This activity supports the Zero Trust principle of **"Assume breach"** by laying the groundwork for continuous monitoring, threat detection, and incident response. Without enabling Sentinel, organizations miss out on centralized visibility and automated threat detection, increasing the risk of undetected breaches.

## Reference

- [Enable Microsoft Sentinel – Microsoft Learn](https://learn.microsoft.com/en-us/azure/sentinel/quickstart-onboard?tabs=defender-portal
