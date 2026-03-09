Without private DNS configuration, remote users can't resolve internal domain names through Microsoft Entra Private Access and must rely on public DNS servers. Threat actors can exploit this gap through DNS spoofing attacks that redirect users to malicious sites, enabling credential harvesting and data exfiltration. Organizations also lose visibility into DNS queries and can't enforce consistent security policies.

**Remediation action**

- [Configure private DNS for internal name resolution](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-quick-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#add-private-dns-suffixes)
<!--- Results --->
%TestResult%

