When the Internet Access forwarding profile isn't enabled, users can access internet resources without routing traffic through the Secure Web Gateway. This gap allows threat actors to bypass security controls that block threats, malicious content, and unsafe destinations.

Without this protection:

- Organizations lose visibility into traffic patterns. They can't detect data exfiltration, connections to malicious domains, or unauthorized external access.
- Threat actors can deliver malware, establish command and control connections, or exfiltrate data through unmonitored channels.
- Threat actors can use compromised credentials or social engineering to gain initial access, download tools, establish persistence, or communicate with external infrastructure.
- Threat actors can use compromised accounts to blend with typical user behavior and access external resources without triggering security alerts based on user context, device compliance, or location.

**Remediation action**

- Enable the Internet Access forwarding profile to route traffic through the Secure Web Gateway. For more information, see [How to manage the Internet Access traffic forwarding profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-internet-access-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Assign users and groups to the Internet Access profile to limit traffic forwarding to specific users. For more information, see [Global Secure Access traffic forwarding profiles](https://learn.microsoft.com/entra/global-secure-access/concept-traffic-forwarding?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%
