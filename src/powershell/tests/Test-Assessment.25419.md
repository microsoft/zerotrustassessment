Without Global Secure Access logs integrated into a Microsoft Sentinel workspace, security operations teams lack centralized visibility into network traffic patterns, connection attempts, and access anomalies across Private Access, Internet Access, and Microsoft 365 traffic forwarding. Threat actors who compromise user credentials or devices can use these network access paths to perform reconnaissance, move laterally, or exfiltrate data without detection.

Without this integration:

- Security teams can't correlate network-layer activities with identity-based signals in Microsoft Entra ID or endpoint detections.
- Security information and event management (SIEM) systems can't apply behavioral analytics, threat intelligence correlation, or automated response playbooks to Global Secure Access traffic.
- Security teams can't investigate historical network access patterns or hunt for threats across network and identity signals.

**Remediation action**

- [Configure Microsoft Entra diagnostic settings](https://learn.microsoft.com/entra/global-secure-access/how-to-sentinel-integration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to send Global Secure Access logs to a Log Analytics workspace for Microsoft Sentinel integration.
- [Enable all required Global Secure Access identity log categories](https://learn.microsoft.com/entra/identity/monitoring-health/concept-diagnostic-settings-logs-options?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci), including `NetworkAccessTrafficLogs`, `EnrichedOffice365AuditLogs`, `RemoteNetworkHealthLogs`, `NetworkAccessAlerts`, `NetworkAccessConnectionEvents`, and `NetworkAccessGenerativeAIInsights` in diagnostic settings.
- [Integrate Microsoft Entra activity logs with Azure Monitor](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) for centralized log collection.
- [Configure a Microsoft Sentinel workspace](https://learn.microsoft.com/azure/sentinel/quickstart-onboard?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) and install the Global Secure Access solution from the content hub.
<!--- Results --->
%TestResult%

