Without Microsoft Entra preauthentication configured on Application Proxy applications, threat actors can directly reach the internal URL of published on-premises applications without first proving their identity. When you use passthrough authentication, Application Proxy forwards traffic without validating the requestor, and all authentication responsibility falls to the internal application.

If you don't configure preauthentication on Application Proxy applications:

- Threat actors can access internal application endpoints without identity verification, enabling reconnaissance and exploitation of backend vulnerabilities.
- Conditional Access policies can't be enforced, so you can't require multifactor authentication, evaluate sign-in risk, or apply location-based restrictions.
- You can't integrate with Microsoft Defender for Cloud Apps for real-time session monitoring and control.

**Remediation action**

- [Configure Microsoft Entra preauthentication for Application Proxy applications](https://learn.microsoft.com/entra/identity/app-proxy/application-proxy-add-on-premises-application?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#add-an-on-premises-app-to-microsoft-entra-id) by changing the Pre-Authentication method from **Passthrough** to **Microsoft Entra ID**.
- [Use Microsoft Graph API to programmatically update Application Proxy settings](https://learn.microsoft.com/graph/application-proxy-configure-api?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

