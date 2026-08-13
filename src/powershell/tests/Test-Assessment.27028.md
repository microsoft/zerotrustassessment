Forwarding Copilot Studio agent traffic to Global Secure Access provides visibility but doesn't restrict the web destinations agents can reach unless a web content filtering policy is linked to the baseline profile. The baseline profile is the supported enforcement path for agent traffic; security profiles linked to Conditional Access policies aren't supported for agents. Without an enabled, administrator-configured web content filtering policy on the baseline profile, an agent's HTTP node action or connector can reach web categories and URLs that the organization intended to block, giving a compromised or manipulated agent an unrestricted path to retrieve payloads, contact command-and-control infrastructure, or transmit data to an external destination. Linking the Copilot Studio web content filtering policy to the enabled baseline profile applies those restrictions tenant-wide to forwarded agent traffic.

**Remediation action**

- [Configure Secure Web and AI Gateway for Microsoft Copilot Studio agents](https://learn.microsoft.com/entra/global-secure-access/how-to-secure-web-ai-gateway-agents?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - Create a web content filtering policy for agent requirements and link it to the baseline profile.
- [Global Secure Access for Copilot Studio agents](https://learn.microsoft.com/power-platform/admin/security/secure-web-ai-gateway-agents?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) - Follow the Power Platform guidance for creating the Copilot Studio agent web repositories policy and linking it to the baseline profile.
- Review the linked policy in the Microsoft Entra admin center under **Global Secure Access** > **Secure** > **Security profiles** > **Baseline profile**.

<!--- Results --->
%TestResult%
