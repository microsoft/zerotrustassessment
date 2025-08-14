Without configured domain allow/deny lists for external collaboration, organizations lack essential domain-level access controls that act as the frontline defense in their security model. Domain allow/deny lists operate at the tenant level and take precedence over Cross-Tenant Access Policies (XTAP), blocking invitations from domains on the deny list regardless of cross-tenant access settings. While XTAP enables granular controls for specific trusted tenants, domain restrictions are critical for preventing invitations from unknown or unverified domains that haven't been explicitly allowed.

Without these restrictions, internal users can invite external accounts from any domain—including potentially compromised or attacker-controlled domains. Threat actors can register domains that appear legitimate to conduct social engineering attacks, tricking users into sending collaboration invitations that circumvent XTAP's targeted protections. Once granted access, these external guest accounts can be used for reconnaissance, mapping internal resources, user relationships, and collaboration patterns.

These invited accounts provide persistent access that appears legitimate in audit logs and security monitoring systems. Attackers can maintain a long-term presence to collect data, access shared resources, documents, and applications configured for external collaboration, and potentially exfiltrate data through authorized channels without triggering alerts.

**Remediation action**
- [Configure domain-based allow or deny lists](https://learn.microsoft.com/en-us/entra/external-id/allow-deny-list?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#set-the-allow-or-blocklist-policy-in-the-portal)<!--- Results --->
%TestResult%

