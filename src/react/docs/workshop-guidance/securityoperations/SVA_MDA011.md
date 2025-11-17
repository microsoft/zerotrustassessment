# Block download of sensitive information with conditional access app control

**Implementation Effort:** Medium: Customer IT and Security Operations teams need to implement programs that require ongoing time or resource commitment. This involves setting up and managing policies in Microsoft Defender for Cloud Apps and ensuring continuous monitoring and adjustments.

**User Impact:** High: A subset of non-privileged users have to take action or be notified of changes. Specifically, users accessing sensitive data from unmanaged devices will be affected by the new policies.

## Overview
This feature allows organizations to block downloads of sensitive information from enterprise cloud apps to unmanaged devices or from off-corporate network locations. It leverages Microsoft Entra ID Conditional Access policies and Microsoft Defender for Cloud Apps to monitor and control cloud app usage, ensuring sensitive data remains protected even when accessed remotely.

## Reference
[Block download of sensitive information with conditional access app control](https://learn.microsoft.com/en-us/defender-cloud-apps/use-case-proxy-block-session-aad)
