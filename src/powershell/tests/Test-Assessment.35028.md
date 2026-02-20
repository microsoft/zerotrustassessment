Email retention policies automatically manage message lifecycle by deleting, archiving, or preserving emails based on organizational compliance and legal requirements. Without retention policies configured for Exchange Online, organizations have no centralized mechanism to enforce record retention schedules, comply with regulatory mandates (GDPR, HIPAA, SOX), or manage mailbox growth. Emails may persist indefinitely in user mailboxes, creating liability for regulatory violations, increased eDiscovery costs during litigation, and uncontrolled data storage expenses. Retention policies ensure sensitive emails are automatically deleted after compliance-required holding periods, legal holds preserve emails for investigations, and archive policies move aged messages to reduce mailbox size while maintaining accessibility. Organizations must configure at least one email retention policy aligned with compliance requirements to enforce consistent message lifecycle management, reduce eDiscovery scope, and ensure regulatory record-keeping obligations are met.

**Remediation action**

To configure email retention policies:
1. Sign in as a Global Administrator or Compliance Administrator to the [Microsoft Purview Compliance Portal](https://purview.microsoft.com)
2. Navigate to **Data lifecycle management** > **Retention policies**
3. Select "New retention policy" to create a policy
4. Name the policy (e.g., "Email Retention - Standard", "Financial Records Retention")
5. Configure the retention policy:
   - **Locations:** Select "Exchange mailboxes" and choose scope (all mailboxes or specific recipients)
   - **Retention settings:** Define retention actions based on compliance requirements
     - Delete emails after X days of last modification
     - Archive emails after X days (move to Archive mailbox)
     - Place emails on legal hold indefinitely (for litigation)
     - Combination: archive after X days, then delete after Y days
6. Add retention rules to the policy:
   - Define conditions that trigger retention (optional - can apply to all emails)
   - Specify the retention action and duration
   - Example: "Delete all emails from Finance department after 7 years"
7. Review and apply the policy
8. Verify the policy is enabled and applied to Exchange
9. Allow 24-48 hours for policy to propagate to mailboxes
10. Monitor policy application and audit logs to ensure retention is functioning

For more information:
- [Create and manage retention policies](https://learn.microsoft.com/en-us/purview/create-retention-policies)
- [Learn about retention for Exchange](https://learn.microsoft.com/en-us/purview/retention-policies-exchange)
- [Learn about retention policies and retention labels](https://learn.microsoft.com/en-us/purview/retention)
- [Create eDiscovery holds](https://learn.microsoft.com/en-us/purview/edisc-hold-create)

<!--- Results --->
%TestResult%
