When the Private Access profile is enabled in Global Secure Access but neither port 53 (UDP/TCP) is published in application segments nor private DNS suffixes are configured, the Global Secure Access client on remote devices cannot route DNS queries for internal domain names through the tunnel. DNS queries for internal FQDNs then go to the local resolver on the device, which has no knowledge of internal zones. This causes FQDN-based application segments to fail to match traffic because the client cannot resolve internal host names to IP addresses. A threat actor operating on the same local network as the remote user can observe these unencrypted DNS queries (T1040 - Network Sniffing), map internal resource names, and use that information to identify targets for later stages of an attack. The client may also fall back to direct connections that bypass Conditional Access and security profile enforcement applied through Global Secure Access, reducing the organization's control over access to private resources. Configuring private DNS suffixes or publishing port 53 to an internal DNS server through an application segment ensures that DNS resolution for internal domains occurs within the tunnel, preventing DNS leakage and maintaining traffic acquisition for FQDN-based segments.

**Remediation action**

- [Configure private DNS suffixes for Quick Access or per-app access to route DNS queries for internal domains through Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-quick-access)
- [Configure per-app access with application segments that include port 53 to an internal DNS server](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-per-app-access)
- [Understand Private Access and application segment configuration in Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/concept-private-access)

<!--- Results --->
%TestResult%
