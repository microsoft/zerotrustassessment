When you don't block high-risk web content filtering categories like criminal activity, hacking, and illegal software, users who connect through Global Secure Access stay exposed to dangerous attack vectors and liability risks. These high-risk sites can distribute exploit code, malware-embedded software, and guidance on committing illegal acts that threat actors can use to compromise your environment.

Without this protection:

- Users can access sites that provide tools, scripts, and tutorials for unauthorized access, enabling threat actors to escalate their capabilities within the network.
- Pirated software and license key generators downloaded from illegal software sites frequently contain embedded malware that establishes persistence and enables lateral movement.
- The organization faces both security vulnerabilities and legal liability from uncontrolled access to high-risk content categories.

**Remediation action**

- [Configure web content filtering](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-web-content-filtering?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to block high-risk web content categories **Criminal activity**, **Hacking**, and **Illegal software**.
- Review all available [Global Secure Access web content filtering categories](https://learn.microsoft.com/entra/global-secure-access/reference-web-content-filtering-categories?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- [Create security profiles](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-web-content-filtering?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-security-profile) to group filtering policies for Conditional Access enforcement.
- [Enable the Internet Access traffic forwarding profile](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-internet-access-profile?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to route traffic through Global Secure Access for web content filtering to apply.
- [Link security profiles to Conditional Access](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-web-content-filtering?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-and-link-conditional-access-policy) to enforce web content filtering for targeted users and groups.
<!--- Results --->
%TestResult%

