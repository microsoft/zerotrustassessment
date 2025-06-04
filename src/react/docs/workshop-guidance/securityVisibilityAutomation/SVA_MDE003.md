# Identify your architecture and select a deployment method for Defender for Endpoint

**Implementation Effort:** Medium  
This task requires IT and Security Operations teams to assess their current infrastructure, choose an appropriate architecture (cloud-native, co-managed, on-premises, or evaluation/local), and align deployment tools accordingly—this is a project-level effort involving planning and coordination.

**User Impact:** Low  
The deployment method selection and architecture identification are handled by administrators; end users are not directly impacted or required to take action during this phase.

## Overview

This step in deploying Microsoft Defender for Endpoint focuses on two key decisions: identifying your organization's architecture and selecting the appropriate deployment method. Microsoft provides four architecture models:

- **Cloud-native**: Ideal for organizations using Microsoft Intune and looking to minimize on-premises infrastructure.
- **Co-management**: Suitable for hybrid environments using both Microsoft Intune and Configuration Manager.
- **On-premises**: For organizations heavily invested in Configuration Manager or Active Directory.
- **Evaluation/local onboarding**: Best for small-scale pilots or environments without centralized management tools.

Once the architecture is selected, deployment tools such as Microsoft Intune, Configuration Manager, or local scripts are chosen based on the endpoint types and management capabilities.

This activity supports the **Zero Trust principle of "Assume Breach"** by ensuring that endpoint protection is deployed consistently across all environments, reducing the risk of unmanaged or misconfigured devices becoming attack vectors. Skipping this step can lead to inconsistent protection coverage, unmanaged endpoints, and gaps in visibility and control.

## Reference

- [Identify your architecture and select a deployment method for Defender for Endpoint](https://learn.microsoft.com/en-us/defender-endpoint/deployment-strategy)  


