Threat actors increasingly target workload identities (applications, service principals, and managed identities) because they lack human factors and often use long-lived credentials. A compromise often looks like the following path:

1. Credential abuse or key theft.
1. Non-interactive sign-ins to cloud resources.
1. Lateral movement via app permissions.
1. Persistence through new secrets or role assignments.

Microsoft Entra ID Protection continuously generates risky workload identity detections and flags sign-in events with risk state and detail. Risky workload identity sign-ins that aren’t triaged (confirmed compromised, dismissed, or marked safe), detection fatigue, and a large alert backlog can be challenging for IT admins to manage. This heavy workload can let repeated malicious access, privilege escalation, and token replay to continue to go unnoticed. To make the workload manageable, address risky workload identity sign-ins in two parts:

- Close the loop: Triage sign-ins and record an authoritative decision on each risky event.
- Drive containment: Disable the service principal, rotate credentials, or revoke sessions.

**Remediation action**

- [Investigate risky workload identities and perform appropriate remediation ](https://learn.microsoft.com/en-us/entra/id-protection/concept-workload-identity-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Dismiss workload identity risks when determined to be false positives](https://learn.microsoft.com/graph/api/riskyserviceprincipal-dismiss?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
- [Confirm compromised workload identities when risks are validated](https://learn.microsoft.com/graph/api/riskyserviceprincipal-confirmcompromised?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

