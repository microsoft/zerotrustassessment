Sensitivity label policies control which labels are available to users and can be scoped to specific users, groups, or the entire organization. Publishing too many labels globally creates confusion and decision paralysis for end users, reducing adoption and increasing the likelihood of misclassification. When users are presented with an overwhelming number of label choices (typically more than 25 top-level and sub-labels), they struggle to identify the appropriate classification for their content, leading to either selecting incorrect labels or avoiding the feature entirely.

Microsoft recommends publishing no more than 25 labels in globally-scoped policies, ideally organized as 5 parent labels with up to 5 sub-labels each. This creates a manageable hierarchy that users can understand and apply consistently. Organizations with complex classification needs should use scoped policies to publish specialized labels only to the departments or roles that require them, keeping the global label set lean and focused on the most common classification scenarios.

**Remediation action**

To reduce the number of globally-published labels:
1. Review which labels are truly needed by all users
2. Create scoped label policies for department-specific or role-specific labels
3. Remove less-commonly-used labels from global policies
4. Consolidate similar labels where possible
5. Use sub-labels to organize related labels under parent categories

Best practices:
- Limit global policies to 5-7 top-level labels with 3-5 sub-labels each
- Use clear, business-friendly label names (not technical jargon)
- Publish specialized labels only to users who need them via scoped policies

To manage label policies:
1. Navigate to [Microsoft Purview portal > Information Protection > Label policies](https://purview.microsoft.com/informationprotection/labelpolicies)
2. Review existing globally-scoped policies
3. Edit policies to remove unnecessary labels or change scope to specific users/groups
4. Create new scoped policies for specialized labels

- [Sensitivity label policies best practices](https://learn.microsoft.com/purview/sensitivity-labels#what-label-policies-can-do)
- [Create and publish sensitivity labels](https://learn.microsoft.com/microsoft-365/compliance/create-sensitivity-labels)
- [Label policy priority and precedence](https://learn.microsoft.com/purview/sensitivity-labels-office-apps#label-policy-priority-order-matters)

<!--- Results --->
%TestResult%
