<!-- This file is a duplicate of 25380.md. Docs files reference 25380.md.-->
When organizations deploy Global Secure Access as their cloud-based network proxy, Microsoft's Secure Service Edge infrastructure routes user traffic. If you don't enable source IP restoration, all authentication requests come from the proxy's IP address instead of the user's actual public egress IP.

Without this protection:

- Threat actors who compromise user credentials can authenticate from any location while bypassing IP-based Conditional Access controls and named location policies.
- Microsoft Entra ID Protection risk detections lose visibility into the original user IP address, which degrades the accuracy of risk scoring algorithms.
- Sign-in logs and audit trails no longer show the true source of authentication attempts, which makes incident investigation and forensic analysis more difficult.

**Remediation action**

- Enable Global Secure Access signaling in Conditional Access. For more information, see [Source IP restoration](https://learn.microsoft.com/entra/global-secure-access/how-to-source-ip-restoration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

