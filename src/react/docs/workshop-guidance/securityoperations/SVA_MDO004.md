# Set up Enhanced Filtering for Connectors (when using another email solution ahead of Defender for Office 365)

**Implementation Effort:** Medium – This setup requires coordination between email routing configurations, connector settings, and Defender for Office 365 policies, typically involving IT and Security teams.

**User Impact:** Low – This is a backend configuration; end users are not impacted or required to take action.

## Overview

Enhanced Filtering for Connectors (EFC) is a feature in Microsoft Defender for Office 365 that improves the accuracy of spoof detection and anti-phishing protection when your organization uses a third-party email gateway (like Proofpoint, Mimecast, etc.) before routing mail to Microsoft 365. Without EFC, Microsoft 365 may misinterpret the source of the email, leading to false positives or missed threats.

EFC works by allowing Microsoft 365 to inspect the original sender IP address from the message headers, even if the message was relayed through a third-party service. This is critical for maintaining accurate filtering and threat detection.

If EFC is not configured, Defender for Office 365 may incorrectly trust or distrust messages based on the IP of the third-party gateway, not the actual sender. This can reduce the effectiveness of anti-spam, anti-phishing, and spoof intelligence features.

This setup supports the **"Verify explicitly"** principle of Zero Trust by ensuring that email filtering decisions are based on accurate sender identity and metadata, not just the last-hop IP.

## Reference

- [Configure Enhanced Filtering for Connectors](https://learn.microsoft.com/en-us/Exchange/mail-flow-best-practices/use-connectors-to-configure-mail-flow/enhanced-filtering-for-connectors)
