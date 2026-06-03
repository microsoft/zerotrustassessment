Microsoft Sentinel is a cloud-native SIEM that correlates security signals from across your environment into incidents your SOC can act on. AI workloads generate events across identity, cloud posture, and threat protection simultaneously — a central workspace is the only place those signals can be assembled into a coherent incident. This check verifies Sentinel is onboarded to at least one Log Analytics workspace, which every other AI threat detection control in this pillar depends on.

When Microsoft Sentinel is not onboarded to a Log Analytics workspace, security signals from AI workloads land in isolated product portals with no central point of correlation. Threat actors who compromise an agent identity can exploit this fragmentation because each product sees only its own slice of the attack — an anomalous Entra sign-in, a bulk Graph API call, and a Defender for AI Services alert each get triaged in isolation with no shared context. Without Sentinel, the organization cannot assemble the cross-product pattern that would reveal the full attack chain and trigger an automated response.

**Remediation action**

- [What is Microsoft Sentinel?](https://learn.microsoft.com/azure/sentinel/overview)
- [Quickstart: Onboard Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/quickstart-onboard)
- [Design your Microsoft Sentinel workspace architecture](https://learn.microsoft.com/azure/sentinel/design-your-workspace-architecture)
- [Sentinel onboarding states — Create (REST API)](https://learn.microsoft.com/rest/api/securityinsights/sentinel-onboarding-states/create)

<!--- Results --->
%TestResult%
