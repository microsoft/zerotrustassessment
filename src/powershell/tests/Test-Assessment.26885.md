When Azure DDoS Protection is enabled for public IP addresses, enabling metrics provides essential real-time visibility into attack activity, mitigation effectiveness, and traffic patterns. Without metrics enabled on DDoS-protected public IPs, security teams lack the telemetry needed to detect ongoing attacks, validate that mitigation policies are working, and perform capacity planning. Azure DDoS Protection emits metrics such as "Under DDoS attack or not", inbound packets and bytes processed, packets and bytes dropped during mitigation, and TCP/UDP/SYN flood counters. These metrics are foundational for alerting, dashboards, and post-incident analysis. The absence of metrics prevents correlation of DDoS events with application performance issues and eliminates the ability to analyze attack patterns for proactive defense improvements. This check identifies all public IP addresses that are actually DDoS-protected — either through DDoS IP Protection enabled directly on the public IP, or through DDoS Network Protection inherited from a VNET that has a DDoS Protection Plan associated — and verifies that diagnostic settings are configured to capture metrics for security monitoring.

**Remediation action**

Enable metrics in diagnostic settings for DDoS-protected public IP addresses
- [Azure DDoS Protection metrics and alerts](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-diagnostic-logs)

Configure diagnostic settings for Azure resources
- [Configure diagnostic settings for Azure resources](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings)

Review DDoS Protection capabilities and overview
- [Azure DDoS Protection overview](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview)

Enable DDoS Network Protection on virtual networks
- [Quickstart: Create and configure Azure DDoS Network Protection using Azure portal](https://learn.microsoft.com/en-us/azure/ddos-protection/manage-ddos-protection)

<!--- Results --->
%TestResult%
