By using Transport Layer Security (TLS) inspection, Global Secure Access can decrypt encrypted HTTPS traffic and check it for threats, malicious content, and policy violations. If TLS inspection fails for a connection, that traffic bypasses security controls. Inspection failures can let potential malware delivery, command-and-control communications, or data exfiltration go undetected.

Failure rates above 1% point to systemic problems. These problems include certificate trust issues on endpoints, incompatible applications that use certificate pinning without proper bypass rules, or certificate authority configuration errors. Threat actors can also intentionally create connections that cause TLS inspection failures.

**Remediation action**

- [Configure diagnostic settings to export traffic logs](https://learn.microsoft.com/entra/global-secure-access/how-to-view-traffic-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-diagnostic-settings-to-export-logs) to a Log Analytics workspace. Use these logs to monitor TLS inspection success rates and investigate the root causes of failures.
- Follow the steps in [Troubleshoot Global Secure Access Transport Layer Security inspection errors](https://learn.microsoft.com/entra/global-secure-access/troubleshoot-transport-layer-security?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to resolve common inspection failures.
- For destinations with certificate pinning, [add TLS bypass rules](https://learn.microsoft.com/entra/global-secure-access/how-to-transport-layer-security?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to reduce failure rates while keeping inspection for other traffic.
<!--- Results --->
%TestResult%

