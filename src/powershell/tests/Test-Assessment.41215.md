Microsoft Security Copilot is a generative AI assistant that compresses analyst triage time by summarizing incidents, scripts, and entity context across Microsoft Defender, Microsoft Sentinel, Microsoft Entra, Microsoft Intune, and Microsoft Purview. The service runs only when the tenant has at least one provisioned Security Compute Unit (SCU) capacity attached to a workspace; without a capacity, neither the standalone portal nor the embedded "Ask Copilot" experiences in Defender XDR are available, and SOC analysts fall back to manual investigation. From a kill-chain perspective, slower analyst workflow is a defender-velocity gap: once a threat actor lands Initial Access, they iterate quickly through Discovery, Credential Access, Lateral Movement, Collection, and Exfiltration; every additional minute of mean-time-to-respond (MTTR) extends the dwell window in which those tactics can complete. Provisioning SCUs is the prerequisite that unlocks AI-assisted triage and is therefore the gating control for every downstream Security Copilot best practice (incident summarization, guided response, script analysis, identity and device review).

**Remediation action**

- [Onboarding to Security Copilot for non-Microsoft 365 E5 customers](https://learn.microsoft.com/copilot/security/manual-onboarding)
- [Learn about Security Copilot for Microsoft 365 E5 included customers](https://learn.microsoft.com/copilot/security/security-copilot-inclusion)

<!--- Results --->
%TestResult%
