When Microsoft Entra private network connectors are inactive or unhealthy, organizations might resort to using less secure access methods. This condition creates opportunities where threat actors can target externally exposed services or use compromised credentials.

Without functional connectors:

- Token-based authentication and authorization for all Microsoft Entra Private Access scenarios is eliminated.
- Threat actors can bypass intended security boundaries to access resources beyond their authorization scope.
- The service can't route requests properly, directly disrupting network access controls.

**Remediation action**

- [Configure connectors for high availability](https://learn.microsoft.com/entra/global-secure-access/how-to-configure-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Monitor connector health in the Microsoft Entra admin center under Global Secure Access > Connect > Connectors.
- [Troubleshoot connector installation and connectivity issues](https://learn.microsoft.com/entra/global-secure-access/troubleshoot-connectors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

