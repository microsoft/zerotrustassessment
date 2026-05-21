When you enable the Private Access profile in Global Secure Access but don't publish port 53 (UDP/TCP) in application segments or configure private DNS suffixes, the Global Secure Access client can't route DNS queries for internal domain names through the tunnel. As a result, DNS queries for internal FQDNs go to the local resolver on the device, which has no knowledge of internal zones.

Without this configuration:

- FQDN-based application segments fail to match traffic because the client can't resolve internal host names to IP addresses.
- Threat actors operating on the same local network as the remote user can observe unencrypted DNS queries, map internal resource names, and identify targets for later stages of an attack.
- The client might fall back to direct connections that bypass Conditional Access and security profile enforcement applied through Global Secure Access.

**Remediation action**

- [Configure private DNS suffixes for Quick Access or per-app access](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-quick-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) so DNS queries for internal domains go through Global Secure Access.
- [Configure per-app access with application segments](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-per-app-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) that include port 53 (UDP/TCP) to an internal DNS server.
- [Learn about Microsoft Entra Private Access](https://learn.microsoft.com/entra/global-secure-access/concept-private-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in Global Secure Access.
<!--- Results --->
%TestResult%

