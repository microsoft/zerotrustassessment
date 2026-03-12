When Quick Access is not configured or is not bound to a connector group with connectors, private network resources remain accessible through paths that bypass Global Secure Access controls. Threat actors who compromise user credentials can access internal FQDNs and IP ranges without Conditional Access evaluation, because the traffic does not route through the Global Secure Access service. Without connector-mediated traffic brokering, there is no enforcement point between the user and the private resource, which means Conditional Access policies targeting the Quick Access enterprise application do not apply. A threat actor can use stolen credentials to authenticate, reach internal resources over a VPN or direct network path, move between internal systems, and exfiltrate data without the organization having visibility through Global Secure Access traffic logs. Binding Quick Access to a connector group with connectors ensures that private network traffic routes through Global Secure Access, where Conditional Access policies, user assignments, and traffic logging apply.

**Remediation action**

Configure Quick Access and connectors for Entra Private Access, and ensure the Private Access forwarding profile is enabled:
- [Configure Quick Access for Global Secure Access Private Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-quick-access)
- [Configure connectors for Global Secure Access](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-connectors)
- [Enable the Private Access traffic forwarding profile](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-private-access-profile)
- [Understand Microsoft Entra Private Access concepts](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-private-access)
<!--- Results --->
%TestResult%
