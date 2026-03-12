Microsoft Entra Private Access relies on private network connectors—lightweight Windows Server agents that broker outbound connections from on-premises or cloud-hosted networks to the Global Secure Access service. Each connector group acts as the sole access path for the private applications assigned to it. If only one connector is deployed in a group serving a region, any failure of that host—whether due to a hardware fault, OS crash, scheduled patch reboot, or a threat actor deliberately disrupting connector host connectivity—immediately eliminates all private application access for users in that region. A threat actor who achieves enough access to terminate the connector Windows service or block its outbound TLS communication on ports 443/80 can silently deny access to private applications without triggering identity-layer alerts. The service marks a connector `inactive` after it stops heartbeating and removes it after 10 days; during that window, no automated failover occurs if it was the sole connector in the group. Because Private Access enforces Conditional Access policies at the point of connection—requiring the connector to be reachable to validate session tokens and enforce per-app policies—a downed single connector means Zero Trust controls cannot be applied, and users are denied access rather than routed through an alternative enforcement point. Microsoft documentation explicitly states: "maintain a minimum of two healthy connectors to ensure resiliency and consistent availability," and "you might experience downtime during an update if you have only one connector." Deploying at least two active connectors per connector group ensures load balancing, seamless automatic updates (which target one connector at a time), and continuity of Zero Trust enforcement if one connector fails.

**Remediation action**

Install and register an additional private network connector on a Windows Server in the affected region
- [How to configure private network connectors for Microsoft Entra Private Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-connectors)

Understand connector group high-availability requirements and best practices
- [Microsoft Entra private network connectors — Connector groups](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-connectors#connector-groups)

Review sizing and resiliency guidance including the minimum two-connector recommendation
- [Microsoft Entra private network connectors — Specifications and sizing requirements](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-connectors#specifications-and-sizing-requirements)

Application Proxy high-availability load balancing best practices applicable to Private Access connector groups
- [Best practices for high availability of connectors](https://learn.microsoft.com/en-us/entra/identity/app-proxy/application-proxy-high-availability-load-balancing#best-practices-for-high-availability-of-connectors)

Troubleshoot inactive or malfunctioning connectors
- [Troubleshoot connectors](https://learn.microsoft.com/en-us/entra/global-secure-access/troubleshoot-connectors)


<!--- Results --->
%TestResult%
