Defender for Cloud's AI threat protection plan detects attacks against Azure OpenAI and Azure AI Services accounts and must be enabled at the subscription level. A subscription without the plan enabled emits no AI threat alerts, regardless of how Sentinel or Defender XDR is configured downstream. This check verifies the plan is active on every subscription that hosts Azure OpenAI or Azure AI Services accounts.

When the plan is not enabled on every subscription, the SOC cannot determine whether a silent subscription is clean or simply unmonitored — there is no way to tell the difference. Threat actors who target an unmonitored AI endpoint can carry out attacks without generating a single alert. Without coverage on every subscription, the organization cannot confirm that any of its AI workloads are protected.

**Source:** [Overview - AI threat protection](https://learn.microsoft.com/azure/defender-for-cloud/ai-threat-protection)

## Remediation resources

- [Enable threat protection for AI services (step-by-step)](https://learn.microsoft.com/azure/defender-for-cloud/ai-onboarding)
- [Overview — AI threat protection](https://learn.microsoft.com/azure/defender-for-cloud/ai-threat-protection)
- [Defender for AI Services alert reference](https://learn.microsoft.com/azure/defender-for-cloud/alerts-ai-workloads)
- [Microsoft.Security/pricings REST reference (read / set the `AI` plan)](https://learn.microsoft.com/rest/api/defenderforcloud/pricings/get)

<!--- Results --->
%TestResult%
