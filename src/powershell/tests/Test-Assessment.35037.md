Purview audit logging is the foundational mechanism for detecting and investigating data security incidents, unauthorized access attempts, and compliance violations across Microsoft 365. Without unified audit logging enabled, organizations lose visibility into who accessed sensitive data, when policy violations occurred, and what administrative actions were taken. Audit logs are critical for forensic investigations, regulatory compliance, eDiscovery, insider threat detection, and demonstrating controls to auditors and regulators. Disabling or failing to enable audit logging creates a "blind spot" where threat actors can operate undetected, policy violations go unnoticed, and incident response becomes impossible due to lack of evidence. Organizations must enable Purview audit logging to maintain visibility across Exchange Online, SharePoint Online, OneDrive, Teams, and other services, ensuring that all user and admin activities are captured and available for investigation. Without audit logging enabled, organizations cannot meet compliance requirements (SOX, HIPAA, GDPR, etc.) that mandate activity logging for sensitive operations.

**Remediation action**

To enable Purview audit logging:

1. Sign in as a Global Administrator or Compliance Administrator to the [Microsoft Purview portal](https://purview.microsoft.com)
2. Navigate to **Audit** > **New Search**
3. If prompted that auditing is not enabled, select **Turn on auditing**
4. Confirm the prompt to enable unified audit logging
5. Wait 1-2 hours for audit log ingestion to become active
6. Via PowerShell:
   - Connect to Exchange Online: `Connect-ExchangeOnline`
   - Verify audit is enabled: `Get-AdminAuditLogConfig | Select-Object UnifiedAuditLogIngestionEnabled`
   - If disabled, audit logging is enabled by default for most organizations; if not, contact Microsoft Support
7. Search audit logs to verify they are being collected: Navigate to **Audit** > **Audit search** and run a test search
8. Configure retention policy (default is 90 days, E5 can extend to 180 days or longer with extended retention)

For more information:
- [Enable or disable audit log search](https://learn.microsoft.com/en-us/purview/audit-log-enable-disable)
- [Search the audit log](https://learn.microsoft.com/en-us/purview/audit-search)
- [Audit log retention policies](https://learn.microsoft.com/en-us/purview/audit-log-retention-policies)
