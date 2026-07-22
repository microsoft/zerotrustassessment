Microsoft Entra Agent ID requires every [agent identity](https://learn.microsoft.com/entra/agent-id/agent-identities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) and [agent identity blueprint](https://learn.microsoft.com/entra/agent-id/agent-blueprint?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to have at least one sponsor. A sponsor is a human user, or supported group, that holds business accountability for the agent's lifecycle, such as deciding when the agent is no longer needed, approving extensions when access expires, and authorizing suspension during incidents. A sponsor is different from an owner, which designates the human users responsible for technical operations and incident response.

Sponsorship is the entry point for identity governance:

- Lifecycle Workflows can route sponsor-leaving notifications to managers
- Access package expiry escalations are sent to the sponsor
- Entitlement management approvers rely on the sponsor relationship to validate continued access.

Without an assigned sponsor, agent identities can't be properly governed. An agent identity that exists without a sponsor is governance-invisible. Without an access package that targets agent identities, every permission an agent receives must be granted directly, through `appRoleAssignment`, `oauth2PermissionGrant`, group membership, or directory-role assignment, which is outside the entitlement management control loop. Direct grants have no built-in expiration, no approver loops, and no access review schedules. Without a Lifecycle Workflow containing agent sponsor tasks, the sponsor relationship is a static directory record with no automation when a sponsor moves or leaves. A threat actor who compromises an ungoverned agent — through credential theft, blueprint compromise, or a malicious access-package request that no governance pipeline existed to intercept — operates against an identity whose permissions were never reviewed. This check also verifies that at least one access package assignment policy targets all directory agent identities.

**Remediation action**

- [Administrative relationships in Microsoft Entra Agent ID](https://learn.microsoft.com/entra/agent-id/agent-owners-sponsors-managers?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Governing agent identities](https://learn.microsoft.com/entra/id-governance/agent-id-governance-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Agent identity sponsor tasks in Lifecycle Workflows](https://learn.microsoft.com/entra/id-governance/agent-sponsor-tasks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Access packages for agent identities](https://learn.microsoft.com/entra/agent-id/agent-access-packages?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Create an access package in entitlement management](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

