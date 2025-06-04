# Design log analytics workspace architecture

**Implementation Effort:** Medium This effort score was chosen because designing a Log Analytics workspace architecture requires customer IT and Security Operations teams to drive projects that involve evaluating multiple criteria and configuring workspaces accordingly.

**User Impact:** Low: This ranking was chosen because the actions required to design and implement the workspace architecture can be taken by administrators without needing to notify or involve non-privileged users.

## Overview
[![Watch the video](https://img.youtube.com/vi/7RBp9j0P_Ao/hqdefault.jpg)](https://www.youtube.com/embed/7RBp9j0P_Ao)

Designing a Log Analytics workspace for Microsoft Sentinel involves choosing between a single or multiple workspace architecture based on operational, security, and cost considerations. A single workspace simplifies management and querying, while multiple workspaces may be needed for regulatory compliance, data sovereignty, or cost optimization. Key design criteria include data ownership, Azure region placement, tenant boundaries, and whether to combine or separate operational and security data.

If not properly designed, organizations may face challenges such as increased data egress costs, fragmented visibility across security data, or non-compliance with data residency requirements. This design activity supports the **Zero Trust principle of "Assume Breach"** by enabling better segmentation and visibility into security data, which is critical for threat detection and response.



## Reference
[Sample Log Analytics workspace designs for Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/sample-workspace-designs)

[Enhance resilience by replicating your Log Analytics workspace across regions – Microsoft Learn](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/workspace-replication)
