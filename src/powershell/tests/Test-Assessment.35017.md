When sensitivity label policies do not have default labels configured, users must actively choose a label for every document, email, site, or content item they create or modify. This increases user friction and can lead to inconsistent labeling practices across the organization. Default labels provide a baseline classification that can be overridden by users when necessary, reducing decision fatigue and ensuring that content has at least a minimum level of classification by default. When default labels are not configured, unclassified content may bypass DLP policies that rely on label detection, and organizations lose the ability to enforce consistent labeling baselines across different workloads and user groups. Different workloads (Outlook for emails, Teams/OneDrive for files, SharePoint for sites and groups, and Power BI for analytics) should each have appropriate default labels configured to ensure consistent baseline classification. Configuring default labels for sensitivity label policies reduces user friction, improves classification consistency, and ensures that even non-engaged users contribute to the organization's data governance objectives.

**Remediation action**

1. Navigate to Sensitivity label policies in Microsoft Purview
    - [Sensitivity label policies](https://purview.microsoft.com/informationprotection/labelpolicies)
2. Create or update a policy to configure default labels for target workloads
3. Set default labels for documents, emails, SharePoint sites, and Power BI
4. Define policy scope (global or specific groups)
5. Test with pilot users before organization-wide rollout

**Learn More:**
- [Apply a default label to all documents in a site](https://learn.microsoft.com/en-us/purview/sensitivity-labels-sharepoint-default-label)
<!--- Results --->
%TestResult%
