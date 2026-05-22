When you don't configure Quick Access or bind it to a connector group with active connectors, users can access private network resources through paths that bypass Global Secure Access controls. Threat actors who compromise user credentials can reach internal FQDNs and IP ranges without Conditional Access evaluation, because traffic doesn't route through the Global Secure Access service.

Without connector-mediated traffic brokering:

- There's no enforcement point between the user and the private resource, so Conditional Access policies targeting the Quick Access enterprise application don't apply.
- Threat actors can use stolen credentials to authenticate, move between internal systems, and exfiltrate data.
- The organization loses visibility through Global Secure Access traffic logs.

If you bind Quick Access to a connector group with active connectors, you ensure that private network traffic routes through Global Secure Access, where Conditional Access policies, user assignments, and traffic logging apply.

**Remediation action**

- [Configure Quick Access for Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-quick-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- [Configure private network connectors for Global Secure Access](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- [Enable the Private Access traffic forwarding profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-private-access-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- [Review Microsoft Entra Private Access concepts](https://learn.microsoft.com/entra/global-secure-access/concept-private-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

