Organizations with large volumes of historical content in SharePoint, OneDrive, and Exchange that predates auto-labeling policy implementation lack visibility into the extent of unclassified sensitive data across their tenants. Auto-labeling policies only classify new and modified content going forward; existing files and emails remain unclassified and invisible to data loss prevention policies that depend on label detection. Without on-demand scans, organizations cannot perform a baseline assessment of sensitive information already present in their environments, making it impossible to quantify compliance risk, plan remediation, or validate that DLP controls are effectively protecting all sensitive data. On-demand scans allow organizations to manually trigger sensitive information type detection across specified SharePoint sites, OneDrive accounts, and Exchange mailboxes, identifying where sensitive data exists and enabling targeted classification through retroactive labeling. Configuring at least one on-demand scan enables organizations to discover and classify historical sensitive data, providing a comprehensive view of their information protection posture beyond the forward-looking coverage of auto-labeling policies and creating a complete baseline for compliance and risk management.

**Remediation action**

To configure on-demand scans for sensitive information discovery and classification, follow these steps:
1. **Plan your scan strategy** by identifying locations with historical sensitive data (finance, HR, legal departments) that predate auto-labeling policies.
2. **Access the scan creation interface** in the Microsoft Purview Portal: Information Protection > Classifiers > On-demand classification OR Data Loss Prevention > Classifiers > On-demand classification.
3.  **Select target locations** (specific SharePoint sites, OneDrive accounts, and/or Exchange mailboxes) and **choose sensitive information types to detect** (credit card numbers, SSNs, healthcare identifiers, trade secrets).
4. **Configure scan settings** including confidence thresholds (lower = more matches but higher false positives; higher = fewer false positives but may miss data) and file type filters. For trainable classifiers, ensure high-quality training data.
5. **Schedule or run the scan** immediately for baseline scans or set recurring schedules (daily/weekly/monthly). Note: Large scans can take days or weeks depending on data volume and may impact resource utilization.
6. **Monitor progress and analyze results** by tracking completion in the Microsoft Purview Portal. Upon completion, identify sensitive data locations, review prevalence by type, and determine remediation actions.

- [On-demand classification in Microsoft Purview](https://learn.microsoft.com/en-us/purview/on-demand-classification) 
- [Sensitive information types entity reference](https://learn.microsoft.com/en-us/purview/sensitive-information-type-entity-definitions)

<!--- Results --->
%TestResult%
