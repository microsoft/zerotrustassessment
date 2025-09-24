Without limiting guest access to approved tenants, threat actors can exploit unrestricted guest access to establish initial access through compromised external accounts or by creating accounts in untrusted tenants. Organizations can configure an allowlist or blocklist to control B2B collaboration invitations from specific organizations, and without these controls, threat actors can leverage social engineering techniques to obtain invitations from legitimate internal users. Once threat actors gain guest access through unrestricted domains, they can perform discovery activities to enumerate internal resources, users, and applications that guest accounts can access. The compromised guest account then serves as a persistent foothold, allowing threat actors to execute collection activities against accessible SharePoint sites, Teams channels, and other resources granted to guest users. From this position, threat actors can attempt lateral movement by exploiting trust relationships between the compromised tenant and partner organizations, or by leveraging guest permissions to access sensitive data that can be used for further credential compromise or business email compromise attacks.

**Remediation action**

- [Configure Domain-Based Allow or Deny Lists](https://learn.microsoft.com/en-us/entra/external-id/allow-deny-list)

<!--- Results --->
%TestResult%
