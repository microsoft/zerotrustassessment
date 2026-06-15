If you let group owners consent to applications in Microsoft Entra ID, you create a lateral escalation path that bad actors can use to persist and steal data without admin credentials. If an attacker compromises a group owner account, they can register or use a malicious application and consent to high-privilege Graph API permissions scoped to the group. Attackers can potentially read all Teams messages, access SharePoint files, or manage group membership. This consent action creates a long-lived application identity with delegated or application permissions. The attacker maintains persistence with OAuth tokens, steals sensitive data from team channels and files, and impersonates users through messaging or email permissions. Without centralized enforcement of app consent policies, security teams lose visibility, and malicious applications spread under the radar, enabling multistage attacks across collaboration platforms.

**Remediation action**

Set your organization's Resource-Specific Consent (RSC) configuration to `EnabledForPreApprovedAppsOnly` and create preapproval policies for each app that requires RSC permissions. Don't use the default `ManagedByMicrosoft` state.
- [Enable RSC for a specific set of apps only](https://learn.microsoft.com/microsoftteams/platform/graph-api/rsc/preapproval-instruction-docs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-rsc-for-a-specific-set-of-apps-only)
<!--- Results --->
%TestResult%

