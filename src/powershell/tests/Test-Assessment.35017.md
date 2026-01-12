When sensitivity label policies do not have default labels configured, users must actively choose a label for every document, email, site, or content item they create or modify. This increases user friction and can lead to inconsistent labeling practices across the organization. Default labels provide a baseline classification that can be overridden by users when necessary, reducing decision fatigue and ensuring that content has at least a minimum level of classification by default. When default labels are not configured, unclassified content may bypass DLP policies that rely on label detection, and organizations lose the ability to enforce consistent labeling baselines across different workloads and user groups. Different workloads (Outlook for emails, Teams/OneDrive for files, SharePoint for sites and groups, and Power BI for analytics) should each have appropriate default labels configured to ensure consistent baseline classification. Configuring default labels for sensitivity label policies reduces user friction, improves classification consistency, and ensures that even non-engaged users contribute to the organization's data governance objectives.

**Remediation action**

To implement default labels for sensitivity label policies:

1. Plan your default labeling strategy by reviewing and identifying which labels should serve as defaults for different workloads and user groups (global or department-specific).
    - [Plan for sensitivity labels](https://learn.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels#plan-for-sensitivity-labels)

2. Create or update label policies in the Microsoft Purview portal by navigating to Information Protection > Policies > Label publishing policies and configuring default label settings for each workload.
    - [Create and publish sensitivity labels](https://learn.microsoft.com/en-us/microsoft-365/compliance/create-sensitivity-labels).

3. Set default labels for documents and emails by configuring the default label during policy creation.
    - [Apply a default label to all documents in a site](https://learn.microsoft.com/en-us/purview/sensitivity-labels-sharepoint-default-label).

4. Configure Outlook-specific default labels by setting a particular default label for email communications if it differs from the general document default. This allows email to have its own baseline classification.

5. Set default labels for SharePoint sites and Microsoft 365 Groups to ensure users selecting a label when creating new sites or groups. This provides immediate classification for collaborative spaces.

6. Configure default labels for Power BI content to establish baseline classification for analytics dashboards, reports, and datasets before publication.

7. Apply the policy to target users or groups, starting with a pilot group to validate the default label experience, then expanding organization-wide.
    - [Plan your sensitivity label solution](https://learn.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels#plan-for-sensitivity-labels).

Best practices:
- Choose a commonly-used, easily-understood label as the default (e.g., "Internal" or "General")
- Ensure the default label is permissive enough that users will not immediately override it for legitimate cases
- Consider different defaults for different user groups or departments based on their data sensitivity profiles
- Verify that default labels are appropriately mapped across all four workloads for consistency
- Monitor adoption and default label application.
    - [Monitor label usage](https://learn.microsoft.com/en-us/purview/sensitivity-labels-usage)
- Default labels should not prevent users from selecting more restrictive labels when appropriate

<!--- Results --->
%TestResult%
