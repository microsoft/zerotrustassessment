Global Secure Access onboards and operates only when the tenant holds a Microsoft Entra ID P1 license plus at least one Global Secure Access licensing entitlement (Microsoft Entra Internet Access, Microsoft Entra Private Access, or Microsoft Agent 365). Without these tenant-level licenses provisioned with an active capability status, administrators cannot configure traffic forwarding profiles, security policies, or remote network connections.

Without this protection:

- Administrators cannot configure Global Secure Access features, leaving traffic unmonitored and unprotected.
- Expired or suspended subscriptions halt the entire Global Secure Access service, creating security gaps where previously protected traffic flows are no longer filtered or secured.

**Remediation action**
- Review Global Secure Access licensing requirements and purchase appropriate tenant licenses. For more information, see [Licensing overview](https://learn.microsoft.com/entra/global-secure-access/overview-what-is-global-secure-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#licensing-overview).
- Consider Microsoft Entra Suite, which includes Microsoft Entra Internet Access and Microsoft Entra Private Access. For more information, see [What's new in Microsoft Entra](https://learn.microsoft.com/entra/fundamentals/whats-new?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#microsoft-entra-suite).
- Purchase or extend Microsoft Entra ID P1 or P2 licenses, which are required prerequisites for Global Secure Access. For more information, see [Microsoft Entra ID licensing](https://learn.microsoft.com/entra/fundamentals/licensing?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
- Confirm purchased SKUs and capability status through the Microsoft 365 admin center. For more information, see [Microsoft 365 admin center](https://admin.microsoft.com/Adminportal/Home#/licenses).
- Ensure you have the required administrative roles to purchase or modify subscriptions. For more information, see [About admin roles](https://learn.microsoft.com/microsoft-365/admin/add-users/about-admin-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%
