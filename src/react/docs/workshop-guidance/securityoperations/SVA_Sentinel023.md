# Hunt for Threats and Investigate Incidents

**Implementation Effort:** Medium - This requires ongoing time and resource commitment from security operations teams to create hypotheses, conduct hunts, and act on findings.

**User Impact:** Low - A subset of non-privileged users, mainly security analysts, need to take action or be notified of changes.

## Overview
The unified security operations portal brings together Microsoft Sentinel and Microsoft Defender XDR into a single workspace, allowing security teams to detect, investigate, and respond to threats more efficiently. It provides advanced tools like guided threat hunting, Kusto Query Language (KQL), and Security Copilot to help analysts uncover suspicious activity across endpoints, identities, cloud apps, and more. Incidents are automatically correlated and enriched with evidence, making investigations faster and more complete.

This capability supports the Zero Trust principle of **"Assume Breach"** by enabling continuous monitoring, proactive threat detection, and rapid response. Without this integration, organizations may miss early warning signs of attacks, delay containment, and increase the risk of lateral movement by adversaries.

## Reference
- [Conduct end-to-end threat hunting with Hunts - Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/hunts)
- [Investigate incidents in the Microsoft Defender portal](https://learn.microsoft.com/en-us/defender-xdr/incidents-overview?toc=%2Funified-secops-platform%2Ftoc.json&bc=%2Funified-secops-platform%2Fbreadcrumb%2Ftoc.json&tabs=defender-portal)
- [Hunting capabilities in Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/hunting)
