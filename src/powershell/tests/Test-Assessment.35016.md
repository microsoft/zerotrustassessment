When sensitivity labels are not mandatory, users can send unclassified emails, share unclassified files and documents, create unclassified sites and groups, and publish unclassified Power BI content without applying appropriate protection labels. This creates a significant security and compliance risk because threat actors can easily exfiltrate sensitive data without any classification metadata to indicate its sensitivity level or trigger automated protection policies. Mandatory labeling must be configured across all workloads (Outlook for emails, Teams for teamwork, SharePoint/Microsoft 365 Groups for sites and groups, and Power BI for analytics content) to ensure comprehensive coverage. If data loss prevention (DLP) policies rely on label detection to identify and block sensitive content, unclassified data bypasses these controls entirely. Additionally, users may accidentally share confidential information without realizing it lacks proper protection, and organizations lose audit trail visibility into what data is being handled and how. Without mandatory labeling across all platforms, compliance frameworks such as GDPR, HIPAA, or industry-specific regulations cannot be effectively enforced because sensitive data remains unidentified. Organizations should implement at least one sensitivity label policy with mandatory labeling enabled across Outlook, Teams/Teamwork, SharePoint/Sites and Groups, and Power BI to ensure all communications, documents, and analytics content are classified before sharing, enabling both automated protection mechanisms and complete audit visibility.

**Remediation action**

To implement mandatory labeling for sensitivity labels across all workloads:

1. Plan your mandatory labeling strategy by reviewing and identifying which user groups require mandatory labeling across emails, files, sites, groups, and Power BI content (global or department-specific).
   - [Plan for sensitivity labels](https://learn.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels#plan-for-sensitivity-labels)
2. Create or update label policies in the Microsoft Purview portal by navigating to Information Protection > Policies > Label publishing policies and enabling the appropriate mandatory labeling settings for each workload.
   - [Create and publish sensitivity labels](https://learn.microsoft.com/en-us/microsoft-365/compliance/create-sensitivity-labels)
3. Enable mandatory labeling for Outlook emails by configuring the "Require users to apply a label to their email" setting.
   - [Require users to apply a label](https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps#require-users-to-apply-a-label-to-their-email-and-documents)
4. Enable mandatory labeling for Teams, OneDrive, and SharePoint files by configuring the "Require users to apply a label for Teams, groups, and SharePoint content" setting in the label policy. This ensures users must label files when uploading to Teams and OneDrive, and when sharing via SharePoint.
5. Enable mandatory labeling for SharePoint sites and Microsoft 365 Groups by configuring the site/group creation policies to require default labels. Users must select a label when creating new sites or groups.
6. Enable mandatory labeling for Power BI by configuring the "Power BI mandatory labeling" setting in the label policy. This ensures Power BI content (dashboards, reports, datasets) requires labels before publication.
7. Deploy the policy to target users or groups, starting with a pilot group, then expanding organization-wide.
   - [Plan your sensitivity label solution](https://learn.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels#plan-for-sensitivity-labels)

Best practices:
- Start with a limited set of mandatory policies covering the most sensitive workloads, then expand incrementally
- Ensure consistency across all four workloads (Outlook, Teams/OneDrive, SharePoint/Groups, Power BI) for a unified experience
- Provide comprehensive user training before enforcement, covering each workload separately if needed
- [Monitor adoption using label usage](https://learn.microsoft.com/en-us/purview/sensitivity-labels-usage)
- Verify that `disablemandatoryinoutlook` is NOT enabled (should be false) unless intentionally exempting Outlook
- Consider integrating with DLP policies
  - [Create DLP policies based on labels](https://learn.microsoft.com/en-us/purview/dlp-use-labels-as-conditions)

<!--- Results --->
%TestResult%

```
