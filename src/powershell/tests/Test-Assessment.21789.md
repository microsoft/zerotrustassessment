Tenant creation events should be monitored and triaged to detect unauthorized tenant creation. Users with sufficient permissions can create new tenants, which could be used to establish shadow environments outside your organization's security monitoring. Routing audit logs to a SIEM and configuring alerts for tenant creation events enables security teams to quickly investigate and respond to potentially malicious activity.

**Remediation action**

- [Review and restrict permissions to create tenants](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Stream audit logs to an event hub for SIEM integration](https://learn.microsoft.com/entra/identity/monitoring-health/howto-stream-logs-to-event-hub?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Configure monitoring and alerting for audit events](https://learn.microsoft.com/entra/identity/monitoring-health/overview-monitoring-health?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

