# Turn on Auditing and Health Monitoring in Microsoft Sentinel

**Implementation Effort:** Low — This feature requires administrators to enable built-in monitoring and auditing settings in Microsoft Sentinel, which is a targeted configuration task with minimal ongoing resource needs.

**User Impact:** Low — This action is performed entirely by administrators; end users are not affected or required to take any action.

## Overview

Enabling auditing and health monitoring in Microsoft Sentinel allows security teams to track the operational health of their Sentinel environment and audit key activities such as rule changes, data connector status, and ingestion health. This helps ensure that Sentinel is functioning as expected and that any issues are detected early. It also provides visibility into who made changes and when, which is essential for compliance and forensic investigations.

This capability supports the **"Assume Breach"** principle of Zero Trust by ensuring continuous visibility into the security operations platform itself. Without this monitoring, organizations risk missing critical failures in data ingestion, rule execution, or unauthorized changes, which could delay detection of threats or lead to compliance gaps.

## Reference

- [Monitor health and audit logs in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/enable-monitoring)
