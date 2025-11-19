Threat actors who compromise a permanently assigned privileged account (e.g., Global Administrator or Privileged Role Administrator) gain continuous, uninterrupted access to high-impact directory operations. This extended dwell time enables attackers to more easily establish persistent backdoors, delete critical data and security configurations, disable monitoring systems, and register malicious applications for data exfiltration and lateral movement. These actions can result in full organizational disruption, widespread data compromise, and total loss of operational control over the tenant. Microsoft Entra PIM’s eligible role assignment model narrows escalation pathways, constrains attacker dwell time and provides the option of role elevation approval workflows.

**Remediation action**
- [Use Privileged Identity Management to manage privileged Microsoft Entra roles](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-getting-started)
- [Manage emergency access admin accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access) 

<!--- Results --->
%TestResult%
