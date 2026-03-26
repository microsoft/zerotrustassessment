# View Incident Summaries and Use Guided Response to Remediate

**Implementation Effort:** Low — Security administrators only need to perform targeted actions in Microsoft Defender XDR to view AI‑generated summaries and guided remediation steps.  
**User Impact:** Low — Actions occur only within the admin/security team; no non‑privileged users are affected or notified.

## Overview
Security Copilot in Microsoft Defender XDR uses generative AI to summarize security incidents and provide guided remediation actions. Defender XDR automatically produces a clear, high‑value summary of the incident attack story, enabling analysts to understand what happened quickly. Security Copilot also uses AI and machine learning to contextualize the incident and generate recommended steps analysts can follow to investigate and remediate threats. These summaries and guided steps appear automatically in the Security Copilot pane within the attack story, helping teams reduce investigation time and improve response consistency. 

If not implemented, analysts must manually correlate data across multiple Defender components, slowing down response and increasing the risk of delayed containment.

**Zero Trust Principle:** *Assume Breach* — This capability helps reduce the blast radius by accelerating detection, investigation, and remediation.

### Where to Enable / Configure
You can access these capabilities directly in the **Microsoft Defender portal**:  
1. Open **Microsoft Defender XDR**  
2. Go to **Incidents**  
3. Select an incident  
4. The **Security Copilot** pane on the right displays the summary and guided response steps  


## Reference
- [Summarize an incident with Microsoft Copilot in Microsoft Defender](https://learn.microsoft.com/en-us/defender-xdr/security-copilot-m365d-incident-summary)  
- [Triage and investigate incidents with guided responses](https://learn.microsoft.com/en-us/defender-xdr/security-copilot-m365d-guided-response)  
- [Incident response and remediation with Security Copilot](https://learn.microsoft.com/en-us/copilot/security/use-case-incident-response-remediation)
