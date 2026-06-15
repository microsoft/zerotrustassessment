When organizations configure Microsoft Entra Private Access with broad application segments, such as wide IP ranges, multiple protocols, or Quick Access configurations, they effectively replicate the over-permissive access model of traditional VPNs. This approach contradicts the Zero Trust principle of least privilege, where users should only reach the specific resources required for their role.

Risks of broad segmentation:

- Threat actors who compromise a user's credentials or device can use broad network permissions to perform reconnaissance, identifying other systems and services within the permitted range.
- Lateral movement becomes easier as attackers can access multiple systems through a single compromised credential.
- Incident response is complicated because security teams can't quickly determine which specific resources a compromised identity could access.

Configuring per-application segmentation with tightly scoped destination hosts, specific ports, and Custom Security Attributes enables dynamic Conditional Access enforcement. This approach requires stronger authentication or device compliance for high-risk applications while streamlining access to lower-risk resources.

**Remediation action**

- [Review and refine application segments](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-per-app-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to use specific FQDNs, IP addresses, and specific port ranges that match application requirements rather than wide port ranges.
<!--- Results --->
%TestResult%

