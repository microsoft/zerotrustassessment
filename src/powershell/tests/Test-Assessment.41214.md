Playbooks are Azure Logic Apps workflows authored against the Microsoft Sentinel connector and the Microsoft Sentinel Incident / Entity / Alert triggers. They execute the orchestrated response actions a SOC needs at machine speed: disable a Microsoft Entra user account, revoke active sessions, block an IP at Defender for Endpoint or the perimeter firewall, isolate a device, post to Microsoft Teams, open a ServiceNow ticket, run a containment script. An automation rule wires the trigger condition (which incidents) to the response (which playbook), closing the SOAR loop. Without a playbook-executing automation rule, response remains entirely manual: a credentialed-account-takeover incident requires a human analyst to acknowledge, triage, locate the affected user, and manually disable in Microsoft Entra, during which time the threat actor continues collection, credential access, and lateral movement. Industry data places median manual containment time at hours; orchestrated containment is sub-minute. The check confirms at least one enabled automation rule has an action whose actionType is RunPlaybook and whose actionConfiguration.logicAppResourceId references a Logic App resource that exists.

**Remediation action**

- [Automate and run Microsoft Sentinel playbooks](https://learn.microsoft.com/azure/sentinel/automation/run-playbooks)
- [Create and manage Microsoft Sentinel playbooks](https://learn.microsoft.com/azure/sentinel/automation/create-playbooks)
- [Use playbooks with automation rules](https://learn.microsoft.com/azure/sentinel/tutorial-respond-threats-playbook)

<!--- Results --->
%TestResult%
