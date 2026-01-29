Without Universal Tenant Restrictions (UTR) configured, users on corporate devices and networks can authenticate to unauthorized external Microsoft Entra tenants and access cloud applications using external identities, creating a significant data exfiltration vector. A threat actor who has compromised user credentials or established persistence on a corporate device can authenticate to a tenant they control using personal or external organizational identities, bypassing traditional network security controls that cannot inspect encrypted authentication traffic to Microsoft identity endpoints. Once authenticated to an external tenant, the actor can access Microsoft Graph APIs and cloud services, enabling data exfiltration through OneDrive, SharePoint, Teams, or any Microsoft Entra-integrated application in the external tenant. This attack path exploits the inherent trust that corporate networks and devices have with Microsoft identity services. Universal Tenant Restrictions address this by injecting tenant identity headers into authentication plane traffic via Global Secure Access, enabling Microsoft Entra ID to enforce tenant restrictions v2 policies that block authentication attempts to unauthorized external tenants.

**Remediation action**

Configure tenant restrictions v2 policies to block all external tenants by default
- [Set up tenant restrictions v2](https://learn.microsoft.com/en-us/entra/external-id/tenant-restrictions-v2)

Enable Universal Tenant Restrictions signaling in Global Secure Access
- [Turn on universal tenant restrictions](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-universal-tenant-restrictions)

Deploy Global Secure Access clients on devices
- [Global Secure Access clients overview](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-clients)

Enable Microsoft traffic profile for Universal Tenant Restrictions
- [Microsoft traffic profile concept](https://learn.microsoft.com/en-us/entra/global-secure-access/concept-microsoft-traffic-profile)

**Who**: Global Secure Access Administrator (for Q1), Security Administrator or Global Administrator (for Q2)

**When**: During initial Global Secure Access deployment and before enabling production traffic forwarding

**Where**: Microsoft Entra admin center > Global Secure Access > Session Management > Universal Tenant Restrictions
<!--- Results --->
%TestResult%
