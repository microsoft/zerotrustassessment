Attack surface reduction rules block the specific behaviors that commodity malware, fileless threats, and human-operated intrusion sets reuse across campaigns. Each rule targets a narrow, well-documented execution pattern such as document applications creating child processes, script interpreters launching downloaded content, unsigned binaries performing bulk file operations, or processes attempting to read credential stores. When the rules are not set to block mode, an adversary who delivers a payload to an endpoint can exercise these patterns freely because no preventive control intervenes at the behavior layer. Audit mode records the activity but does not stop it, which means the security operations team sees the evidence only after the damage is done. The risk compounds because ASR rules operate as a set: leaving even a small number of rules in audit or disabled state creates predictable gaps that an attacker can target, knowing that the specific behavior will not be blocked. If you are new to ASR, Microsoft recommends starting in audit mode to understand the impact in your environment before switching rules to block - audit mode is a starting point, not the end state.

**Remediation action**

- [Attack surface reduction rules deployment](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-deployment?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Plan attack surface reduction rules deployment](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-deployment-plan?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Test attack surface reduction rules](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-deployment-test?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Enable attack surface reduction rules](https://learn.microsoft.com/en-us/defender-endpoint/enable-attack-surface-reduction?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Attack surface reduction rules reference](https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)

<!--- Results --->
%TestResult%
