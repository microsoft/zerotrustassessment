Without extended retention for Global Secure Access audit and traffic logs, threat actors can operate beyond the default 30-day retention window, knowing that their activities are automatically purged before detection occurs. Security investigations often require historical analysis spanning weeks or months to identify compromise vectors, lateral movement patterns, and data exfiltration channels.

Without adequate log retention:

- Security teams can't establish baseline behavior patterns, perform retrospective threat hunting, or correlate network access events across extended timeframes.
- Organizations subject to regulatory frameworks like [GDPR](https://learn.microsoft.com/compliance/regulatory/gdpr?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci), HIPAA, PCI DSS, and SOX face compliance violations when they're unable to produce audit trails for mandated retention periods.
- Root cause analysis during incident response is limited, potentially allowing threat actors to maintain persistence while organizations focus on visible symptoms.

**Remediation action**

- [Configure diagnostic settings with a Log Analytics workspace](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) for an extended retention of 90-730 days, with query capabilities.
- [Configure Log Analytics workspace retention](https://learn.microsoft.com/azure/azure-monitor/logs/data-retention-archive?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to meet organizational security and compliance requirements (minimum 90 days recommended).
- [Enable table-level retention](https://learn.microsoft.com/azure/azure-monitor/logs/data-retention-archive?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-table-level-retention) for specific Global Secure Access tables to extend beyond workspace defaults.
<!--- Results --->
%TestResult%

