Without Microsoft Entra pre-authentication configured on Application Proxy applications, threat actors can directly reach the internal URL of published on-premises applications without first proving their identity. When passthrough authentication is used, all authentication responsibility falls to the internal application, and Application Proxy merely forwards traffic without validating the requestor. This configuration potentially allows reconnaissance activities against backend systems, as threat actors can probe application endpoints to discover vulnerabilities or exploit authentication weaknesses in legacy applications. Once a vulnerability is identified in the backend application, threat actors can exploit it to gain initial access to the internal network. From this foothold, lateral movement becomes possible as the compromised application may have network connectivity to other internal systems. Additionally, passthrough mode prevents the enforcement of Conditional Access policies, meaning organizations cannot apply location-based restrictions, require multifactor authentication, or evaluate user and sign-in risk before granting access. The lack of pre-authentication also prevents integration with Microsoft Defender for Cloud Apps for real-time session monitoring and control.

**Remediation action**

- [Configure Microsoft Entra pre-authentication for Application Proxy applications by navigating to the application's Application Proxy settings in the Microsoft Entra admin center and changing the Pre-Authentication method from Passthrough to Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/app-proxy/application-proxy-add-on-premises-application#add-an-on-premises-app-to-microsoft-entra-id)

- [Plan your Application Proxy deployment and understand the security benefits of pre-authentication](https://learn.microsoft.com/en-us/entra/identity/app-proxy/conceptual-deployment-plan)

- [Review security considerations for Application Proxy including the authenticated access benefits](https://learn.microsoft.com/en-us/entra/identity/app-proxy/application-proxy-security)

- [Configure single sign-on (SSO) options which require pre-authentication to function](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/what-is-single-sign-on)

- [Use Microsoft Graph API to programmatically update Application Proxy settings](https://learn.microsoft.com/en-us/graph/application-proxy-configure-api)

<!--- Results --->
%TestResult%
