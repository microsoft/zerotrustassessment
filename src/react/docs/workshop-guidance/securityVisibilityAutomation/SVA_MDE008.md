# Enable EDR in Block Mode

**Implementation Effort:** Medium – While the feature is enabled through a simple configuration, it often requires coordination with security teams to validate compatibility with existing antivirus solutions and ensure proper monitoring is in place.

**User Impact:** Low – The change is transparent to end users and does not require them to take any action or be notified.

## Overview

**EDR in block mode** is a feature in Microsoft Defender for Endpoint that allows Defender Antivirus to take action on threats detected by Endpoint Detection and Response (EDR), even when Defender Antivirus is not the primary antivirus. This is especially useful in environments where Defender is running in passive mode alongside a third-party antivirus.

When enabled, EDR in block mode automatically blocks or remediates threats based on behavioral detections, helping to contain attacks that may have bypassed the primary antivirus. It strengthens post-breach defense by ensuring that threats are addressed even if the initial detection was missed.

If not enabled, organizations risk leaving gaps in their endpoint protection, especially in hybrid AV environments. This can lead to persistent threats and increased risk of lateral movement or data compromise.

This feature supports the **Zero Trust principle of "Assume Breach"** by ensuring continuous threat response, even in passive AV configurations.

## Reference

- [Endpoint detection and response in block mode – Microsoft Learn](https://learn.microsoft.com/en-us/defender-endpoint/edr-in-block-mode)
- [EDR in block mode FAQs – Microsoft Learn](https://learn.microsoft.com/en-us/defender-endpoint/edr-block-mode-faqs)
