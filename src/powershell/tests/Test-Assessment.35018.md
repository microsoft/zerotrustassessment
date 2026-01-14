When sensitivity label policies do not require users to provide justification when removing or downgrading labels, users can silently reduce the classification level of sensitive content without creating an audit trail explaining why. This creates a compliance and audit risk because organizations lose visibility into intentional label downgrades that may indicate inappropriate access to sensitive data. When a user removes a "Confidential" label and replaces it with "Internal" or no label at all, organizations should require explicit justification to create an audit record of this action. Downgrade justification is a lightweight control that increases accountability for label decisions without significantly impacting user workflows. When justification is not required, compromised user accounts or departing employees could systematically downgrade labels on sensitive documents to enable data exfiltration, leaving no clear audit trail of the unauthorized changes. Configuring downgrade justification requirements on sensitivity label policies ensures that any intentional reduction in classification level is logged with a user-provided business reason, supporting both compliance audits and insider threat investigations. Downgrade justification should be configured alongside other label controls (mandatory labeling, default labels, and mandatory enforcement) to create a comprehensive data governance framework.

**Remediation action**
1. Navigate to [Sensitivity label policies](https://purview.microsoft.com/informationprotection/labelpolicies) in Microsoft Purview
2. Create or update a policy to enable downgrade justification requirement
3. Enable: "Require users to provide justification to change a label"
4. Define predefined justification reasons
5. Set policy scope (global or specific groups)
6. Verify audit logging is enabled
7. Test with pilot users

**Learn More:** [Require users to provide justification to change a label](https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps#require-users-to-provide-justification-to-change-a-label)

- [Create and publish sensitivity labels](https://learn.microsoft.com/en-us/microsoft-365/compliance/create-sensitivity-labels)
- [Require users to provide justification to change a label](https://learn.microsoft.com/en-us/purview/sensitivity-labels-office-apps#require-users-to-provide-justification-to-change-a-label)
- [Plan your sensitivity label solution](https://learn.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels#plan-for-sensitivity-labels)
- [Search the audit log](https://learn.microsoft.com/en-us/purview/audit-log-search)

<!--- Results --->
%TestResult%
