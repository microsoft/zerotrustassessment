When Quick Access lacks user or group assignments, the service prevents connections to fully qualified domain names (FQDNs) and IP addresses that you configure in the application segments. This restriction disrupts access to internal resources like file shares, web applications, and databases. When users can't reach resources through the Global Secure Access client, they might seek alternative access methods that bypass security controls such as Conditional Access policies and multifactor authentication.

If you don't assign users to Quick Access:

- Authorized users can't reach internal resources through Private Access, creating gaps in business continuity.
- Administrators might implement temporary workarounds that weaken the organization's security posture.

**Remediation action**

- [Assign users and groups to Quick Access](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-quick-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to enable Private Access connectivity to configured application segments.
<!--- Results --->
%TestResult%

