SharePoint sites and OneDrive accounts are the primary repositories for unstructured file content in Microsoft 365, containing diverse document types, spreadsheets, presentations, and business intelligence files.

Without auto-labeling policies specifically targeting these locations, organizations cannot automatically classify files based on their content or sensitive information types, leaving sensitive data vulnerable. Files uploaded to SharePoint and OneDrive without automatic classification become invisible to data loss prevention (DLP) policies that rely on label detection, allowing sensitive information to circulate uncontrolled and potentially be shared externally or accessed by unauthorized users. Manual classification by users is inconsistent and unreliable due to user oversight, lack of awareness about what constitutes sensitive data, or time constraints in daily workflows.

Auto-labeling policies deployed in enforcement mode (not simulation) for SharePoint and OneDrive locations actively scan new and modified files, automatically applying sensitivity labels when the policy conditions are met. Implementing at least one auto-labeling policy in enforcement mode for these locations ensures that file-based sensitive data is consistently classified at the point of creation or modification, enabling downstream data protection controls like DLP rules, access restrictions, and audit logging to function effectively across the organization's file-sharing infrastructure.

**Remediation action**

**Remediation Steps:**
1. Navigate to [Auto-labeling policies](https://purview.microsoft.com/informationprotection/autolabeling) in Microsoft Purview
2. Assess existing policies targeting SharePoint/OneDrive
3. If policies exist in simulation mode, review statistics and transition to enforcement
4. If no policies exist for these workloads, create a new policy
5. Select SharePoint and/or OneDrive as target locations
6. Choose file-based sensitive information types
7. Select appropriate label and test in simulation mode
8. Activate enforcement mode after validation

**Best Practices:**
- Prioritize file-based sensitive data types (financial records, healthcare information, trade secrets) over email-specific types when targeting SharePoint/OneDrive
- Start with high-confidence SITs (credit card numbers, SSNs, bank account numbers) to minimize false positives in file content
- Test file-based policies thoroughly in simulation mode; false positives in files are more visible to end users than in email
- Combine SharePoint/OneDrive auto-labeling with DLP rules that detect the applied labels for additional file protection
- Monitor OneDrive auto-labeling separately from SharePoint—OneDrive policies have different scan schedules and may catch content before SharePoint
- Document the sensitive data types and business justification for each SharePoint/OneDrive policy to support audit and compliance reporting

**Learn More:**
- [Apply sensitivity labels automatically for SharePoint and OneDrive](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Sensitive information types entity reference](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Create and configure auto-labeling policies](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%
