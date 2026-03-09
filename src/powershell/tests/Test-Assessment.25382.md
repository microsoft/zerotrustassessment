Without proper scoping of traffic forwarding profiles, organizations risk either exposing all users to security controls before infrastructure readiness is validated or inadvertently excluding users who should be protected.

Risks of improper scoping:

- **Too broad**: When profiles are assigned to "all users" without deliberate planning, a misconfiguration could disrupt network connectivity for the entire organization simultaneously.
- **Too narrow**: If profiles are scoped too narrowly or assignments are incomplete, a subset of users operates outside the security perimeter, creating gaps that threat actors can exploit.
- **Unmonitored access**: Attackers who compromise devices belonging to unassigned users can access resources without traffic being inspected, logged, or subject to security policies.

Proper scoping ensures controlled rollout—starting with pilot groups to validate functionality, then expanding to broader populations—while maintaining visibility into which users are protected.

**Remediation action**

- Assign users and groups to traffic forwarding profiles. For more information, see [Manage users and groups assignment](https://learn.microsoft.com/entra/global-secure-access/how-to-manage-users-groups-assignment?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).
<!--- Results --->
%TestResult%

