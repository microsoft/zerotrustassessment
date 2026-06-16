The Agent 365 data connector brings AI agent telemetry into Microsoft Sentinel, including agent invocations, tool calls, and grounding source access. Without it, there is no way to see whether an AI agent was involved in a session, what it did, or what data it accessed. This check verifies the connector is installed and connected on at least one Sentinel-onboarded workspace.

When Agent 365 telemetry is not forwarded to Sentinel, the workspace has no visibility into what AI agents ran, what tools they invoked, or what data they accessed. Threat actors who manipulate an agent through prompt injection can exploit this blind spot because their entire footprint — tool invocations, grounding source queries, and induced outputs — exists only in the agent execution layer, which is invisible to the SIEM. Without this connector, the organization cannot distinguish whether a data access event was performed by a human user or by an agent operating under attacker control.

**Remediation action**

- [A365 Observability solution for Sentinel — Marketplace listing](https://marketplace.microsoft.com/en-us/product/saas/azuresentinel.azure-sentinel-solution-a365observability)
- [A365 Observability GitHub source and release notes](https://github.com/Azure/Azure-Sentinel/tree/master/Solutions/A365%20Observability)
- [Install solutions from the Microsoft Sentinel Content Hub](https://learn.microsoft.com/azure/sentinel/sentinel-solutions-deploy)
- [Microsoft Sentinel data connectors overview](https://learn.microsoft.com/azure/sentinel/connect-data-sources)

<!--- Results --->
%TestResult%
