Allowing unrestricted external collaboration with unvetted organizations increases the risk surface area to the tenant because it allows onboarding guest accounts that might not have proper security controls. Threat actors can establish initial access by compromising identities within loosely governed external tenants and leveraging legitimate collaboration pathways to infiltrate resources in your tenant. Once granted guest access, adversaries can attempt to harvest sensitive information, and exploit misconfigured permissions to escalate privileges and try additional attacks. Without vetting the security of organizations you collaborate with, malicious external accounts can persist undetected, exfiltrate confidential data, inject malicious payloads. This unbounded collaboration surface weakens organizational control, enabling cross-tenant attacks that bypass traditional perimeter defenses and undermine both data integrity and operational resilience.

Cross-tenant access settings for outbound access in Entra provides a mechanism to block collaboration by default with unknown organizations, reducing the attack surface created.

**Remediation action**

Implement default outbound policy to restrict access by default. Create targeted policies for the organizations that your tenant approved collaboration with to override the default block policy.
- [Cross-tenant access with Microsoft Entra External ID](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-overview)
- [Cross-tenant access settings for B2B collaboration](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration#configure-default-settings)
<!--- Results --->
%TestResult%
