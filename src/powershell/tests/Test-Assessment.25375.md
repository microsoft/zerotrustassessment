Global Secure Access requires specific Microsoft Entra licenses to function, including Microsoft Entra Internet Access and Microsoft Entra Private Access, both of which require Microsoft Entra ID P1 as a prerequisite. Without valid GSA licenses provisioned in the tenant, administrators cannot configure traffic forwarding profiles, security policies, or remote network connections. If licenses exist but are not assigned to users, those users will not have their traffic routed through the Global Secure Access service, leaving them unprotected by the security controls configured in the platform. Threat actors targeting unprotected users can bypass web content filtering, threat protection, and conditional access policies that would otherwise apply through GSA. Additionally, if licenses are assigned but the subscription has expired or been suspended, the entire GSA infrastructure becomes non-functional, creating a sudden security gap where previously protected traffic flows unmonitored. This check verifies that valid GSA licenses exist in the tenant with an enabled capability status and that those licenses are actively assigned to users who require protection through the Global Secure Access service.

**Remediation action**

- [Review GSA licensing requirements and purchase appropriate licenses](https://learn.microsoft.com/en-us/entra/global-secure-access/overview-what-is-global-secure-access#licensing-overview)
- [Assign licenses to users through Microsoft Entra admin center](https://learn.microsoft.com/en-us/entra/fundamentals/license-users-groups)
- [Use group-based licensing for easier management at scale](https://learn.microsoft.com/en-us/entra/fundamentals/concept-group-based-licensing)
- [Monitor license utilization through Microsoft 365 admin center](https://admin.microsoft.com/Adminportal/Home#/licenses)
- [Review Microsoft Entra Suite as an alternative that includes both Internet Access and Private Access](https://learn.microsoft.com/en-us/entra/fundamentals/whats-new#microsoft-entra-suite)

<!--- Results --->
%TestResult%
