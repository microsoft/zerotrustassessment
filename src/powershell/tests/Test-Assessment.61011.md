An agent endpoint that does not require Microsoft Entra user authentication is an unauthenticated but reachable surface inside the tenant's AI estate. A threat actor might find this endpoint by discovering public agent URLs, using leaked Copilot Studio links, or enumerating Foundry project endpoints. The actor can then interact with the agent without presenting an identity and use the agent’s existing grants to access grounding data, connected tools, and downstream APIs.

Calls that don't reach Microsoft Entra can't be evaluated by Conditional Access policies, have no sign-in risk to calculate, and can't tie audit records to a specific user. The lack of this information makes it difficult to investigate and remediate. The runtime behavior that enforces Microsoft Entra user authentication lives inside each agent's host (Copilot Studio, Microsoft 365 Copilot, Microsoft Foundry, custom code, or non-Microsoft platforms) and is therefore not directly observable from the directory. What *is* observable is the trail left in the Microsoft Entra sign-in logs whenever an agent and its callers do go through Microsoft Entra.

This check inspects the last 30 days of sign-in activity for each agent identity and classifies the agent by the strongest evidence found: a non-interactive agent sign-in where the subject is a real user is the strongest positive signal. An interactive user sign-in to the agent's blueprint is also positive evidence that users reach the agent through Microsoft Entra. Absence of either signal across the observation period means the platform can't confirm the agent enforces Microsoft Entra user authentication, and an accountable owner must verify the agent's host configuration directly.

**Remediation action**

- [Authenticate users in interactive agents](https://learn.microsoft.com/entra/agent-id/interactive-agent-authentication-authorization-flow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Request delegated user authorization for interactive agents](https://learn.microsoft.com/entra/agent-id/grant-agent-access-microsoft-365?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Agent users in Microsoft Entra Agent ID](https://learn.microsoft.com/entra/agent-id/agent-users?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Microsoft Entra Agent ID overview](https://learn.microsoft.com/entra/agent-id/what-is-microsoft-entra-agent-id?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Sign-in logs in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/monitoring-health/concept-sign-ins?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

