While Global Administrators can assign themselves access to Azure subscriptions to regain access, or grant access to other users, removing standing permissions reduces the attack surface and ensures that such escalation is a deliberate and auditable action. If a Global Administrator account is compromised or misused, pre-existing access to all subscriptions allows the attacker to immediately enumerate resources, modify configurations, assign roles, and exfiltrate sensitive data. In contrast, requiring explicit elevation introduces detectable signals, and reduces attacker velocity. This constraint forces high-impact operations through observable control points, making malicious activity easier to detect and contain before widespread impact occurs.

**Remediation action**

Remove elevated access as documented here:
- [Elevate access to manage all Azure subscriptions and management groups](https://learn.microsoft.com/azure/role-based-access-control/elevate-access-global-admin?tabs=azure-portal%2Centra-audit-logs#step-2-remove-elevated-access)
<!--- Results --->
%TestResult%
