When sensitivity labels are not mandatory, users can send unclassified emails, share unclassified files and documents, create unclassified sites and groups, and publish unclassified Power BI content without applying appropriate protection labels. This creates a significant security and compliance risk because threat actors can easily exfiltrate sensitive data without any classification metadata to indicate its sensitivity level or trigger automated protection policies. Mandatory labeling must be configured across all workloads (Outlook for emails, Teams for teamwork, SharePoint/Microsoft 365 Groups for sites and groups, and Power BI for analytics content) to ensure comprehensive coverage. If data loss prevention (DLP) policies rely on label detection to identify and block sensitive content, unclassified data bypasses these controls entirely. Additionally, users may accidentally share confidential information without realizing it lacks proper protection, and organizations lose audit trail visibility into what data is being handled and how. Without mandatory labeling across all platforms, compliance frameworks such as GDPR, HIPAA, or industry-specific regulations cannot be effectively enforced because sensitive data remains unidentified. Organizations should implement at least one sensitivity label policy with mandatory labeling enabled across Outlook, Teams/Teamwork, SharePoint/Sites and Groups, and Power BI to ensure all communications, documents, and analytics content are classified before sharing, enabling both automated protection mechanisms and complete audit visibility.

**Remediation action**

1. Navigate to Sensitivity label policies in Microsoft Purview
   - [Sensitivity label policies](https://purview.microsoft.com/informationprotection/labelpolicies)
2. Create or update a policy to enable mandatory labeling for target workloads (Outlook, Teams, SharePoint, Power BI)
3. Enable specific settings:
   - "Require users to apply a label to their email" (Outlook)
   - "Require users to apply a label for Teams, groups, and SharePoint content" (collaboration)
   - Mandatory labeling for Power BI content
4. Set policy scope (global or specific groups)
5. Test with pilot users before organization-wide rollout

**Learn More:** 
- [Require users to apply a label](https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps#require-users-to-apply-a-label-to-their-email-and-documents)

<!--- Results --->
%TestResult%
