Allowing group owners to consent to applications in Entra ID introduces a lateral escalation path that enables threat actors to persist and exfiltrate data without administrative credentials. If a group owner account is compromised, the attacker can register or use a malicious application and consent to high-privilege Graph API permissions scoped to the group, such as reading all Teams messages, accessing SharePoint files, or managing group membership. This consent action establishes a long-lived application identity with delegated or application permissions. The attacker maintains persistence via OAuth tokens, harvests sensitive data from team channels and files, and impersonates users through messaging or email permissions. Without centralized enforcement of app consent policies, security teams lose visibility, and malicious applications proliferate under the radar, enabling multi-stage attacks across collaboration platforms.

**Remediation action**

Configure preapproval of RSC permissions.
- [Preapproval of RSC permissions](https://learn.microsoft.com/microsoftteams/platform/graph-api/rsc/preapproval-instruction-docs)
<!--- Results --->
%TestResult%
