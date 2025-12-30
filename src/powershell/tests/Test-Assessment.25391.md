When Entra Private Network Connectors are inactive or unhealthy, threat actors operating under assume breach conditions can exploit the lack of secure remote access control. Connectors create outbound connections to the Private Access services to reach internal resources, and when these connectors fail, organizations may resort to alternatives such as exposing applications directly or using less secure access methods. This creates initial access opportunities where threat actors can target externally exposed services or leverage compromised VPN credentials. Following successful authentication through weakened access controls, threat actors can establish persistence by maintaining access to internal resources that would otherwise require connector-based authentication and authorization checks.  

The absence of functional connectors eliminates the token-based authentication and authorization performed for all Private Access scenarios, enabling lateral movement as threat actors traverse the network without the granular access controls enforced by connector groups. The service routes new requests to an available connector, and if a connector is temporarily unavailable, it does not receive traffic meaning connector failures directly disrupt zero trust network access controls. Organizations may then implement workarounds that bypass intended security boundaries, facilitating privilege escalation as threat actors exploit the degraded security posture to access resources beyond their authorization scope. 

**Remediation action**

- [Troubleshoot connector installation and connectivity issues](https://learn.microsoft.com/en-us/entra/global-secure-access/troubleshoot-connectors)
- [Configure connectors for high availability](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-connectors)
- [Monitor connector health and performance](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-connectors)

<!--- Results --->
%TestResult%
