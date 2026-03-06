Without universal tenant restrictions configured, users on corporate devices and networks can authenticate to unauthorized external Microsoft Entra tenants and access cloud applications by using external identities. This vulnerability makes it possible for a threat actor to use compromised user credentials or established persistence on a corporate device to authenticate to a tenant they control. They can bypass traditional network security controls that can't inspect encrypted authentication traffic to Microsoft identity endpoints.

Once authenticated to an external tenant, a threat actor can access Microsoft Graph APIs and cloud services. This access enables data exfiltration through OneDrive, SharePoint, Teams, or any Microsoft Entra-integrated application in the external tenant. This attack path exploits the inherent trust that corporate networks and devices have with Microsoft identity services. Universal tenant restrictions address this vulnerability by injecting tenant identity headers into authentication plane traffic through Global Secure Access. Microsoft Entra ID uses these headers to enforce tenant restrictions v2 policies that block authentication attempts to unauthorized external tenants.

**Remediation action**

- [Set up tenant restrictions v2](https://learn.microsoft.com/entra/external-id/tenant-restrictions-v2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) policies to block all external tenants by default.
- [Turn on universal tenant restrictions](https://learn.microsoft.com/entra/global-secure-access/how-to-universal-tenant-restrictions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) signaling in Global Secure Access.
- [Deploy Global Secure Access client](https://learn.microsoft.com/entra/global-secure-access/concept-clients?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) on devices.
- [Enable the Microsoft traffic profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-microsoft-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%
