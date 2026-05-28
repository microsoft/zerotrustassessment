Defender CSPM is the plan in Microsoft Defender for Cloud that scans your subscriptions, inventories your AI workloads, and surfaces risks through security recommendations and attack path analysis. Without it, there is no AI inventory, no flagging of misconfigured AI services, and no modeling of how an attacker could reach sensitive grounding data through an exposed endpoint. This check verifies the plan is enabled on every subscription that hosts AI workloads.

When Defender CSPM is not enabled on a subscription hosting AI workloads, misconfigured AI service accounts — publicly exposed, secured only by API keys, lacking private endpoints — are never surfaced as risks and remain accessible indefinitely. Threat actors can exploit this visibility gap because the attack path from an exposed AI endpoint to the sensitive grounding or fine-tuning data it connects to has never been modeled by defenders. Without Defender CSPM, the organization cannot identify those paths before an attacker follows them.

**Source:** [Overview - AI security posture management](https://learn.microsoft.com/azure/defender-for-cloud/ai-security-posture)

**Remediation action**

- [Enable Microsoft Defender for Cloud CSPM plan](https://learn.microsoft.com/azure/defender-for-cloud/tutorial-enable-cspm-plan)
- [AI security posture management in Defender for Cloud](https://learn.microsoft.com/azure/defender-for-cloud/ai-security-posture)
- [Enable plans programmatically (\PUT .../pricings/CloudPosture`)](https://learn.microsoft.com/rest/api/defenderforcloud/pricings/update)

<!--- Results --->
%TestResult%
