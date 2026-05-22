Microsoft Entra Private Access uses private network connectors to broker connections from on-premises or cloud-hosted networks to the Global Secure Access service. Each connector group serves as the only access path for the private applications assigned to it. If you deploy only one connector in a group, any failure of that host immediately removes all private application access for users who rely on that group.

Without this protection:

- A single connector failure causes a complete loss of private resource access for all users who rely on that connector group until you manually restore the connector.
- A threat actor who terminates the connector Windows service or blocks its outbound Transport Layer Security (TLS) communication can silently deny access to private applications without triggering identity-layer alerts.
- Automatic updates that target one connector at a time might cause downtime when only one connector exists in a group.
- You can't apply Conditional Access policies when the connector is unreachable, and users are denied access rather than routed through an alternative enforcement point.

**Remediation action**

- [Install and register an additional private network connector](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) on a Windows Server in the affected region.
- [Learn about connector group high-availability requirements](https://learn.microsoft.com/entra/global-secure-access/concept-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#connector-groups) and best practices.
- [Review sizing and resiliency guidance](https://learn.microsoft.com/entra/global-secure-access/concept-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#specifications-and-sizing-requirements) for Microsoft Entra private network connectors, including the minimum two-connector recommendation.
- [Review high-availability load-balancing best practices](https://learn.microsoft.com/entra/identity/app-proxy/application-proxy-high-availability-load-balancing?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#best-practices-for-high-availability-of-connectors) applicable to Private Access connector groups.
- [Troubleshoot inactive or malfunctioning private network connectors](https://learn.microsoft.com/entra/global-secure-access/troubleshoot-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

