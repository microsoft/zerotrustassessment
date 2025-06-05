# Normalize Microsoft Sentinel Data with the Advanced Security Information Model (ASIM)

**Implementation Effort:** Medium – This requires IT and security teams to configure and maintain ASIM parsers and schemas, and potentially refactor existing analytics rules and queries to align with normalized data models.

**User Impact:** Low – This change is handled entirely by security and IT teams; end users and analysts benefit from improved consistency but do not need to take action.

## Overview

The **Advanced Security Information Model (ASIM)** in Microsoft Sentinel is a normalization layer that standardizes data from diverse sources into a consistent schema. This allows security teams to write analytics rules, hunting queries, and workbooks that work across multiple data sources—such as firewalls, identity providers, and endpoint solutions—without needing to understand each source’s unique schema. ASIM uses **KQL-based parsers** to transform raw data into a normalized format at query time, aligning with the **Open Source Security Events Metadata (OSSEM)** model for predictable entity correlation.

By using ASIM, organizations can:
- Detect threats across hybrid and multi-cloud environments using **source-agnostic analytics**.
- Simplify query writing and reduce duplication of detection logic.
- Extend coverage to new data sources without rewriting content.

If ASIM is not implemented, organizations risk:
- Inconsistent detection coverage across data sources.
- Increased complexity in maintaining analytics rules.
- Slower incident response due to fragmented data views.

This capability strongly supports the **Zero Trust principle of "Assume Breach"** by enabling better visibility and correlation across diverse telemetry, which improves threat detection and investigation.

## Reference
- [Normalization and the Advanced Security Information Model (ASIM)](https://learn.microsoft.com/en-us/azure/sentinel/normalization)


