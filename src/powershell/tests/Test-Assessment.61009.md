When an organization deploys AI agents, those agents acquire access tokens to access organizational resources on every interaction, but without an interactive user session and device, location, or MFA signals that classic Conditional Access uses to make trust decisions for human users. Microsoft Entra Agent ID introduces two distinct identity types:

- An [agent identity](https://learn.microsoft.com/entra/agent-id/agent-identities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci): An identity account within Microsoft Entra ID that provides unique identification and authentication capabilities for AI agents.
- An [agent's user account](https://learn.microsoft.com/entra/agent-id/agent-users?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci): An optional account that pairs 1:1 with an agent identity when the agent must access systems that require a user object.

Conditional Access treats both agent identity objects as separate principal types. So a policy that targets agent identities can't target an agent's user account, and vice versa. A tenant that enables agent workloads without at least one Conditional Access policy enforcing block-unless-approved has no enforcement boundary on autonomous AI access. Every token request from an agent identity or agent's user account is allowed by default. Threat actors seek to exploit this type of failure mode when they compromise a single agent identity or its backing agent's user account and pivot through the resources that identity can reach.

**Remediation action**

- [Conditional Access for Agent ID (Preview)](https://learn.microsoft.com/entra/identity/conditional-access/agent-id?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Identity Protection signals for agents](https://learn.microsoft.com/entra/id-protection/concept-risky-agents?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Filter for applications in Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/concept-filter-for-applications?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Custom security attributes in Microsoft Entra ID](https://learn.microsoft.com/entra/fundamentals/custom-security-attributes-add?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

