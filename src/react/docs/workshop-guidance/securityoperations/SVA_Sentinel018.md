# View and Manage SOC Optimization Recommendations in Microsoft Sentinel

**Implementation Effort:** Medium  
SOC optimization requires project-level coordination to onboard Microsoft Sentinel to the Defender portal, assign roles, and regularly review and act on recommendations.

**User Impact:** Low  
All actions are handled by SOC administrators or security engineers; end users are not impacted or required to take action.

## Overview

SOC Optimization Recommendations in Microsoft Sentinel help security teams improve the efficiency and effectiveness of their operations. These recommendations are tailored to your environment and are based on your current data coverage and threat landscape. They guide SOC teams on how to reduce unnecessary data ingestion (which can lower costs), close coverage gaps, and enhance threat detection capabilities. The recommendations are automatically generated and continuously updated, reducing the need for manual analysis.

You can access these recommendations via the **SOC Optimization** page in either the Azure portal or the Microsoft Defender portal. Metrics on the overview tab provide insights into how well your data is being used and how your optimization posture evolves over time.

Failing to implement these recommendations may result in higher operational costs, missed threat detections, and inefficient use of Microsoft Sentinel’s capabilities.

This feature supports the **Zero Trust principle of "Assume Breach"** by helping organizations continuously improve their detection and response posture, ensuring that gaps are identified and addressed proactively.

## Reference

- [Optimize security operations | Microsoft Learn](https://learn.microsoft.com/en-us/azure/sentinel/soc-optimization/soc-optimization-access)  
- [SOC optimization reference | Microsoft Learn](https://learn.microsoft.com/en-us/azure/sentinel/soc-optimization/soc-optimization-reference)
