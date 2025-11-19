Letting group owners consent to applications in Microsoft Entra ID creates a lateral escalation path that lets threat actors persist and steal data without admin credentials. If an attacker compromises a group owner account, they can register or use a malicious application and consent to high-privilege Graph API permissions scoped to the group. Attackers can potentially read all Teams messages, access SharePoint files, or manage group membership. This consent action creates a long-lived application identity with delegated or application permissions. The attacker maintains persistence with OAuth tokens, steals sensitive data from team channels and files, and impersonates users through messaging or email permissions. Without centralized enforcement of app consent policies, security teams lose visibility, and malicious applications spread under the radar, enabling multi-stage attacks across collaboration platforms.

**Remediation action**
Configure preapproval of Resource-Specific Consent (RSC) permissions.
- [Preapproval of RSC permissions](https://learn.microsoft.com/microsoftteams/platform/graph-api/rsc/preapproval-instruction-docs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)
<!--- Results --->
%TestResult%

