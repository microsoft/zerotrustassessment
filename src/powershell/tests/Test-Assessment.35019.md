When auto-labeling policies are not configured, organizations cannot automatically classify content based on sensitive information types, patterns, or conditions. This creates a significant compliance and security gap because sensitive data relies entirely on manual user action for classification, which is inconsistent and error-prone. Users frequently miss classification opportunities due to time constraints, lack of awareness, or simple oversight, resulting in unclassified sensitive data throughout the organization.

Without auto-labeling, data loss prevention (DLP) policies that depend on label detection cannot effectively identify and protect sensitive content, leaving high-risk information vulnerable to unauthorized access or exfiltration. Auto-labeling policies intelligently classify content across all workloads (Outlook emails, Exchange mailboxes, SharePoint sites, OneDrive accounts, Teams channels, and Power BI) based on content inspection, sensitive information type detection, trainable classifiers, or custom conditions. Configuring at least one auto-labeling policy for the organization's most sensitive data types is the foundation for consistent automated classification; enforcement mode activation is a separate step validated by test 35020.

**Remediation action**

To configure auto-labeling policies:

1. Navigate to [Microsoft Purview portal > Information Protection > Auto-labeling](https://purview.microsoft.com/informationprotection/autolabeling)
2. Select "Create auto-labeling policy"
3. Choose the type of information to detect (e.g., Financial, Medical and health, Privacy, Custom)
4. Select specific sensitive information types or trainable classifiers to trigger labeling
5. Select target locations/workloads (Exchange, SharePoint, OneDrive, Teams, Power BI)
6. Choose the sensitivity label to automatically apply
7. Configure policy settings and decide whether to run in simulation mode initially
8. Test the policy in simulation mode for 1-2 weeks to validate accuracy
9. Review simulation results and activate enforcement when ready (validated in test 35020)

Best practices:
- Start with high-confidence, high-risk sensitive information types (credit card numbers, SSNs) before expanding
- Create separate policies for different data classifications to allow independent management
- Use simulation mode initially to validate detection accuracy and identify false positives
- Combine auto-labeling with DLP policies for additional protection
- Regularly review auto-labeling statistics to monitor effectiveness

- [Apply sensitivity labels automatically](https://learn.microsoft.com/purview/apply-sensitivity-label-automatically)
- [Create and configure auto-labeling policies](https://learn.microsoft.com/purview/apply-sensitivity-label-automatically)
- [Sensitive information types entity reference](https://learn.microsoft.com/purview/sensitive-information-type-entity-definitions)

<!--- Results --->
%TestResult%
