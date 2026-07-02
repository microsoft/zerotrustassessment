Automation rules are Sentinel's central control plane for incident handling: they fire on incident creation, incident update, or alert creation, evaluate conditions against incident properties (severity, tactics, entities, analytics rule of origin), and execute one or more actions — assign owner, change status, change severity, add tags, suppress duplicates, and run a playbook. Without automation rules, every incident is processed manually by a tier-1 analyst from raw queue: the analyst must triage, assign, set severity, write context, and decide whether to escalate, drastically inflating the mean-time-to-acknowledge (MTTA) and mean-time-to-respond (MTTR). The detection-blind-spot risk is operational: a high-severity incident from a high-fidelity rule (for example, a Defender for Identity DCSync alert correlating with the Microsoft Threat Intelligence map for a known ransomware affiliate; tactic, technique - DCSync) sits unhandled in queue while the threat actor proceeds with privilege escalation and lateral movement. Automation rules also enable noise reduction (auto-close known-benign alerts) so analyst attention concentrates on real incidents. The check confirms at least one automation rule exists. Mature deployments maintain rules that route by analytics-rule, severity, or entity tag.

**Remediation action**

- [Create and use Microsoft Sentinel automation rules to manage response](https://learn.microsoft.com/azure/sentinel/create-manage-use-automation-rules)
- [Automate threat response in Microsoft Sentinel with automation rules](https://learn.microsoft.com/azure/sentinel/automate-incident-handling-with-automation-rules)

<!--- Results --->
%TestResult%
