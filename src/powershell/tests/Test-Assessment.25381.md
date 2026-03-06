Traffic forwarding profiles are the foundational mechanism through which Global Secure Access captures and routes network traffic to Microsoft's Security Service Edge infrastructure. If you don't enable the appropriate traffic forwarding profiles, network traffic bypasses the Global Secure Access service entirely, and users don't get these network access protections.

There are three distinct profiles:

- **Microsoft traffic profile**: Captures Microsoft Entra ID, Microsoft Graph, SharePoint Online, Exchange Online, and other Microsoft 365 workloads.
- **Private access profile**: Captures traffic destined for internal corporate resources.
- **Internet access profile**: Captures traffic to the public internet including non-Microsoft SaaS applications.

If you don't enable these profiles:

- You can't enforce security policies, web content filtering, threat protection, or Universal Continuous Access Evaluation.
- Threat actors who compromise user credentials can access corporate resources without the security controls that Global Secure Access would otherwise apply.

**Remediation action**

- Enable the Microsoft traffic forwarding profile. For more information, see [Manage the Microsoft traffic profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-microsoft-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Enable the Private Access traffic forwarding profile. For more information, see [Manage the Private Access traffic forwarding profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-private-access-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Enable the Internet Access traffic forwarding profile. For more information, see [Manage the Internet Access traffic forwarding profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-internet-access-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

