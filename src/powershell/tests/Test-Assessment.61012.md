When an organization enables AI agents in Microsoft Entra, [agent identities](https://learn.microsoft.com/entra/agent-id/agent-identities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) can access tokens to access organizational resources without an interactive user session and device, location, or MFA signals that classic Conditional Access uses to make trust decisions for human users. Microsoft Entra ID Protection for agents continuously evaluates each agent's behavior and emits a risk level that is driven by signals such as:

- Unfamiliar resource access (the agent reaches outside its established patterns)
- Sign-in spikes (token replay or automation abuse)
- Failed-access probing (an attacker enumerating resources with the agent's credentials)
- Sign-ins by risky users during delegated authentication (an attacker leveraging a compromised user account)
- Admin-confirmed compromise (a security admin manually flags the agent as compromised)

Without a Conditional Access policy that consumes the risk level and blocks token issuance, the platform can just record that an agent is high risk while continuing to mint the very tokens the adversary needs. The logs say "compromised" while the resource still says "yes." A risk-based Conditional Access policy that blocks high-risk agent identities is required to close this gap between detection and enforcement.

**Remediation action**

- [ID Protection for agents](https://learn.microsoft.com/entra/id-protection/concept-risky-agents?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Conditional Access for agent identities](https://learn.microsoft.com/entra/identity/conditional-access/agent-id?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

