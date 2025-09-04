Allowing unrestricted external collaboration with unverified organizations can increase the risk surface area of the tenant because it allows guest accounts that might not have proper security controls. Threat actors can attempt to gain access by compromising identities in these loosely governed external tenants. Once granted guest access, they can then use legitimate collaboration pathways to infiltrate resources in your tenant and attempt to gain sensitive information. Threat actors can also exploit misconfigured permissions to escalate privileges and try different types of attacks.

Without vetting the security of organizations you collaborate with, malicious external accounts can persist undetected, exfiltrate confidential data, and inject malicious payloads. This type of exposure can weaken organizational control and enable cross-tenant attacks that bypass traditional perimeter defenses and undermine both data integrity and operational resilience. Cross-tenant settings for outbound access in Microsoft Entra provide the ability to block collaboration with unknown organizations by default, reducing the attack surface.

**Remediation action**

- [Cross-tenant access overview](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Configure cross-tenant access settings](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-default-settings)
- [Modify outbound access settings](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

