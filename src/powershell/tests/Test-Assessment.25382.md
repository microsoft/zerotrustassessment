Without proper scoping of traffic forwarding profiles, organizations risk either exposing all users to security controls before infrastructure readiness is validated or inadvertently excluding users who should be protected. When traffic forwarding profiles are assigned to "all users" without deliberate planning, a misconfiguration in the Global Secure Access infrastructure could disrupt network connectivity for the entire organization simultaneously. Conversely, if profiles are scoped too narrowly or assignments are incomplete, a subset of users operates outside the security perimeter, creating gaps that threat actors can exploit. An attacker who compromises a device belonging to an unassigned user can access resources without the traffic being inspected, logged, or subject to security policies. The threat actor can then use this unmonitored access path for reconnaissance, lateral movement, or data exfiltration while remaining invisible to the organization's Security Service Edge controls.  

Proper scoping ensures that traffic forwarding profiles are rolled out in a controlled manner—starting with pilot groups to validate functionality, then expanding to broader populations—while maintaining visibility into which users are protected and which are not.  

Organizations should explicitly decide whether to assign profiles to all users or to specific groups, document that decision, and periodically review assignments to ensure alignment with security requirements. 

**Remediation action**

- [Review profile assignments: Navigate to Global Secure Access > Connect > Traffic forwarding, select View for user and group assignments](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-users-groups-assignment)
- [Assign specific users/groups: For controlled rollout, assign pilot groups before enabling for all users.](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-users-groups-assignment#how-to-assign-users-and-group-to-a-traffic-profile)
- [Enable for all users: Once validated, toggle "Assign to all users" for production deployment.](https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-users-groups-assignment#assign-the-traffic-profile-to-all-users)

<!--- Results --->
%TestResult%
