The Microsoft 365 Agent Registry is the tenant-scoped catalogue that lists every declarative agent, connected agent, and custom Copilot extension that has been published to users in the tenant. Its role is to provide the central answer to two questions that security teams must be able to answer at any moment: "which agents are operating inside our Microsoft 365 environment" and "who are they available to". Without a populated Agent Registry view, those questions cannot be answered consistently — agent deployments proliferate through individual authoring and sideloading paths, each with its own audit signal, and no single surface enumerates them. Threat actors exploit this inventory gap by publishing agents that impersonate legitimate productivity tools, by distributing agents to broad audiences when only a narrow scope was approved, and by relying on the visibility asymmetry to keep malicious or retired agents running long after they should have been removed. Confirming that the Agent Registry returns results — and, in follow-up specs, that those results match the organisation's approved inventory — is the baseline control that makes every downstream agent-governance check possible.

**Remediation action**

- [Manage agents for Microsoft 365 Copilot](https://learn.microsoft.com/microsoft-365-copilot/extensibility/agent-registry)
- [Publish and deploy an agent](https://learn.microsoft.com/microsoft-365-copilot/extensibility/build-agent)
- [Governance of agents in Microsoft 365 Copilot](https://learn.microsoft.com/microsoft-365-copilot/extensibility/governance)
- [List Copilot packages (Microsoft Graph beta)](https://learn.microsoft.com/microsoft-365-copilot/extensibility/api/admin-settings/package/copilotpackages-list)

<!--- Results --->
%TestResult%
