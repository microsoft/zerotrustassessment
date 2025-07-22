Inviting external guests is beneficial for organizational collaboration. However, in the absence of an assigned internal sponsor for each guest, these accounts might persist within the directory without clear accountability. This oversight creates a risk: threat actors could potentially compromise an unused or unmonitored guest account, and then establish an initial foothold within the tenant. Once granted access as an apparent "legitimate" user, an attacker might explore accessible resources and attempt privilege escalation, which could ultimately expose sensitive information or critical systems. An unmonitored guest account might therefore become the vector for unauthorized data access or a significant security breach. A typical attack sequence might use the following pattern, all achieved under the guise of a standard external collaborator:

1. Initial access gained through compromised guest credentials
1. Persistence due to a lack of oversight.
1. Further escalation or lateral movement if the guest account possesses group memberships or elevated permissions.
1. Execution of malicious objectives. 

Mandating that every guest account is assigned to a sponsor directly mitigates this risk. Such a requirement ensures that each external user is linked to a responsible internal party who is expected to regularly monitor and attest to the guest's ongoing need for access. The sponsor feature within Microsoft Entra ID supports accountability by tracking the inviter and preventing the proliferation of "orphaned" guest accounts. When a sponsor manages the guest account lifecycle, such as removing access when collaboration concludes, the opportunity for threat actors to exploit neglected accounts is substantially reduced. This best practice is consistent with Microsoft’s guidance to require sponsorship for business guests as part of an effective guest access governance strategy. It strikes a balance between enabling collaboration and enforcing security, as it guarantees that each guest user's presence and permissions remain under ongoing internal oversight.

**Remediation action**
- For each guest user that has no sponsor, assign a sponsor in Microsoft Entra ID.
    - [Add a sponsor to a guest user in the Microsoft Entra admin center](https://learn.microsoft.com/en-us/entra/external-id/b2b-sponsors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
    - [Add a sponsor to a guest user using Microsoft Graph](https://learn.microsoft.com/graph/api/user-post-sponsors?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)<!--- Results --->
%TestResult%

