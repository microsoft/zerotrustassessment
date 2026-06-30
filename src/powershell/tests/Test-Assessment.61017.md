Defender for Cloud's AI threat protection plan detects attacks against Azure OpenAI and Azure AI Services accounts in real time. For those alerts to reach Microsoft Sentinel, two conditions must be met: the plan must be enabled at the subscription level, and exactly one connector path must forward alerts to the workspace — running more than one path simultaneously produces duplicate incidents. This check verifies both conditions are met.

When the Defender for AI Services plan is not enabled, attacks against Azure OpenAI and Azure AI Services accounts generate no security alerts regardless of how Sentinel is configured. Threat actors who target AI endpoints with prompt injection, jailbreak techniques, or data extraction queries can exploit this absence because there is no detection layer to observe or interrupt their activity. Without this plan, the organization cannot detect any of the AI-specific attacks in the [Defender for AI Services alert reference](https://learn.microsoft.com/azure/defender-for-cloud/alerts-ai-workloads) — prompt injection, jailbreak attempts, wallet exhaustion, and sensitive data exposure all go unobserved.

**Sources:** [Overview - AI threat protection](https://learn.microsoft.com/azure/defender-for-cloud/ai-threat-protection) and [Connect Defender for Cloud to Microsoft Sentinel](https://learn.microsoft.com/azure/sentinel/connect-defender-for-cloud)

**Remediation action**

- [Defender for AI Services overview](https://learn.microsoft.com/azure/defender-for-cloud/ai-threat-protection)
- [Defender for AI Services alert reference](https://learn.microsoft.com/azure/defender-for-cloud/alerts-ai-workloads)
- [Enable Defender for AI Services pricing plan](https://learn.microsoft.com/azure/defender-for-cloud/ai-onboarding)
- [Ingest Microsoft Defender for Cloud alerts to Microsoft Sentinel (Tenant‑based and Legacy connectors)](https://learn.microsoft.com/azure/sentinel/connect-defender-for-cloud)
- [Ingest Microsoft Defender for Cloud incidents with Microsoft Defender XDR integration](https://learn.microsoft.com/azure/sentinel/ingest-defender-for-cloud-incidents)
- [Microsoft Sentinel + Defender XDR: preventing duplicate Defender for Cloud alerts](https://learn.microsoft.com/azure/defender-for-cloud/concept-integration-365#microsoft-sentinel-customers)

<!--- Results --->
%TestResult%
