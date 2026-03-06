Global Secure Access requires specific Microsoft Entra licenses to function, including Microsoft Entra Internet Access and Microsoft Entra Private Access, both of which require Microsoft Entra ID P1 as a prerequisite. Without valid licenses provisioned in the tenant, administrators can't configure traffic forwarding profiles, security policies, or remote network connections. If you don't assign licenses to users, their traffic doesn't route through Global Secure Access, and remains unprotected by security controls.

Without this protection:

- Threat actors can bypass web content filtering, threat protection, and Conditional Access policies.
- Expired or suspended subscriptions can halt the Global Secure Access service, creating security gaps where previously protected traffic flows go unmonitored.

**Remediation action**

- Review Global Secure Access licensing requirements and purchase appropriate licenses. For more information, see [Licensing overview](https://learn.microsoft.com/entra/global-secure-access/overview-what-is-global-secure-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#licensing-overview).
- Assign licenses to users through the Microsoft Entra admin center. For more information, see [Assign licenses to users](https://learn.microsoft.com/entra/fundamentals/license-users-groups?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Use group-based licensing for easier management at scale. For more information, see [Group-based licensing](https://learn.microsoft.com/entra/fundamentals/concept-group-based-licensing?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Monitor license utilization through Microsoft 365 admin center. For more information, see [Microsoft 365 admin center](https://admin.microsoft.com/Adminportal/Home#/licenses).
- Review Microsoft Entra Suite as an alternative that includes both Internet Access and Private Access. For more information, see [What's new in Microsoft Entra](https://learn.microsoft.com/entra/fundamentals/whats-new?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#microsoft-entra-suite).
<!--- Results --->
%TestResult%
