TLS inspection enables Global Secure Access to decrypt and analyze encrypted HTTPS traffic for threats, malicious content, and policy violations. When TLS inspection fails for a connection, that traffic bypasses security controls entirely, allowing potential malware delivery, command-and-control communications, or data exfiltration to proceed undetected. Failure rates above 1% indicate systemic issues such as certificate trust problems on endpoints, incompatible applications using certificate pinning without proper bypass rules, or certificate authority configuration errors. Threat actors may intentionally craft connections designed to cause TLS inspection failures, knowing the resulting traffic will evade detection. A sustained high failure rate represents an expanding blind spot in the organization's security posture, as each failed inspection is a missed opportunity to detect and block malicious activity. Organizations should monitor TLS inspection success rates and investigate the root causes of failures to maintain comprehensive visibility into encrypted traffic.

**Remediation action**

- [Configure diagnostic settings to export traffic logs to Log Analytics](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-view-traffic-logs#configure-diagnostic-settings-to-export-logs)
- [Review TLS inspection concepts and troubleshooting](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-transport-layer-security)
- [For destinations with certificate pinning, add TLS bypass rules](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-transport-layer-security)

<!--- Results --->
%TestResult%
