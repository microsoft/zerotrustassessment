# Analyze Potentially Malicious Files, Scripts, and Code with Microsoft Security Copilot

**Implementation Effort:** Low — Security teams only need to enable and use built‑in Security Copilot capabilities, requiring targeted actions rather than ongoing programs.

**User Impact:** Low — Only administrators and security analysts need to take action; no notification or action is required from end users.

## Overview
Microsoft Security Copilot provides AI-driven analysis for suspicious files, scripts, and command lines within the Microsoft Defender portal. Copilot can summarize file behavior, highlight suspicious elements, display certificates, API calls, strings, and provide contextual detection information to speed up investigation efforts. It also analyzes scripts by identifying malicious patterns, evaluating behavior, and producing security assessments with recommended remediation guidance. This accelerates the investigation process and reduces the time to identify threats.

If this capability is not deployed, analysts must rely on manual reverse-engineering and static/dynamic analysis processes, which take more time and increase the risk that threats remain undetected, spread laterally, or exfiltrate data.

**Zero Trust Connection — Assume Breach:**  
This aligns with the “assume breach” principle by continuously validating potentially harmful code and enhancing threat detection visibility through AI-powered analysis.

## Reference
- [File analysis with Microsoft Copilot in Microsoft Defender](https://learn.microsoft.com/en-us/defender-xdr/copilot-in-defender-file-analysis)  
- [Script analysis with Microsoft Copilot in Microsoft Defender](https://learn.microsoft.com/en-us/defender-xdr/security-copilot-m365d-script-analysis)  
- [Investigate an incident's malicious script](https://learn.microsoft.com/en-us/copilot/security/investigate-incident-malicious-script)
