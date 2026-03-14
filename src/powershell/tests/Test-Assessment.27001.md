Transport Layer Security (TLS) inspection bypass rules create exceptions where encrypted traffic skips deep packet inspection. Without regular review, bypass rules accumulate as temporary exceptions become permanent, applications are decommissioned while their rules remain, or initial justifications become obsolete. Threat actors target uninspected traffic channels. They know that malware command-and-control communications, data exfiltration, and credential theft over HTTPS evade detection when traffic bypasses TLS inspection. Policies not modified in over 90 days might contain stale bypass rules that create blind spots in your network security posture.

**Remediation action**

- Establish a quarterly review process for TLS inspection bypass rules, document a business justification for each bypass rule, and remove rules that are no longer necessary.
- [Review and manage TLS inspection policies](https://learn.microsoft.com/graph/api/resources/networkaccess-tlsinspectionpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in the Microsoft Entra admin center under **Global Secure Access** > **Secure** > **TLS inspection**.
- Review the steps in [Configure Transport Layer Security inspection policies](https://learn.microsoft.com/entra/global-secure-access/how-to-transport-layer-security?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to understand how to modify or remove bypass rules as part of the review process.
<!--- Results --->
%TestResult%

