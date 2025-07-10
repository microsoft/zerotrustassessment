// Use quicktype (Paste JSON as Code) VSCode extension to generate this typescript interface from ZeroTrustAssessmentReport.json created by PowerShell

export interface ZeroTrustAssessmentReport {
  ExecutedAt: string;
  TenantId: string;
  TenantName: string;
  Domain: string;
  Account: string;
  CurrentVersion: string;
  LatestVersion: string;
  Tests: Test[];
  TenantInfo: TenantInfo;
  TestResultSummary: TestResultSummaryData;
  EndOfJson: string;
}

export interface TenantInfo {
  OverviewCaMfaAllUsers: SankeyData;
  OverviewCaDevicesAllUsers: SankeyData;
  OverviewAuthMethodsPrivilegedUsers: SankeyData;
  OverviewAuthMethodsAllUsers: SankeyData;
}

export interface TestResultSummaryData {
  IdentityPassed: number;
  IdentityTotal: number;
  DevicesPassed: number;
  DevicesTotal: number;
  DataPassed: number;
  DataTotal: number;
}
export interface SankeyData {
  nodes: SankeyDataNode[];
  description: string;
}
export interface SankeyDataNode {
  value: number;
  source: string;
  target: string;
}

export interface Test {
  TestTitle: string;
  TestRisk: string;
  TestAppliesTo: string[];
  TestImpact: string;
  TestCategory: string | null;
  TestImplementationCost: string;
  SkippedReason: string | null;
  TestResult: string;
  TestSkipped: string;
  TestStatus: string;
  TestTags: string[];
  TestId: string;
  TestDescription: string;
}

export const reportData: ZeroTrustAssessmentReport = {
  "ExecutedAt": "2025-07-10T18:29:28.812666+10:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora Inc.",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "0.9.0",
  "LatestVersion": "0.9.0",
  "TestResultSummary": {
    "IdentityPassed": 16,
    "IdentityTotal": 47,
    "DevicesPassed": 0,
    "DevicesTotal": 0,
    "DataPassed": 0,
    "DataTotal": 0
  },
  "Tests": [
    {
      "TestTags": [
        "Application"
      ],
      "TestSkipped": "",
      "TestCategory": "Monitoring",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "High priority Microsoft Entra recommendations are addressed",
      "TestRisk": "High",
      "TestId": "22124",
      "TestResult": "\nFound 5 unaddressed high priority Entra recommendations.\n\n\n## Unaddressed high priority Entra recommendations\n\n| Display Name | Status | Insights |\n| :--- | :--- | :--- |\n| Protect all users with a user risk policy  | active | You have 2 of 61 users that don’t have a user risk policy enabled.  |\n| Protect all users with a sign-in risk policy | active | You have 61 of 61 users that don't have a sign-in risk policy turned on. |\n| Ensure all users can complete multifactor authentication | active | You have 46 of 61 users that aren’t registered with MFA.  |\n| Enable policy to block legacy authentication | active | You have 2 of 61 users that don’t have legacy authentication blocked.  |\n| Require multifactor authentication for administrative roles | active | You have 5 of 11 users with administrative roles that aren’t registered and protected with MFA. |\n\n\n",
      "TestDescription": "Leaving high-priority Microsoft Entra recommendations unaddressed can create a gap in an organization’s security posture, offering threat actors opportunities to exploit known weaknesses. Not acting on these items might result in an increased attack surface area, suboptimal operations, or poor user experience. \n\n**Remediation action**\n\n- [Address all high priority recommendations in the Microsoft Entra admin center](https://learn.microsoft.com/entra/identity/monitoring-health/overview-recommendations?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-does-it-work)\n",
      "TestStatus": "Failed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Application"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Inactive applications don’t have highly privileged built-in roles",
      "TestRisk": "High",
      "TestId": "21771",
      "TestResult": "\nFound 1 inactive applications with privileged Entra built-in roles\n\n\n## Apps with privileged Entra built-in roles\n\n| | Name | Role | Assignment | App owner tenant | Last sign in|\n| :--- | :--- | :--- | :--- | :--- | :--- |\n| ❌ | [AppRolePimAutomationTestParentAcc19Feb22](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d22f071d-e8d3-41fc-a516-b29753cdd1f6/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | Application Administrator | Permanent |  | Unknown | \n\n\n",
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they're legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable inactive privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases. If so, [analyze if a OAuth2 permission is a better fit](https://learn.microsoft.com/entra/identity-platform/v2-app-types?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Privileged access",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Permissions to create new tenants are limited to the Tenant Creator role",
      "TestRisk": "High",
      "TestId": "21787",
      "TestResult": "\nNon-privileged users are allowed to create tenants.\n\n\n\n",
      "TestDescription": "A threat actor or a well-intentioned but uninformed employee can create a new Microsoft Entra tenant if there are no restrictions in place. By default, the user who creates a tenant is automatically assigned the Global Administrator role. Without proper controls, this action fractures the identity perimeter by creating a tenant outside the organization's governance and visibility. It introduces risk though a shadow identity platform that can be exploited for token issuance, brand impersonation, consent phishing, or persistent staging infrastructure. Since the rogue tenant might not be tethered to the enterprise’s administrative or monitoring planes, traditional defenses are blind to its creation, activity, and potential misuse.\n\n**Remediation action**\n\nEnable the **Restrict non-admin users from creating tenants** setting. For users that need the ability to create tenants, assign them the Tenant Creator role. You can also review tenant creation events in the Microsoft Entra audit logs.\n\n- [Restrict member users' default permissions](https://learn.microsoft.com/entra/fundamentals/users-default-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#restrict-member-users-default-permissions)\n- [Assign the Tenant Creator role](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#tenant-creator)\n- [Review tenant creation events](https://learn.microsoft.com/entra/identity/monitoring-health/reference-audit-activities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#core-directory). Look for OperationName==\"Create Company\", Category == \"DirectoryManagement\".\n",
      "TestStatus": "Failed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Credential management",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Migrate from legacy MFA and self service password reset (SSPR) policies",
      "TestRisk": "High",
      "TestId": "21804",
      "TestResult": "\nFound weak authentication methods that are still enabled.\n\n## Weak authentication methods\n| Method ID | Is method weak? | State |\n| :-------- | :-------------- | :---- |\n| Sms | Yes | enabled |\n| Voice | Yes | disabled |\n\n\n",
      "TestDescription": "When weak authentication methods like SMS and voice calls remain enabled in Microsoft Entra ID, threat actors can exploit these vulnerabilities through multiple attack vectors. Initially, attackers often conduct reconnaissance to identify organizations using these weaker authentication methods through social engineering or technical scanning. They then execute initial access through credential stuffing attacks, password spraying, or phishing campaigns targeting user credentials. Once basic credentials are compromised, threat actors use the inherent weaknesses in SMS and voice-based authentication - SMS messages can be intercepted through SIM swapping attacks, SS7 network vulnerabilities, or malware on mobile devices, while voice calls are susceptible to voice phishing (vishing) and call forwarding manipulation. With these weak second factors bypassed, attackers achieve persistence by registering their own authentication methods. This enables privilege escalation as compromised accounts can be used to target higher-privileged users through internal phishing or social engineering. Finally, threat actors achieve their objectives through data exfiltration, lateral movement to critical systems, or deployment of other malicious tools, all while maintaining stealth by using legitimate authentication pathways that appear normal in security logs. \n\n**Remediation action**\n\n- [Enable combined security information registration](https://learn.microsoft.com/entra/identity/authentication/howto-registration-mfa-sspr-combined?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [How to migrate MFA and SSPR policy settings to the Authentication methods policy for Microsoft Entra ID](https://learn.microsoft.com/entra/identity/authentication/how-to-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Failed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "AccessControl",
        "Authentication"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Privileged Microsoft Entra built-in roles are targeted with Conditional Access policies to enforce phishing-resistant methods",
      "TestRisk": "High",
      "TestId": "21783",
      "TestResult": "\nFound Roles don’t have policies to enforce phishing resistant Credentials\n\n\n\n## Conditional Access Policies with phishing resistant authentication policies \n\nFound 4 phishing resistant conditional access policies.\n\n  - [AuthContext: Require FIDO2 ](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/854ff675-1eef-448d-8382-533788fae7e5) (Disabled)\n  - [MFA CA Policy](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/e589544c-0c92-432e-86ae-4e4ef103eac8)\n  - [Guest-Meferna-Woodgrove-PhishingResistantAuthStrength](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/0f0a0c1c-41b0-4c18-ae20-d02492d03737)\n  - [NewphishingCA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/3fe49849-5ab6-4717-a22d-aa42536eb560) (Disabled)\n\n\n## Privileged Roles\n\nFound 2 of 29 privileged roles protected by phishing resistant authentication.\n\n| Role Name | Phishing resistance enforced |\n| :--- | :---: |\n| Hybrid Identity Administrator | ✅ |\n| Security Administrator | ✅ |\n| Application Administrator | ❌ |\n| Application Developer | ❌ |\n| Attribute Provisioning Administrator | ❌ |\n| Attribute Provisioning Reader | ❌ |\n| Authentication Administrator | ❌ |\n| Authentication Extensibility Administrator | ❌ |\n| B2C IEF Keyset Administrator | ❌ |\n| Cloud Application Administrator | ❌ |\n| Cloud Device Administrator | ❌ |\n| Conditional Access Administrator | ❌ |\n| Directory Writers | ❌ |\n| Domain Name Administrator | ❌ |\n| ExamStudyTest | ❌ |\n| External Identity Provider Administrator | ❌ |\n| Global Administrator | ❌ |\n| Global Reader | ❌ |\n| Helpdesk Administrator | ❌ |\n| Intune Administrator | ❌ |\n| Lifecycle Workflows Administrator | ❌ |\n| Partner Tier1 Support | ❌ |\n| Partner Tier2 Support | ❌ |\n| Password Administrator | ❌ |\n| Privileged Authentication Administrator | ❌ |\n| Privileged Role Administrator | ❌ |\n| Security Operator | ❌ |\n| Security Reader | ❌ |\n| User Administrator | ❌ |\n## Authentication Strength Policies\n\nFound 2 custom phishing resistant authentication strength policies.\n\n  - [ACSC Maturity Level 3](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n  - [Phishing-resistant MFA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n\n\n",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Outbound cross-tenant access settings are configured",
      "TestRisk": "High",
      "TestId": "21790",
      "TestResult": "\nTenant has a default cross-tenant access setting outbound policy with unrestricted access.\n## [Outbound access settings - Default settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/OutboundAccessSettings.ReactView/isDefault~/true/name//id/)\n### B2B Collaboration\nUsers and groups\n- Access status: blocked\n- Applies to: Selected users and groups (0 users, 1 groups)\n\nExternal applications\n- Access status: blocked\n- Applies to: Selected external applications (2 applications)\n\n### B2B Direct Connect\nUsers and groups\n- Access status: allowed\n- Applies to: All users\n\nExternal applications\n- Access status: allowed\n- Applies to: All external applications\n\n\n",
      "TestDescription": "Allowing unrestricted external collaboration with unverified organizations can increase the risk surface area of the tenant because it allows guest accounts that might not have proper security controls. Threat actors can attempt to gain access by compromising identities in these loosely governed external tenants. Once granted guest access, they can then use legitimate collaboration pathways to infiltrate resources in your tenant and attempt to gain sensitive information. Threat actors can also exploit misconfigured permissions to escalate privileges and try different types of attacks.\n\nWithout vetting the security of organizations you collaborate with, malicious external accounts can persist undetected, exfiltrate confidential data, and inject malicious payloads. This type of exposure can weaken organizational control and enable cross-tenant attacks that bypass traditional perimeter defenses and undermine both data integrity and operational resilience. Cross-tenant settings for outbound access in Microsoft Entra provide the ability to block collaboration with unknown organizations by default, reducing the attack surface.\n\n**Remediation action**\n\n- [Cross-tenant access overview](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure cross-tenant access settings](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-default-settings)\n- [Modify outbound access settings](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestStatus": "Failed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Service principals use safe redirect URIs",
      "TestRisk": "High",
      "TestId": "23183",
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe Redirect URIs |App owner tenant |\n| :--- | :--- | :--- | :--- |\n|  | [EAM Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24b12ae7-4648-4aae-b00c-6349a565d24c/appId/e6e0be31-7040-4084-ac44-600b67661f2c) | `2️⃣ https://eamdemo.azurewebsites.net` | 1852b10f-a011-428b-98f9-d09c37d477cf |\n|  | [FIDO2-passkeys-MFA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1aa7e155-cbf8-4970-8458-05a0c7a2d1a5/appId/4fabcfc0-5c44-45a1-8c80-8537f0625949) | `2️⃣ https://fidomfaserver.azurewebsites.net/connect/authorize` | 1852b10f-a011-428b-98f9-d09c37d477cf |\n|  | [Graph Explorer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f8f300a-870a-46ff-bdab-934e1436920d/appId/d3ce4cf8-6810-442d-b42e-375e14710095) | `2️⃣ https://graphexplorer.azurewebsites.net/` | 5508eaf2-e7b4-4510-a4fb-9f5970550d80 |\n|  | [Graph explorer (official site)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cd2e9b58-eb21-4a50-a338-33f9daa1599c/appId/de8bc8b5-d9f9-48b1-a8ad-b748da725064) | `2️⃣ https://graphtryit.azurewebsites.net`, `2️⃣ https://graphtryit.azurewebsites.net/` | 72f988bf-86f1-41af-91ab-2d7cd011db47 |\n|  | [Internal_AccessScope](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/180a3ccb-3f2f-486f-8b56-025fc225166d/appId/3f9bd1ee-5a72-4ad3-b67d-cb016f935bcf) | `1️⃣ http://featureconfiguration.onmicrosoft.com/Internal_AccessScope` | 0d2db716-b331-4d7b-aa37-7f1ac9d35dae |\n|  | [Modern Workplace Concierge](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad1c51e8-f8a8-4bf2-ac09-a3a20cba5fa5/appId/c65c4011-1b90-4ec9-b5e9-1ee17786ad84) | `2️⃣ https://mwconcierge.azurewebsites.net/` | 7955e1b3-cbad-49eb-9a84-e14aed7f3400 |\n|  | [entraChatAppMultiTenant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/855a57ff-88a6-4ad0-85d7-4f46d742730e/appId/5e00b345-a805-42a0-9caa-7d6cb761c668) | `2️⃣ https://entrachatapp.azurewebsites.net`, `2️⃣ https://entrachatapp.azurewebsites.net/redirect` | 8b047ec6-6d2e-481d-acfa-5d562c09f49a |\n\n",
      "TestDescription": "Non-Microsoft and multitenant applications configured with URLs that include wildcards or URL shorteners increase the attack surface for threat actors. These insecure redirect URIs (reply URLs) might allow adversaries to manipulate authentication requests, hijack authorization codes, and intercept tokens by directing users to attacker-controlled endpoints. Wildcard entries expand the risk by permitting unintended domains to process authentication responses, while shortener URLs might facilitate phishing and token theft in uncontrolled environments.\n\nWithout strict validation of redirect URIs, attackers can bypass security controls, impersonate legitimate applications, and escalate their privileges. This misconfiguration enables persistence, unauthorized access, and lateral movement, as adversaries exploit weak OAuth enforcement to infiltrate protected resources undetected.\n\n**Remediation action**\n\n- [Check the redirect URIs for your application registrations.](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) Make sure the redirect URIs don't have *.azurewebsites.net, wildcards, or URL shorteners.\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Credential"
      ],
      "TestSkipped": "",
      "TestCategory": "Privileged access",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Privileged accounts have phishing-resistant methods registered",
      "TestRisk": "High",
      "TestId": "21782",
      "TestResult": "\nFound privileged users that have not yet registered phishing resistant authentication methods\n\n## Privileged users\n\nFound privileged users that have not registered phishing resistant authentication methods.\n\nUser | Role Name | Phishing resistant method registered |\n| :--- | :--- | :---: |\n|[Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true)| User Administrator | ❌ |\n|[Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true)| AI Administrator | ❌ |\n|[Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true)| User Administrator | ❌ |\n|[Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f/hidePreviewBanner~/true)| Directory Synchronization Accounts | ❌ |\n|[Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Diego Siciliani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/cdfa577c-972f-4399-98aa-1ec4be7fa6d1/hidePreviewBanner~/true)| User Administrator | ✅ |\n|[Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Attribute Assignment Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Attribute Definition Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Global Administrator | ✅ |\n\n\n",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Secure the MFA registration (My Security Info) page",
      "TestRisk": "High",
      "TestId": "21806",
      "TestResult": "\nSecurity information registration is not protected by Conditional Access policies.\n",
      "TestDescription": "Without Conditional Access policies protecting security information registration, threat actors can exploit unprotected registration flows to compromise authentication methods. When users register multifactor authentication and self-service password reset methods without proper controls, threat actors can intercept these registration sessions through adversary-in-the-middle attacks or exploit unmanaged devices accessing registration from untrusted locations. Once threat actors gain access to an unprotected registration flow, they can register their own authentication methods, effectively hijacking the target's authentication profile. This enables them to maintain persistent access by controlling the victim's MFA methods, allowing them to bypass security controls and potentially escalate privileges throughout the environment. The compromised authentication methods then become the foundation for lateral movement as threat actors can authenticate as the legitimate user across multiple services and applications.\n\n**Remediation action**\n\nCreate Conditional Access policy for security info registration\n- [Protect security info registration with Conditional Access policy](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-security-info-registration)\n\nConfigure trusted network locations\n- [What is the location condition in Microsoft Entra Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/concept-assignment-network)\n\nEnable combined security information registration\n- [Enable combined security information registration](https://learn.microsoft.com/entra/identity/authentication/howto-registration-mfa-sspr-combined)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Application"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Applications don't have secrets configured",
      "TestRisk": "High",
      "TestId": "21772",
      "TestResult": "\nFound 28 applications and 12 service principals with client secrets configured.\n\n\n## Applications with client secrets\n\n| Application | Secret expiry |\n| :--- | :--- |\n| [AppProxy Header Test](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/19a70df3-cddf-48c7-be44-97b25b9857f1) | 2025-12-12 00:00:00 |\n| [AppProxyDemoLocalhost](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c) | 02/17/2026 |\n| [AppRolePimAutomationTestParentAcc19Feb22](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | 08/19/2022 |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2325-01-01 00:00:00 |\n| [BlazorMultiDemo](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2e311a1d-f5c0-41c6-b866-77af3289871e) | 2024-02-11 00:00:00 |\n| [Cool New for Telstra](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d77611ee-5051-4383-9af3-5ba3627306a7) | 08/16/2022 |\n| [Entra.News Automation Script - Message Center](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/83f76a08-fa60-48e6-9cb5-fd8ced5ae314) | 02/17/2026 |\n| [Entry Kiosk](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b903f17a-87b0-460b-9978-962c812e4f98) | 11/25/2021 |\n| [Graph Filter](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975) | 09/16/2024 |\n| [Graph PowerShell - Privileged Perms](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/c5338ce0-3e9e-4895-8f49-5e176836a348) | 05/15/2024 |\n| [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d36fe320-bc28-40c8-a141-a512d65d112c) | 2026-09-02 00:00:00 |\n| [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/fef811e1-2354-43b0-961b-248fe15e737d) | 2022-11-02 00:00:00 |\n| [Lokka](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/f581405a-9e57-4e81-91f1-40cd62f7595e) | 2026-01-01 00:00:00 |\n| [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | 03/29/2022 |\n| [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) | 09/23/2024 |\n| [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) | 02/21/2124 |\n| [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) | 2025-07-06 00:00:00 |\n| [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | 03/29/2022 |\n| [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) | 10/16/2023 |\n| [RemixTest](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d4588485-154e-4b32-935f-31ceaf993cdc) | 06/24/2024 |\n| [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | 05/15/2024 |\n| [WebApplication3](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/bcdb1ed5-9470-41e6-821b-1fc42ae94cfb) | 2022-11-02 00:00:00 |\n| [WebApplication3_20210211261232](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/ac49e193-bd5f-40fe-b4ff-e62136419388) | 2022-11-02 00:00:00 |\n| [WebApplication4](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b2d1f868-27ee-4ecd-ae81-0ee96b028605) | 2022-04-03 00:00:00 |\n| [WingtipToys App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/56a89db1-6ed2-4171-88f6-b4f7597dbce3) | 11/27/2025 |\n| [aadgraphmggraph](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/24b66505-1142-452f-9472-2ecbb37deac1) | 11/26/2022 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/4f50c653-dae4-44e7-ae2e-a081cce1f830) | 02/25/2023 |\n| [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) | 2025-09-03 00:00:00 |\n\n\n## Service Principals with client secrets\n\n| Service principal | App owner tenant | Secret expiry |\n| :--- | :--- | :--- |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 10/26/2025 |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/dc7d83b5-d38b-4488-8952-7abf02e71590/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2027-03-03 00:00:00 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/17/2024 |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-01-07 00:00:00 |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-06-11 00:00:00 |\n| [SPO Version](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/2d6d9bf1-1f6e-48cf-bb02-31beec2f442e/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 11/17/2024 |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-10-02 00:00:00 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 11/17/2025 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/15/2024 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/15/2027 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/26/2028 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-10-10 00:00:00 |\n\n\n",
      "TestDescription": "Applications that use client secrets might store them in configuration files, hardcode them in scripts, or risk their exposure in other ways. The complexities of secret management make client secrets susceptible to leaks and attractive to attackers. Client secrets, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's client secret, they can escalate their privileges within the system, leading to broader access and control, depending on the permissions of the application.\n\nApplications and service principals that have permissions for Microsoft Graph APIs or other APIs have a higher risk because an attacker can potentially exploit these additional permissions.\n\n**Remediation action**\n\n- [Move applications away from shared secrets to managed identities and adopt more secure practices](https://learn.microsoft.com/entra/identity/enterprise-apps/migrate-applications-from-secrets?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n   - Use managed identities for Azure resources\n   - Deploy Conditional Access policies for workload identities\n   - Implement secret scanning\n   - Deploy application authentication policies to enforce secure authentication practices\n   - Create a least-privileged custom role to rotate application credentials\n   - Ensure you have a process to triage and monitor applications\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Block high risk sign-ins",
      "TestRisk": "High",
      "TestId": "21799",
      "TestResult": "\nSome high-risk sign-in attempts are not adequately mitigated by Conditional Access policies.\n",
      "TestDescription": "When high-risk sign-ins are not properly restricted through Conditional Access policies, organizations expose themselves to significant security vulnerabilities that threat actors can exploit for initial access through compromised credentials, credential stuffing attacks, or anomalous sign-in patterns that Microsoft Entra ID Protection identifies as risky behaviors. Without appropriate restrictions, threat actors who successfully authenticate during high-risk scenarios can perform privilege escalation by misusing the authenticated session to access sensitive resources, modify security configurations, or conduct reconnaissance activities within the environment. Once threat actors establish access through uncontrolled high-risk sign-ins, they can achieve persistence by creating additional accounts, installing backdoors, or modifying authentication policies to maintain long-term access to the organization's resources. The unrestricted access enables threat actors to conduct lateral movement across systems and applications using the authenticated session, potentially accessing sensitive data stores, administrative interfaces, or critical business applications. Finally, threat actors achieve impact through data exfiltration, or compromise business-critical systems while maintaining plausible deniability by exploiting the fact that their risky authentication was not properly challenged or blocked.\n\n**Remediation action**\n\nImplement sign-in risk policy as documented here:\n- [Require multifactor authentication for elevated sign-in risk](https://learn.microsoft.com/entra/identity/conditional-access/policy-risk-based-sign-in)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "App registrations use safe redirect URIs",
      "TestRisk": "High",
      "TestId": "21885",
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe Redirect URIs |\n| :--- | :--- | :--- |\n|  | [Azure AD SAML Toolkit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/4317fd0a-dcee-45bf-8e94-9a66638b11e0/appId/6f5ed68c-9fad-4d78-bf88-2b16bbe16338/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://samltoolkit.azurewebsites.net/SAML/Consume` |  |\n|  | [My nice app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d41cfc13-11d1-4f93-835a-88e729725564/appId/2946f286-2b59-4f29-876c-0ed8bbe1c482/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://mysalmon.azurewebsites.net/login.saml` |  |\n|  | [saml test app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/daa6074c-db6f-4bdc-a41b-bc0052c536a5/appId/c266d677-a5f8-47bc-9f0a-1b6fbe0bddad/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://appclaims.azurewebsites.net/signin-saml`, `2️⃣ https://appclaims.azurewebsites.net/signin-oidc` |  |\n\n",
      "TestDescription": "OAuth applications configured with URLs that include wildcards, or URL shorteners increase the attack surface for threat actors. Insecure redirect URIs (reply URLs) might allow adversaries to manipulate authentication requests, hijack authorization codes, and intercept tokens by directing users to attacker-controlled endpoints. Wildcard entries expand the risk by permitting unintended domains to process authentication responses, while shortener URLs might facilitate phishing and token theft in uncontrolled environments. \n\nWithout strict validation of redirect URIs, attackers can bypass security controls, impersonate legitimate applications, and escalate their privileges. This misconfiguration enables persistence, unauthorized access, and lateral movement, as adversaries exploit weak OAuth enforcement to infiltrate protected resources undetected.\n\n**Remediation action**\n\n- [Check the redirect URIs for your application registrations.](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) Make sure the redirect URIs don't have *.azurewebsites.net, wildcards, or URL shorteners.\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Application"
      ],
      "TestSkipped": "",
      "TestCategory": "Monitoring",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Diagnostic settings are configured for all Microsoft Entra logs",
      "TestRisk": "High",
      "TestId": "21860",
      "TestResult": "\nSome Entra Logs are not configured with Diagnostic settings.\n\n## Log archiving\n\nLog | Archiving enabled |\n| :--- | :---: |\n|ADFSSignInLogs | ❌ |\n|AuditLogs | ❌ |\n|EnrichedOffice365AuditLogs | ❌ |\n|ManagedIdentitySignInLogs | ❌ |\n|MicrosoftGraphActivityLogs | ❌ |\n|NetworkAccessTrafficLogs | ❌ |\n|NonInteractiveUserSignInLogs | ❌ |\n|ProvisioningLogs | ❌ |\n|RemoteNetworkHealthLogs | ❌ |\n|RiskyServicePrincipals | ❌ |\n|RiskyUsers | ❌ |\n|ServicePrincipalRiskEvents | ❌ |\n|ServicePrincipalSignInLogs | ❌ |\n|SignInLogs | ❌ |\n|UserRiskEvents | ❌ |\n\n\n",
      "TestDescription": "The activity logs and reports in Microsoft Entra can help detect unauthorized access attempts or identify when tenant configuration changes. When logs are archived or integrated with Security Information and Event Management (SIEM) tools, security teams can implement powerful monitoring and detection security controls, proactive threat hunting, and incident response processes. The logs and monitoring features can be used to assess tenant health and provide evidence for compliance and audits.\n\nIf logs aren't regularly archived or sent to a SIEM tool for querying, it's challenging to investigate sign-in issues. The absence of historical logs means that security teams might miss patterns of failed sign-in attempts, unusual activity, and other indicators of compromise. This lack of visibility can prevent the timely detection of breaches, allowing attackers to maintain undetected access for extended periods.\n\n**Remediation action**\n\n- [Configure Microsoft Entra diagnostic settings](https://learn.microsoft.com/entra/identity/monitoring-health/howto-configure-diagnostic-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Integrate Microsoft Entra logs with Azure Monitor logs](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Stream Microsoft Entra logs to an event hub](https://learn.microsoft.com/entra/identity/monitoring-health/howto-stream-logs-to-event-hub?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Application certificates must be rotated on a regular basis",
      "TestRisk": "High",
      "TestId": "21992",
      "TestResult": "\nFound 4 applications and 9 service principals in your tenant with certificates that have not been rotated within 180 days.\n\n\n## Applications with certificates that have not been rotated within 180 days\n\n| Application | Certificate Start Date |\n| :--- | :--- |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2024-12-06 00:00:00 |\n| [InfinityDemo - Sample](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/20f152d5-856c-449d-aa07-81f5e510dfa7) | 2021-05-03 00:00:00 |\n| [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | 02/28/2021 |\n| [test public client](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/79a0c604-f215-4c52-8fbe-641d08aa7937) | 10/22/2021 |\n\n\n## Service principals with certificates that have not been rotated within 180 days\n\n| Service principal | App owner tenant | Certificate Start Date |\n| :--- | :--- | :--- |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 10/26/2022 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/17/2021 |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/05c98ca9-d208-4d3e-ad24-911bfc3d028c/appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2023-06-11 00:00:00 |\n| [SPO Version](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/4c780b09-998f-4b35-b41f-b125dc9f729a/appId/2d6d9bf1-1f6e-48cf-bb02-31beec2f442e/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 11/17/2023 |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-10-02 00:00:00 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 11/17/2022 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/15/2021 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/15/2024 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-10-10 00:00:00 |\n\n\n",
      "TestDescription": "If certificates aren't rotated regularly, they can give threat actors an extended window to extract and exploit them, leading to unauthorized access. When credentials like these are exposed, attackers can blend their malicious activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the application's privileges.\n\nQuery all of your service principals and application registrations that have certificate credentials. Make sure the certificate start date is less than 180 days.\n\n**Remediation action**\n\n- [Define an application management policy to manage certificate lifetimes](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Define a trusted certificate chain of trust](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create a least privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) \n- [Learn more about app management policies to manage certificate based credentials](https://devblogs.microsoft.com/identity/app-management-policy/)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Monitoring",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Privileged role activations have monitoring and alerting configured",
      "TestRisk": "High",
      "TestId": "21818",
      "TestResult": "\nRole notifications are not properly configured.\n\n\n## Notifications for high privileged roles\n\n\n| Role Name | Notification Scenario | Notification Type | Default Recipients Enabled | Additional Recipients |\n| :-------- | :-------------------- | :---------------- | :------------------------- | :-------------------- |\n| Application Administrator | Send notifications when members are assigned as eligible to this role | Role assignment alert | True | aleksandar@elapora.com |\n| Application Administrator | Send notifications when members are assigned as eligible to this role | Notification to the assigned user (assignee) | True | merill@elapora.com |\n| Application Administrator | Send notifications when members are assigned as eligible to this role | Request to approve a role assignment renewal/extension | True |  |\n\n\n\n",
      "TestDescription": "Organizations without proper activation alerts for highly privileged roles lack visibility into when users access these critical permissions. Threat actors can exploit this monitoring gap to perform privilege escalation by activating highly privileged roles without detection, then establish persistence through admin account creation or security policy modifications. The absence of real-time alerts enables attackers to conduct lateral movement, modify audit configurations, and disable security controls without triggering immediate response procedures.\n\n**Remediation action**\n\n- [Configure Microsoft Entra role settings in Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-how-to-change-default-setting?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#require-justification-on-active-assignment)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "User sign-in activity uses token protection",
      "TestRisk": "High",
      "TestId": "21786",
      "TestResult": "\nThe tenant is missing properly configured Token Protection policies.\n\n",
      "TestDescription": "A threat actor can intercept or extract authentication tokens from memory, local storage on a legitimate device, or by inspecting network traffic. The attacker might replay those tokens to bypass authentication controls on users and devices, get unauthorized access to sensitive data, or run further attacks. Because these tokens are valid and time bound, traditional anomaly detection often fails to flag the activity, which might allow sustained access until the token expires or is revoked.\n\nToken protection, also called token binding, helps prevent token theft by making sure a token is usable only from the intended device. Token protection uses cryptography so that without the client device key, no one can use the token.\n\n**Remediation action**   \nCreate a Conditional Access policy to set up token protection.   \n- [Microsoft Entra Conditional Access: Token protection](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Conditional Access policies for Privileged Access Workstations are configured",
      "TestRisk": "High",
      "TestId": "21830",
      "TestResult": "\nNo Conditional Access policies found that restrict privileged roles to PAW device.\n\n**❌ Found 0 policy(s) with compliant device control targeting all privileged roles**\n\n\n**❌ Found 0 policy(s) with PAW/SAW device filter targeting all privileged roles**\n\n\n",
      "TestDescription": "If privileged role activations aren't restricted to dedicated Privileged Access Workstations (PAWs), threat actors can exploit compromised endpoint devices to perform privileged escalation attacks from unmanaged or noncompliant workstations. Standard productivity workstations often contain attack vectors such as unrestricted web browsing, email clients vulnerable to phishing, and locally installed applications with potential vulnerabilities. When administrators activated privileged roles from these workstations, threat actors who gain initial access through malware, browser exploits, or social engineering can then use the locally cached privileged credentials or hijack existing authenticated sessions to escalate their privileges. Privileged role activations grant extensive administrative rights across Microsoft Entra ID and connected services, so attackers can create new administrative accounts, modify security policies, access sensitive data across all organizational resources, and deploy malware or backdoors throughout the environment to establish persistent access. This lateral movement from a compromised endpoint to privileged cloud resources represents a critical attack path that bypasses many traditional security controls. The privileged access appears legitimate when originating from an authenticated administrator's session.\n\nIf this check passes, your tenant has a Conditional Access policy that restricts privileged role access to PAW devices, but it isn't the only control required to fully enable a PAW solution. You also need to configure an Intune device configuration and compliance policy and a device filter.\n\n**Remediation action**\n\n- [Deploy a privileged access workstation solution](https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-deployment?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - Provides guidance for configuring the Conditional Access and Intune device configuration and compliance policies.\n- [Configure device filters in Conditional Access to restrict privileged access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-condition-filters-for-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "App instance property lock is configured for all multitenant applications",
      "TestRisk": "High",
      "TestId": "21777",
      "TestResult": "\nFound multi-tenant apps without app instance property lock configured.\n\n\n## Multi-tenant applications and their App Instance Property Lock setting\n\n\n| Application | Application ID | App Instance Property Lock configured |\n| :---------- | :------------- | :------------------------------------ |\n| [Adatum Demo App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/d2934d2a-3fbc-44a1-bda0-13e8d8a73b15/isMSAApp~/false) | d2934d2a-3fbc-44a1-bda0-13e8d8a73b15 | False |\n| [BlazorMultiDemo](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/2e311a1d-f5c0-41c6-b866-77af3289871e/isMSAApp~/false) | 2e311a1d-f5c0-41c6-b866-77af3289871e | False |\n| [EAM Provider](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/f8642471-b7d7-4432-9527-776071e69b8b/isMSAApp~/false) | f8642471-b7d7-4432-9527-776071e69b8b | True |\n| [ExtProperties](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/61a54643-d4b6-471d-bd7c-a55586155dfc/isMSAApp~/false) | 61a54643-d4b6-471d-bd7c-a55586155dfc | False |\n| [Graph Filter](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975/isMSAApp~/false) | c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975 | False |\n| [My Properties Bag](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/303b4699-5b62-451c-b951-7e10b01d9b6d/isMSAApp~/false) | 303b4699-5b62-451c-b951-7e10b01d9b6d | False |\n| [Tenant Extension Properties App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/7db77c2b-30c1-4379-838f-8767c1e0d619/isMSAApp~/false) | 7db77c2b-30c1-4379-838f-8767c1e0d619 | False |\n| [Tenant Extension Properties App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/271b9db4-6e96-430c-808f-973a776adeaf/isMSAApp~/false) | 271b9db4-6e96-430c-808f-973a776adeaf | False |\n| [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/e7dfcbb6-fe86-44a2-b512-8d361dcc3d30/isMSAApp~/false) | e7dfcbb6-fe86-44a2-b512-8d361dcc3d30 | True |\n| [graph-developer-proxy-samples](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/3658d9e9-dc87-4345-b59b-184febcf6781/isMSAApp~/false) | 3658d9e9-dc87-4345-b59b-184febcf6781 | False |\n| [idpowerelectron](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/909fff82-5b0a-4ce5-b66d-db58ee1a925d/isMSAApp~/false) | 909fff82-5b0a-4ce5-b66d-db58ee1a925d | True |\n| [test-mta](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/5ebc726d-e583-4822-b111-95ee05503c7e/isMSAApp~/false) | 5ebc726d-e583-4822-b111-95ee05503c7e | True |\n\n\n\n",
      "TestDescription": "App instance property lock prevents changes to sensitive properties of a multitenant application after the application is provisioned in another tenant. Without a lock, critical properties such as application credentials can be maliciously or unintentionally modified, causing disruptions, increased risk, unauthorized access, or privilege escalations.\n\n**Remediation action**\nEnable the app instance property lock for all multitenant applications and specify the properties to lock.\n- [Configure an app instance lock](https://learn.microsoft.com/en-us/entra/identity-platform/howto-configure-app-instance-property-locks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-an-app-instance-lock)   \n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Privileged access",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Global Administrators don't have standing access to Azure subscriptions",
      "TestRisk": "High",
      "TestId": "21788",
      "TestResult": "\nStanding access to Root Management group was found.\n\n\n## Entra ID objects with standing access to Root Management group\n\n\n| Entra ID Object | Object ID | Principal type |\n| :-------------- | :-------- | :------------- |\n| merill@elapora.com | 513f3db2-044c-41be-af14-431bf88a2b3e | User |\n| madura@elapora.com | 5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a | User |\n\n\n\n",
      "TestDescription": "Global Administrators with persistent access to Azure subscriptions expand the attack surface for threat actors. If a Global Administrator account is compromised, attackers can immediately enumerate resources, modify configurations, assign roles, and exfiltrate sensitive data across all subscriptions. Requiring just-in-time elevation for subscription access introduces detectable signals, slows attacker velocity, and routes high-impact operations through observable control points.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths.md)\n\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity.md)",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Admin consent workflow is enabled",
      "TestRisk": "High",
      "TestId": "21809",
      "TestResult": "\nAdmin consent workflow is disabled.\n\nThe adminConsentRequestPolicy.isEnabled property is set to false.\n\n",
      "TestDescription": "Enabling the Admin consent workflow in a Microsoft Entra tenant is a vital security measure that mitigates risks associated with unauthorized application access and privilege escalation. This check is important because it ensures that any application requesting elevated permission undergoes a review process by designated administrators before consent is granted. The admin consent workflow in Microsoft Entra ID notifies reviewers who evaluate and approve or deny consent requests based on the application's legitimacy and necessity. If this check doesn't pass, meaning the workflow is disabled, any application can request and potentially receive elevated permissions without administrative review. This poses a substantial security risk, as malicious actors could exploit this lack of oversight to gain unauthorized access to sensitive data, perform privilege escalation, or execute other malicious activities.\n\n**Remediation action**\n\nFor admin consent requests, set the **Users can request admin consent to apps they are unable to consent to** setting to **Yes**. Specify other settings, such as who can review requests.\n\n- [Enable the admin consent workflow](https://learn.microsoft.com/entra/identity/enterprise-apps/configure-admin-consent-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-the-admin-consent-workflow)\n- Or use the [Update adminConsentRequestPolicy](https://learn.microsoft.com/graph/api/adminconsentrequestpolicy-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) API to set the `isEnabled` property to true and other settings\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Guests are not assigned high privileged directory roles",
      "TestRisk": "High",
      "TestId": "22128",
      "TestResult": "\nGuests with privileged roles were detected.\n\n\n## Users with assigned high privileged directory roles\n\n\n| Role Name | User Name | User Principal Name | User Type | Assignment Type |\n| :-------- | :-------- | :------------------ | :-------- | :-------------- |\n| Global Administrator | [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true) | aleksandar@elapora.com | Member | Permanent |\n| Global Administrator | [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true) | ann@elapora.com | Member | Permanent |\n| Global Administrator | [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true) | merillf_gmail.com#EXT#@pora.onmicrosoft.com | Guest | Permanent |\n| Global Administrator | [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true) | damien.bowden@elapora.com | Member | Permanent |\n| Global Administrator | [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true) | emergency@elapora.com | Member | Permanent |\n| Global Administrator | [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true) | joshua@elapora.com | Member | Permanent |\n| Global Administrator | [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true) | madura@elapora.com | Member | Permanent |\n| Global Administrator | [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true) | merill@elapora.com | Member | Permanent |\n| Global Administrator | [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true) | tyler@elapora.com | Member | Permanent |\n| User Administrator | [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true) | aleksandar@elapora.com | Member | Eligible |\n| User Administrator | [Diego Siciliani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/cdfa577c-972f-4399-98aa-1ec4be7fa6d1/hidePreviewBanner~/true) | DiegoS@elapora.com | Member | Eligible |\n| User Administrator | [Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true) | GradyA@elapora.com | Member | Permanent |\n\n\n\n",
      "TestDescription": "When guest users are assigned highly privileged directory roles such as Global Administrator or Privileged Role Administrator, organizations create significant security vulnerabilities that threat actors can exploit for initial access through compromised external accounts or business partner environments. Since guest users originate from external organizations without direct control of security policies, threat actors who compromise these external identities can gain privileged access to the target organization's Microsoft Entra tenant.\n\nWhen threat actors obtain access through compromised guest accounts with elevated privileges, they can escalate their own privilege to create other backdoor accounts, modify security policies, or assign themselves permanent roles within the organization. The compromised privileged guest accounts enable threat actors to establish persistence and then make all the changes they need to remain undetected. For example they could create cloud-only accounts, bypass Conditional Access policies applied to internal users, and maintain access even after the guest's home organization detects the compromise. Threat actors can then conduct lateral movement using administrative privileges to access sensitive resources, modify audit settings, or disable security monitoring across the entire tenant. Threat actors can reach complete compromise of the organization's identity infrastructure while maintaining plausible deniability through the external guest account origin. \n\n**Remediation action**\n\n- [Remove Guest users from privileged roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/best-practices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "App registrations must not have dangling or abandoned domain redirect URIs",
      "TestRisk": "High",
      "TestId": "21888",
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe Redirect URIs |\n| :--- | :--- | :--- |\n|  | [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/35cbeecb-be21-4596-9869-0157d84f2d67/appId/c823a25d-fe94-494c-91f6-c7d51bf2df82/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `https://127.0.0.1` |  |\n\n\n",
      "TestDescription": "Unmaintained or orphaned redirect URIs in app registrations create significant security vulnerabilities when they reference domains that no longer point to active resources. Threat actors can exploit these \"dangling\" DNS entries by provisioning resources at abandoned domains, effectively taking control of redirect endpoints. This vulnerability enables attackers to intercept authentication tokens and credentials during OAuth 2.0 flows, which can lead to unauthorized access, session hijacking, and potential broader organizational compromise.\n\n**Remediation action**\n\n- [Redirect URI (reply URL) outline and restrictions](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Privileged access",
      "SkippedReason": null,
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All privileged role assignments are activated just in time and not permanently active",
      "TestRisk": "High",
      "TestId": "21815",
      "TestResult": "\nPrivileged users with permanent role assignments were found.\n\n\n## Privileged users with permanent role assignments\n\n\n| User | UPN | Role Name | Assignment Type |\n| :--- | :-- | :-------- | :-------------- |\n| [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true) | damien.bowden@elapora.com | Global Administrator | Permanent |\n| [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true) | aleksandar@elapora.com | Global Administrator | Permanent |\n| [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true) | madura@elapora.com | Global Administrator | Permanent |\n| [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true) | joshua@elapora.com | Global Administrator | Permanent |\n| [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true) | tyler@elapora.com | Global Administrator | Permanent |\n| [Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true) | GradyA@elapora.com | User Administrator | Permanent |\n| [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true) | merillf_gmail.com#EXT#@pora.onmicrosoft.com | Global Administrator | Permanent |\n| [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true) | merill@elapora.com | Global Administrator | Permanent |\n| [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true) | emergency@elapora.com | Global Administrator | Permanent |\n| [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true) | ann@elapora.com | Global Administrator | Permanent |\n\n\n\n",
      "TestDescription": "Threat actors target privileged accounts because they have access to the data and resources they want. This might include more access to your Microsoft Entra tenant, data in Microsoft SharePoint, or the ability to establish long-term persistence. Without a just-in-time (JIT) activation model, administrative privileges remain continuously exposed, providing attackers with an extended window to operate undetected. Just-in-time access mitigates risk by enforcing time-limited privilege activation with extra controls such as approvals, justification, and Conditional Access policy, ensuring that high-risk permissions are granted only when needed and for a limited duration. This restriction minimizes the attack surface, disrupts lateral movement, and forces adversaries to trigger actions that can be specially monitored and denied when not expected. Without just-in-time access, compromised admin accounts grant indefinite control, letting attackers disable security controls, erase logs, and maintain stealth, amplifying the impact of a compromise.\n\nUse Microsoft Entra Privileged Identity Management (PIM) to provide time-bound just-in-time access to privileged role assignments. Use access reviews in Microsoft Entra ID Governance to regularly review privileged access to ensure continued need.\n\n**Remediation action**\n\n- [Start using Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-getting-started?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create an access review of Azure resource and Microsoft Entra roles in PIM](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-create-roles-and-resource-roles-review?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Microsoft services applications don't have credentials configured",
      "TestRisk": "High",
      "TestId": "21774",
      "TestResult": "\nFound Microsoft services applications with credentials configured in the tenant, which represents a security risk.\n\n\n## Microsoft services applications with credentials configured in the tenant\n\n\n| Service Principal Name | Credentials Type | Credentials Expiration Date |\n| :--------------------- | :--------------- | :-------------------------- |\n| [Microsoft Office Web Apps Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/037813dc-c7fe-447a-aa1e-ab273ee9faf2/appId/67e3df25-268a-4324-a550-0de1c7f97287) | Password Credentials | Unknown |\n| [MicrosoftTeamsCortanaSkills](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/04b4c6be-21bd-4d12-84c4-ba9ae55c6cd7/appId/2bb78a2a-f8f1-4bc3-8ecf-c1e15a0726e6) | Password Credentials | Unknown |\n| [AAD Request Verification Service - PROD](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0f47a894-2d06-4d4a-97b1-0e69da30e28a/appId/c728155f-7b2a-4502-a08b-b8af9b269319) | Password Credentials | Unknown |\n| [Microsoft Invitation Acceptance Portal](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/112188ca-9cba-43b7-97a2-a81c1f44df0c/appId/4660504c-45b3-4674-a709-71951a6b0763) | Password Credentials | Unknown |\n| [Microsoft Defender for Cloud Pricing Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/14308172-290a-42ef-94cd-008f5652bf9f/appId/cbff9545-769a-4b41-b76e-fbb069e8727e) | Password Credentials | Unknown |\n| [Azure Files](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/14986977-6e69-44ed-8013-04854e732ef1/appId/69dda2a9-33ca-4ed0-83fb-a9b7b8973ff4) | Password Credentials | Unknown |\n| [SPAuthEvent](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1ad21667-1706-4385-a1a8-eff1f1a12b39/appId/3340b944-b12e-47d0-b46b-35f08ec1d8ee) | Password Credentials | Unknown |\n| [OneProfile Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1e9d9250-11dc-4779-8af2-503dc466ae4c/appId/b2cc270f-563e-4d8a-af47-f00963a71dcd) | Password Credentials | Unknown |\n| [Centralized Deployment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/20d9d544-6f4d-417c-b921-b6aa778966d4/appId/257601fd-462f-4a21-b623-7f719f0f90f4) | Password Credentials | Unknown |\n| [Microsoft Flow CDS Integration Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2783dfb3-c359-4668-9c6e-ab1653791794/appId/0eda3b13-ddc9-4c25-b7dd-2f6ea073d6b7) | Password Credentials | Unknown |\n| [Fiji Storage Backend](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3152cfe7-152e-4898-82a6-517855f44aa2/appId/05d97c70-cb7c-4e66-8138-d5ca7c59d206) | Password Credentials | Unknown |\n| [NetworkTrafficAnalyticsService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31d9c616-8c58-4cc3-a883-18b45c6674f9/appId/1e3e4475-288f-4018-a376-df66fd7fac5f) | Password Credentials | Unknown |\n| [Azure Storage Actions Resource Provider Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/37d03510-b5a5-4433-99c1-15032351d8d5/appId/7d3471e1-ec8b-4655-92f3-bb331362b5ae) | Password Credentials | Unknown |\n| [AzNS EventHub Action](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/398f86eb-b26c-46a4-8ab9-675804a54fcf/appId/58ef1dbd-684c-47d6-8ffc-61ea7a197b95) | Password Credentials | Unknown |\n| [SharePoint Online Client Extensibility](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/428dcf14-9799-4304-8763-316663f694f5/appId/c58637bb-e2e1-4312-8a00-04b5ffcd3403) | Password Credentials | Unknown |\n| [ComplianceWorkbenchApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/47c5aaca-7384-42ad-8d3d-17f62bd6362d/appId/92876b03-76a3-4da8-ad6a-0511ffdf8647) | Password Credentials | Unknown |\n| [Azure SQL Database](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4d5bdc37-875d-4581-9adf-aa8bda5097ee/appId/022907d3-0f1b-48f7-badc-1ba6abab6d66) | Password Credentials | Unknown |\n| [Azure Service Connector Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4e61b179-8037-40e7-852c-4a188a8d6d0b/appId/c4288165-6698-45ba-98a5-48ea7791fed3) | Password Credentials | Unknown |\n| [Microsoft Whiteboard Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4eac3407-9d0b-4f5d-ad19-26adf2091f8a/appId/95de633a-083e-42f5-b444-a4295d8e9314) | Password Credentials | Unknown |\n| [Microsoft Intune](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/50b7da26-1a27-4434-ae66-32e6783dee4d/appId/0000000a-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [Microsoft Device Management Enrollment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/55e60291-7ee3-4c12-9229-7a38b651fdd9/appId/709110f7-976e-4284-8851-b537e9bcb187) | Password Credentials | Unknown |\n| [AADReporting](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/563b3145-fb94-4944-8124-8c3713cb2216/appId/1b912ec3-a9dd-4c4d-a53e-76aa7adb28d7) | Password Credentials | Unknown |\n| [Microsoft Teams Partner Tenant Administration ](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/61154cd8-a40d-4c93-a1a0-991613d240c3/appId/0c708d37-30b2-4f22-8168-5d0cba6f37be) | Password Credentials | Unknown |\n| [MsgDataMgmt](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/62d52de4-12ff-4074-bdad-3189e54c30bf/appId/61a63147-3824-45f5-a186-ace3f4c9daeb) | Password Credentials | Unknown |\n| [NetworkVerifier](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/645dcd75-7a7f-44fa-a10b-3ef92b20d089/appId/6e02f8e9-db9b-4eb5-aa5a-7c8968375f68) | Password Credentials | Unknown |\n| [Storage Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/66a121c9-0059-41a0-83ca-dca210893b02/appId/a6aa9161-5291-40bb-8c5c-923b567bee3b) | Password Credentials | Unknown |\n| [Azure Help Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6864a419-e03a-4c65-97be-1df17083e849/appId/fd225045-a727-45dc-8caa-77c8eb1b9521) | Password Credentials | Unknown |\n| [Azure AD Identity Governance](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6954c68b-3945-4133-bea7-78bec0320b43/appId/bf26f092-3426-4a99-abfb-97dad74e661a) | Password Credentials | Unknown |\n| [Microsoft SharePoint Online - SharePoint Home](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6b9c59a7-ca3b-456a-aa7d-3b7235ea72af/appId/dcad865d-9257-4521-ad4d-bae3e137b345) | Password Credentials | Unknown |\n| [TenantSearchProcessors](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6bedbcd5-9e03-4b20-9cd5-6bbcac752e2b/appId/abc63b55-0325-4305-9e1e-3463b182a6dc) | Password Credentials | Unknown |\n| [Azure AD Identity Governance - Dynamics 365 Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6eb18785-edb9-4fb8-ba07-88d2b84f1706/appId/c495cfdc-814f-46a1-89f0-657921c9fbe0) | Password Credentials | Unknown |\n| [Microsoft Office Licensing Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/749b3ee3-7229-45f5-9ff2-ec5a7e95e5e9/appId/8d3a7d3c-c034-4f19-a2ef-8412952a9671) | Password Credentials | Unknown |\n| [CAS API Security RP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/758fafbd-eee5-40ae-a8a5-6122d71c7476/appId/56823b05-67d8-413a-b6ab-ad19d7710cf2) | Password Credentials | Unknown |\n| [Teams Policy Notification Processor Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7f23ecb8-4570-43d0-a699-c359521abb8b/appId/61f9e166-f678-4342-bfd3-b49781ce7a0a) | Password Credentials | Unknown |\n| [Microsoft Teams - Device Admin Agent](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8c3863db-5199-49a7-8996-7db519beaf6a/appId/87749df4-7ccf-48f8-aa87-704bad0e0e16) | Password Credentials | Unknown |\n| [Directory and Policy Cache](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8dd5e56b-bdba-4cc4-ac23-73fe93c12c0f/appId/7b58f833-4438-494c-a724-234928795a67) | Password Credentials | Unknown |\n| [O365 Demeter](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/998156da-a5db-4c3e-91ce-e29792361d7f/appId/982bda36-4632-4165-a46a-9863b1bbcf7d) | Password Credentials | Unknown |\n| [Microsoft To-Do](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9cb8bb28-0fac-467f-bdf2-b1db74fcd376/appId/c830ddb0-63e6-4f22-bd71-2ad47198a23e) | Password Credentials | Unknown |\n| [Microsoft Teams Settings Store](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9e1c30ca-5c56-4b7f-9f0f-efed4fbc5a1c/appId/cf6c77f8-914f-4078-baef-e39a5181158b) | Password Credentials | Unknown |\n| [Marketplace Caps API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9f259d37-738c-41b2-8f73-135133f2d0f9/appId/184909ca-69f1-4368-a6a7-c558ee6eb0bd) | Password Credentials | Unknown |\n| [RPA - Machine Management Relay Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9fc81fdc-0435-46fe-9a02-18573822101a/appId/aad3e70f-aa64-4fde-82aa-c9d97a4501dc) | Password Credentials | Unknown |\n| [Windows Azure Active Directory](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a08c4c37-4e78-4a10-8dc5-7131c2d325b6/appId/00000002-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [Power Query Online](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a0cebebf-2a4b-49de-933f-629ff534c785/appId/f3b07414-6bf4-46e6-b63f-56941f3f4128) | Password Credentials | Unknown |\n| [OCaaS Worker Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a28b8984-86b9-4592-a982-2b03a0d59fc5/appId/167e2ded-f32d-49f5-8a10-308b921bc7ee) | Password Credentials | Unknown |\n| [Microsoft Teams Retail Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a2e54a37-8fdf-4ed5-b027-e58ac14e9667/appId/75efb5bc-18a1-4e7b-8a66-2ad2503d79c6) | Password Credentials | Unknown |\n| [Azure AD Identity Governance - Directory Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a4760268-6661-4bbe-ba2c-79db64f6ea13/appId/ec245c98-4a90-40c2-955a-88b727d97151) | Password Credentials | Unknown |\n| [Microsoft.DynamicsMarketing](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a8b289c0-9eac-4795-85f1-7abcdc4cb9a3/appId/9b06ebd4-9068-486b-bdd2-dac26b8a5a7a) | Password Credentials | Unknown |\n| [AzureAutomation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad98d0ca-c44b-431d-a173-37dfd1e97972/appId/fc75330b-179d-49af-87dd-3b1acf6827fa) | Password Credentials | Unknown |\n| [Microsoft Teams Intelligent Workspaces Interactions Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b10fa084-cbbe-4cd2-96ab-b50a7676756a/appId/0eb4bf93-cb63-4fe1-9d7d-70632ccf3082) | Password Credentials | Unknown |\n| [Application Insights Configuration Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bd09a6d9-de29-4601-bfc1-9d901cde1650/appId/6a0a243c-0886-468a-a4c2-eff52c7445da) | Password Credentials | Unknown |\n| [Signup](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bfd9c1c8-590b-4320-8952-c2b6140540c9/appId/b4bddae8-ab25-483e-8670-df09b9f1d0ea) | Password Credentials | Unknown |\n| [Azure Monitor Control Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cf513924-c055-4f21-adcb-16e353767d1c/appId/e933bd07-d2ee-4f1d-933c-3752b819567b) | Password Credentials | Unknown |\n| [HoloLens Camera Roll Upload](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cfc95074-f250-49c7-bbb2-5a281da00134/appId/6b11041d-54a2-4c4f-96a2-6053efe46d8b) | Password Credentials | Unknown |\n| [Microsoft Threat Protection](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d0d2c1bb-d10d-4b7c-bae0-abd769c91e3f/appId/8ee8fdad-f234-4243-8f3b-15c294843740) | Password Credentials | Unknown |\n| [Marketplace Reviews](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d9b80698-d7da-43a9-be8e-4c76b6f09751/appId/a4c1cdb3-88ab-4d13-bc99-1c46106f0727) | Password Credentials | Unknown |\n| [Intune DiagnosticService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e579882a-e59c-41b8-a05e-846eee3b4ba7/appId/7f0d9978-eb2a-4974-88bd-f22a3006fe17) | Password Credentials | Unknown |\n| [Microsoft Graph Bicep Extension](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e6d46c2c-1c07-4f9f-ab8b-fb317550b816/appId/a1bfe852-bf44-4da0-a9c1-37af2d5e6df9) | Password Credentials | Unknown |\n| [Office365 Zoom](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e8744c2f-87aa-4b4a-adab-096a1e82b73f/appId/0d38933a-0bbd-41ca-9ebd-28c4b5ba7cb7) | Password Credentials | Unknown |\n| [AAD Terms Of Use](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f195f6ec-95be-4657-bba8-25c070a9f1d6/appId/d52792f4-ba38-424d-8140-ada5b883f293) | Password Credentials | Unknown |\n| [Office 365 Management APIs](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f553ca8d-3e06-4232-8c0f-0ce7bc624ffc/appId/c5393580-f805-4401-95e8-94b7a6ef2fc2) | Password Credentials | Unknown |\n| [Microsoft Azure Log Search Alerts](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f679d94a-c05a-4398-b87b-564a1457505a/appId/f6b60513-f290-450e-a2f3-9930de61c5e7) | Password Credentials | Unknown |\n| [Microsoft apps with Global Secure Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fa52458c-3907-47d0-b2cc-a9c10c6e8a15/appId/c08f52c9-8f03-4558-a0ea-9a4c878cf343) | Password Credentials | Unknown |\n| [My Profile](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fa5cb8bf-cec1-49ea-92ce-d4e8e8ca311f/appId/8c59ead7-d703-4a27-9e55-c96a0054c8d2) | Password Credentials | Unknown |\n| [Microsoft Exchange Online Protection](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fad56c3c-8551-43df-8337-07288b23ab50/appId/00000007-0000-0ff1-ce00-000000000000) | Password Credentials | Unknown |\n| [Service Encryption](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fde2f26d-e508-4e4a-933e-e43d71b4729e/appId/dbc36ae1-c097-4df9-8d94-343c3d091a76) | Password Credentials | Unknown |\n| [Microsoft.Azure.DataMarket](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ff26ee33-817a-4095-883e-3a34edad21e9/appId/00000008-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [OfficeServicesManager](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/029a7058-1a23-4c7b-937b-8f4013499955/appId/9e4a5442-a5c9-4f6f-b03f-5b9fcaaf24b1) | Password Credentials | Unknown |\n| [Microsoft Teams AuditService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/037f6be2-4f3a-4055-9688-03f4f776e7e7/appId/978877ea-b2d6-458b-80c7-05df932f3723) | Password Credentials | Unknown |\n| [Office 365 Configure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0838fcd9-c737-4905-9dab-7636305c5fbc/appId/aa9ecb1e-fd53-4aaa-a8fe-7a54de2c1334) | Password Credentials | Unknown |\n| [Azure SQL Database Backup To Azure Backup Vault](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0de77b8a-9981-4072-80ed-2ba179c0a4b0/appId/e4ab13ed-33cb-41b4-9140-6e264582cf85) | Password Credentials | Unknown |\n| [Microsoft Azure Policy Insights](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/10996137-bc26-4d3d-a765-5e9fd71b5f86/appId/1d78a85d-813d-46f0-b496-dd72f50a3ec0) | Password Credentials | Unknown |\n| [Azure Compute](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1f6acbd7-a1eb-4efe-b0ad-f7f6344de6b3/appId/579d9c9d-4c83-4efc-8124-7eba65ed3356) | Password Credentials | Unknown |\n| [Substrate Instant Revocation Pipeline](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/201ca5da-10a5-4604-8f31-43b407e72cdd/appId/eace8149-b661-472f-b40d-939f89085bd4) | Password Credentials | Unknown |\n| [Azure AD Identity Protection](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2092cef4-8152-4ee1-b645-2874fe8583ee/appId/fc68d9e5-1f76-45ef-99aa-214805418498) | Password Credentials | Unknown |\n| [Microsoft Teams - Teams And Channels Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2254593d-f566-425e-9f40-5ef5271d94ba/appId/b55b276d-2b09-4ad2-8de5-f09cf24ffba9) | Password Credentials | Unknown |\n| [EAPortals-AAD-PROD-PME](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/22dc5e24-9e67-4607-958e-57dd94fae47b/appId/d48cb907-3a0f-481e-a0d1-41097337a938) | Password Credentials | Unknown |\n| [Microsoft Teams Web Client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/26632cc7-ad87-414b-9304-1643fdc25dbe/appId/e1829006-9cf1-4d05-8b48-2e665cb48e6a) | Password Credentials | Unknown |\n| [Log Analytics API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2686a72c-433f-4886-b8af-0e46a97084df/appId/ca7f3f0b-7d91-482c-8e09-c5d840d0eac5) | Password Credentials | Unknown |\n| [Power Query Online GCC-L5](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2b44d4fb-3e90-4f91-a5c4-ab31b504c92c/appId/8c8fbf21-0ef3-4f60-81cf-0df811ff5d16) | Password Credentials | Unknown |\n| [o365.servicecommunications.microsoft.com](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2c0e8cbb-f005-4ad2-901b-aa081ec7311a/appId/cb1bda4c-1213-4e8b-911a-0a8c83c5d3b7) | Password Credentials | Unknown |\n| [Data Classification Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2e758d44-a880-4cf0-87f6-73c8476ee6fb/appId/7c99d979-3b9c-4342-97dd-3239678fb300) | Password Credentials | Unknown |\n| [IC3 Long Running Operations Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/341b9b60-da0e-45d3-955e-293b0b5ae6ad/appId/21a8a852-89f4-4947-a374-b26b2db3d365) | Password Credentials | Unknown |\n| [Euclid](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3709440c-a736-4ee3-a6b8-da9b6b4c4219/appId/2ca80e7c-4ad1-444f-88f5-58f92b71b7b0) | Password Credentials | Unknown |\n| [AzureBackup_Fabric_Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/38bb08e4-d927-4484-9572-2dcb5709d276/appId/e81c7467-0fc3-4866-b814-c973488361cd) | Password Credentials | Unknown |\n| [Azure Active Directory PowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/39921e28-0140-4bfc-ad89-26a3294f6ca9/appId/1b730954-1685-4b74-9bfd-dac224a7b894) | Password Credentials | Unknown |\n| [NFV Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3c3e96e7-d7dc-4bca-893c-99bf6eb68be1/appId/328fd23b-de6e-462c-9433-e207470a5727) | Password Credentials | Unknown |\n| [OCaaS Client Interaction Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4279da77-42d6-419d-bfd9-c0fcc40c595f/appId/c2ada927-a9e2-4564-aae2-70775a2fa0af) | Password Credentials | Unknown |\n| [Microsoft Exact Data Match Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/44f45270-6e29-4ca8-acdc-fcf94d5e4a10/appId/273404b8-7ebc-4360-9f90-b40417f77b53) | Password Credentials | Unknown |\n| [SharePoint Framework Azure AD Helper](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4bdc3f8f-03ec-4307-9cf3-bba4bf64ca71/appId/e29b5c86-b9ab-4a86-9a20-d10842007599) | Password Credentials | Unknown |\n| [CloudLicensingSystem](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4c190f19-92a6-4250-be96-997f33c33857/appId/de247707-4e4a-47d6-89fd-3c632f870b34) | Password Credentials | Unknown |\n| [Common Data Service - Azure Data Lake Storage](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4f69838b-ce76-415c-b43d-036644412eee/appId/546068c3-99b1-4890-8e93-c8aeadcfe56a) | Password Credentials | Unknown |\n| [MS Teams Griffin Assistant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5af10024-85f8-49d1-9cb8-63f4d2480fab/appId/c9224372-5534-42cb-a48b-8db4f4a3892e) | Password Credentials | Unknown |\n| [AzureBackupReporting](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5d071c2b-96fb-4ef2-9b15-91e40a3c9d04/appId/3b2fa68d-a091-48c9-95be-88d572e08fb7) | Password Credentials | Unknown |\n| [M365AdminSettingsService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5d0d3b7e-a50d-496d-9488-c34f7e8f3cd3/appId/914fed76-dc75-4540-bf23-57624291b0ec) | Password Credentials | Unknown |\n| [Microsoft Intune IW Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5d2274e5-e9c3-4951-9679-0290e33220f5/appId/b8066b99-6e67-41be-abfa-75db1a2c8809) | Password Credentials | Unknown |\n| [Azure Regional Service Manager](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5eeca7e1-1e9e-4941-9590-9d22b94ba3a7/appId/5e5e43d4-54da-4211-86a4-c6e7f3715801) | Password Credentials | Unknown |\n| [Signal B2 Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5f6b6711-3f08-4234-8940-00efca471cc3/appId/32b6d34b-c894-4971-8223-e17b86e9ad26) | Password Credentials | Unknown |\n| [Microsoft Teams](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/60036175-cbdf-4be7-9376-77f87783bee7/appId/1fec8e78-bce4-4aaf-ab1b-5451cc387264) | Password Credentials | Unknown |\n| [Geneva Alert RP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/68632035-53e1-4adb-b1e1-4774609e75df/appId/6bccf540-eb86-4037-af03-7fa058c2db75) | Password Credentials | Unknown |\n| [Dual-write](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/687cf93e-1f39-42a3-968a-ff187d5fcdd7/appId/6f7d0213-62b1-43a8-b7f4-ff2bb8b7b452) | Password Credentials | Unknown |\n| [RPA - Machine Management Relay Service - Application](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6a78fe44-3041-4dab-9000-f0269d7e3518/appId/db040338-7cb4-44df-a22b-785bde7ce0e2) | Password Credentials | Unknown |\n| [Microsoft Azure Alerts Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6d5be45c-6f88-4b41-9fbb-7aaed2d84d03/appId/161a339d-b9f5-41c5-8856-6a6669acac64) | Password Credentials | Unknown |\n| [Microsoft Defender for Cloud](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6d8621d1-6042-4035-aa8b-87eb04cb19db/appId/bceea168-88ac-4736-95dc-4ce488ffe324) | Password Credentials | Unknown |\n| [Defender Experts for XDR](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6e64f4bd-f5bb-4415-ade8-99d7e57d8635/appId/9ee7b58d-f9db-45bc-ad7b-c2b97bbc3337) | Password Credentials | Unknown |\n| [Office 365 SharePoint Online](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/717c0a8c-b7d2-4d7f-879e-0db5e6e12941/appId/00000003-0000-0ff1-ce00-000000000000) | Password Credentials | Unknown |\n| [Windows Azure Service Management API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/72e020c5-8f95-4dce-b875-b4004bbb13a7/appId/797f4846-ba00-4fd7-ba43-dac1f8f63013) | Password Credentials | Unknown |\n| [Microsoft Defender for Cloud Apps - Customer Experience](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7798d874-0f48-4adb-bd3a-5505380e9132/appId/ac6dbf5e-1087-4434-beb2-0ebf7bd1b883) | Password Credentials | Unknown |\n| [Microsoft Information Protection Sync Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/78a176eb-26d9-42ae-9b12-2d6fa0f27d04/appId/870c4f2e-85b6-4d43-bdda-6ed9a579b725) | Password Credentials | Unknown |\n| [Call Recorder](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7c3a1c53-7b1f-49c8-8d14-3a65c05cf378/appId/4580fd1d-e5a3-4f56-9ad1-aab0e3bf8f76) | Password Credentials | Unknown |\n| [Microsoft Azure](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7e3d7e28-2f4f-4d93-84c7-a6a2037d0a80/appId/15689b28-1333-4213-bb64-38407dde8a5e) | Password Credentials | Unknown |\n| [MileIQ Admin Center](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/82fed135-7609-4bf9-9619-f44d32bf658a/appId/de096ee1-dae7-4ee1-8dd5-d88ccc473815) | Password Credentials | Unknown |\n| [Office365 Shell WCSS-Server Default](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8ddfc7ca-208b-4833-a2a6-2ddd03676011/appId/a68e1e61-ad4f-45b6-897d-0a1ea8786345) | Password Credentials | Unknown |\n| [Azure Logic Apps](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8ec08ea7-c888-4029-8dcd-d57e62016d41/appId/7cd684f4-8a78-49b0-91ec-6a35d38739ba) | Password Credentials | Unknown |\n| [WindowsUpdate-Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8ef863a6-8b4a-4580-8472-8bbf2cefb9a8/appId/6f0478d5-61a3-4897-a2f2-de09a5a90c7f) | Password Credentials | Unknown |\n| [Fiji Storage](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f452ece-2464-4539-bd1c-f8ba877334d0/appId/1609d3a1-0db2-4818-b854-fe1614f0718a) | Password Credentials | Unknown |\n| [Compute Recommendation Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/930b7eed-30ce-431b-bd5e-0b079d5ed4d6/appId/b9a92e36-2cf8-4f4e-bcb3-9d99e00e14ab) | Password Credentials | Unknown |\n| [Demeter.WorkerRole](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9614fe31-d526-4a70-9624-5f7155106b7f/appId/3c31d730-a768-4286-a972-43e9b83601cd) | Password Credentials | Unknown |\n| [Substrate-FileWatcher](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/97d65478-67c7-4f62-b8be-f33b3b1861a7/appId/fbb0ac1a-82dd-478b-a0e5-0b2b98ef38fe) | Password Credentials | Unknown |\n| [Azure Traffic Manager and DNS](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9804ae3e-a294-4383-a785-d401ff2a4dc5/appId/2cf9eb86-36b5-49dc-86ae-9a63135dfa8c) | Password Credentials | Unknown |\n| [Microsoft password reset service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9bee6db7-75a0-46cc-bc76-b82a9dab8128/appId/93625bc8-bfe2-437a-97e0-3d0060024faa) | Password Credentials | Unknown |\n| [Microsoft Office Licensing Service Agents](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9bef973a-b9e0-4d25-be22-47b0455eb694/appId/d7097cd1-c779-44d0-8c71-ab1f8386a97e) | Password Credentials | Unknown |\n| [SQLVMResourceProviderAuth](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9c39ac30-a324-4a59-94ee-572440560ab1/appId/bd93b475-f9e2-476e-963d-b2daf143ffb9) | Password Credentials | Unknown |\n| [ChatMigrationService1P](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9ce61eba-5b29-45c2-8cab-1cfa87ea52b0/appId/3af5adde-460d-4bc1-ada0-fc648af8fefb) | Password Credentials | Unknown |\n| [Common Data Service User Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9d1517fc-a633-4264-84b6-4c681f430aae/appId/c92229fa-e4e7-47fc-81a8-01386459c021) | Password Credentials | Unknown |\n| [CAP Neptune Prod CM Prod ](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a0880346-f4dc-4d2d-80dd-515bbf310a6e/appId/ab158d9a-0b5c-4cc3-bb2b-f6646581e4e4) | Password Credentials | Unknown |\n| [Azure ESTS Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a9f0152b-ed28-4bc5-8d8d-f6bb5a220a70/appId/00000001-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [PROD Microsoft Defender For Cloud Athena](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/aa29dc5f-c8cc-4a65-aa8f-d96d976ee56e/appId/e807d0e2-91da-40d6-8cee-e33c91a0b051) | Password Credentials | Unknown |\n| [Microsoft_Azure_Support](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/acc7769c-bbd6-42fa-9305-ff866725c01e/appId/959678cf-d004-4c22-82a6-d2ce549a58b8) | Password Credentials | Unknown |\n| [CAS API Security RP Staging](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b75c420f-cf5d-4ecf-b733-b546434d209e/appId/19b21e10-1304-498b-92d4-4290e94999fa) | Password Credentials | Unknown |\n| [Microsoft B2B Admin Worker](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bc37842d-af36-406b-802a-03e50c4c138e/appId/1e2ca66a-c176-45ea-a877-e87f7231e0ee) | Password Credentials | Unknown |\n| [Microsoft Defender For Cloud Billing](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bde0c68b-4c24-4930-af44-e395a1707cc3/appId/e3a3c6d7-bd80-4be5-88da-c2226a5d9328) | Password Credentials | Unknown |\n| [SQL Copilot PPE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bfdfe311-16b1-4cf1-b82c-8f184f973c8d/appId/0fc12b9a-5463-4b87-8f10-765fecb39990) | Password Credentials | Unknown |\n| [All private resources with Global Secure Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c5916f16-20b9-437a-bdac-bcb2849ffc40/appId/e92b9b37-1b47-4c01-9fbc-91d84450870e) | Password Credentials | Unknown |\n| [AzureLockbox](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c649bff5-c7a3-471c-a4c1-25774eb02283/appId/a0551534-cfc9-4e1f-9a7a-65093b32bb38) | Password Credentials | Unknown |\n| [IC3 Gateway](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c874ae98-fab8-46bc-8d00-9669fe909aaf/appId/39aaf054-81a5-48c7-a4f8-0293012095b9) | Password Credentials | Unknown |\n| [Microsoft Defender for Cloud for AI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cc1bba54-3e14-4875-b5c0-8e9d4775b44a/appId/1efb1569-5fd6-4938-8b8d-9f3aa07c658d) | Password Credentials | Unknown |\n| [Azure Application Change Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d0154046-5f57-4557-a1b7-1c4164a27325/appId/3edcf11f-df80-41b2-a5e4-7e213cca30d1) | Password Credentials | Unknown |\n| [Office 365 Search Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d761e774-1eaa-47e8-b923-cbccb19b2455/appId/66a88757-258c-4c72-893c-3e8bed4d6899) | Password Credentials | Unknown |\n| [Microsoft Operations Management Suite](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d9142239-bd04-4e65-8cdf-fc96e403be7e/appId/d2a0a418-0aac-4541-82b2-b3142c89da77) | Password Credentials | Unknown |\n| [Microsoft Graph Change Tracking](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dc84f49d-d815-4187-8b2d-34a59cba2b40/appId/0bf30f3b-4a52-48df-9a82-234910c4a086) | Password Credentials | Unknown |\n| [WeveEngine](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/df93320a-8b56-4a18-8e89-b6c18a58988d/appId/3c896ded-22c5-450f-91f6-3d1ef0848f6e) | Password Credentials | Unknown |\n| [Power Platform Dataflows Common Data Service Client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e5216ac4-c878-4550-a0ee-bf45ab9d1018/appId/99335b6b-7d9d-4216-8dee-883b26e0ccf7) | Password Credentials | Unknown |\n| [Substrate Conversation Intelligence Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e6a29817-cd1f-47ba-819e-2e5ffb155734/appId/aa813f0e-407a-459d-93af-805f2bf10f33) | Password Credentials | Unknown |\n| [SharePoint Notification Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e89712ba-4cee-47d1-b62b-8ae4f7f8b905/appId/88884730-8181-4d82-9ce2-7d5a7cc7b81e) | Password Credentials | Unknown |\n| [Microsoft Intune Enrollment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e916e817-120a-4e90-a4c0-275e3107a373/appId/d4ebce55-015a-49b5-a083-c84d1797ae8c) | Password Credentials | Unknown |\n| [Microsoft Azure CLI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ec54b7a5-fdc0-48bf-90fa-992d04e3b981/appId/04b07795-8ddb-461a-bbee-02f9e1bf7b46) | Password Credentials | Unknown |\n| [Dynamics 365 AI for Customer Service Bot ](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ecb4abf8-31f7-4cb5-9a48-714e77e407a2/appId/96ff4394-9197-43aa-b393-6a41652e21f8) | Password Credentials | Unknown |\n| [IPSubstrate](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fb832759-aa99-42f8-91c5-5790fabded08/appId/4c8f074c-e32b-4ba7-b072-0f39d71daf51) | Password Credentials | Unknown |\n| [Sway](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/028ee643-425a-4a8d-bb81-a66113ee62d9/appId/905fcf26-4eb7-48a0-9ff0-8dcc7194b5ba) | Password Credentials | Unknown |\n| [Teams Approvals](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/077e3a7f-640f-43ec-8ed5-63f1014ea901/appId/3e050dd7-7815-46a0-8263-b73168a42c10) | Password Credentials | Unknown |\n| [Azure Analysis Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/10aa2f37-0596-49a4-b97f-d12b252cb975/appId/4ac7d521-0382-477b-b0f8-7e1d95f85ca2) | Password Credentials | Unknown |\n| [Viva Skills](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/17c4ba1c-fe5d-4e6b-b872-7941d5cfd55f/appId/75d4238e-b142-4d2d-aed9-232b830b8706) | Password Credentials | Unknown |\n| [Dataverse](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/17e09bb1-d8d6-48c5-addf-e80402a1fb42/appId/00000007-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [Azure Windows VM Sign-In](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1de1842e-06a6-4241-900e-d70dc4239511/appId/372140e0-b3b7-4226-8ef9-d57986796201) | Password Credentials | Unknown |\n| [Azure Cloud Shell](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/20664b5f-d545-465c-98c0-ed491487e9f6/appId/2233b157-f44d-4812-b777-036cdaf9a96e) | Password Credentials | Unknown |\n| [ResourceHealthRP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/21ee38b7-7b5a-4320-95a1-668842ad3b28/appId/8bdebf23-c0fe-4187-a378-717ad86f6a53) | Password Credentials | Unknown |\n| [Conference Auto Attendant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/295b4a14-8efb-4f7b-8cd5-fa366dc1079c/appId/207a6836-d031-4764-a9d8-c1193f455f21) | Password Credentials | Unknown |\n| [Microsoft Teams UIS](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/29d5e89f-cada-434c-8078-494d64bedd60/appId/1996141e-2b07-4491-927a-5a024b335c78) | Password Credentials | Unknown |\n| [Application Insights API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/35c253bc-4296-4e9d-b834-16903c3d2e8c/appId/f5c26e74-f226-4ae8-85f0-b4af0080ac9e) | Password Credentials | Unknown |\n| [Managed Service Identity](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/37bfc831-576e-4d69-b10f-3ff98ae43c0e/appId/ef5d5c69-a5df-46bb-acaf-426f161a21a2) | Password Credentials | Unknown |\n| [Azure Key Vault Managed HSM Key Governance Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3dd9d59b-1f8f-41d7-8508-bbfa9f3ea0b9/appId/a1b76039-a76c-499f-a2dd-846b4cc32627) | Password Credentials | Unknown |\n| [Microsoft Azure Signup Portal](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3f955b0f-eed9-45cb-99b0-143e5b90825d/appId/8e0e8db5-b713-4e91-98e6-470fed0aa4c2) | Password Credentials | Unknown |\n| [AAD App Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/40516ab4-1d0e-4f8a-9726-170405e6f997/appId/f0ae4899-d877-4d3c-ae25-679e38eea492) | Password Credentials | Unknown |\n| [MIP Exchange Solutions](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/443f469e-7016-42e9-bff0-7dd70e4bd8f5/appId/a150d169-7d37-47dd-9b20-156207b7b02f) | Password Credentials | Unknown |\n| [Azure Portal RP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4b28d61d-6451-421c-a947-1b43284b2dc9/appId/5b3b270a-b9ad-46e7-9bbb-a866897c4dc7) | Password Credentials | Unknown |\n| [Azure DNS Managed Resolver](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4cacd989-f431-41e2-aa7c-ac4203acb580/appId/b4ca0290-4e73-4e31-ade0-c82ecfaabf6a) | Password Credentials | Unknown |\n| [Microsoft Teams RetentionHook Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4da670ee-dd38-40ca-8f94-facbaca7c064/appId/f5aeb603-2a64-4f37-b9a8-b544f3542865) | Password Credentials | Unknown |\n| [Compute Artifacts Publishing Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4dcf9da2-ffa6-454d-9053-4e40e4de8aba/appId/a8b6bf88-1d1a-4626-b040-9a729ea93c65) | Password Credentials | Unknown |\n| [M365CommunicationCompliance](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4f97f9e8-dd13-48e3-a3af-690a9fff0189/appId/b8d56525-1fd0-4121-a640-e0ede64f74b5) | Password Credentials | Unknown |\n| [Windows Azure Application Insights](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5d80a07a-785d-4ecb-84ef-eec340572bf5/appId/11c174dc-1945-4a9a-a36b-c79a0f246b9b) | Password Credentials | Unknown |\n| [M365 App Management Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5e8e32b9-ba2a-4b05-abb8-c121fbf7beac/appId/0517ffae-825d-4aff-999e-3f2336b8a20a) | Password Credentials | Unknown |\n| [Diagnostic Services Trusted Storage Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/61194cc1-b4d8-4d8c-893b-bff8f04f108d/appId/562db366-1b96-45d2-aa4a-f2148cef2240) | Password Credentials | Unknown |\n| [MDATPNetworkScanAgent](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/61a233da-c577-448e-8b47-00c62fc9c5f7/appId/04687a56-4fc2-4e36-b274-b862fb649733) | Password Credentials | Unknown |\n| [DeploymentScheduler](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6c17c75e-9d8f-4948-8a6e-6ba675c472b9/appId/8bbf8725-b3ca-4468-a217-7c8da873186e) | Password Credentials | Unknown |\n| [Microsoft Device Management EMM API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/77329b46-3f6f-4c62-9bc4-e50eb5a15e65/appId/8ae6a0b1-a07f-4ec9-927a-afb8d39da81c) | Password Credentials | Unknown |\n| [Targeted Messaging Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7a007b43-60b2-4b9c-bb79-57590e0c00ec/appId/4c4f550b-42b2-4a16-93f9-fdb9e01bb6ed) | Password Credentials | Unknown |\n| [Microsoft Teams Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8261aefe-df59-4536-9adf-f1a080948b09/appId/cc15fd57-2c6c-4117-a88c-83b1d56b4bbe) | Password Credentials | Unknown |\n| [Yggdrasil](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8725fcb8-c9a4-499f-a334-c2769b228074/appId/78e7bc61-0fab-4d35-8387-09a8d2f5a59d) | Password Credentials | Unknown |\n| [Intune CMDeviceService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8ca129c5-3b0b-4055-aa82-922a0a6a3c08/appId/14452459-6fa6-4ec0-bc50-1528a1a06bf0) | Password Credentials | Unknown |\n| [SQLDBControlPlaneFirstPartyApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/922068fd-4420-41ea-bc13-e82bb4b9b7ef/appId/ceecbdd6-288c-4be9-8445-74f139e5db19) | Password Credentials | Unknown |\n| [AD Hybrid Health](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/93b5c95f-4c85-4d36-97be-6c4dba5d6ecf/appId/6ea8091b-151d-447a-9013-6845b83ba57b) | Password Credentials | Unknown |\n| [Microsoft Defender for Cloud MultiCloud Onboarding](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9b908274-913b-4a81-82d9-e0acd00c5402/appId/81172f0f-5d81-47c7-96f6-49c58b60d192) | Password Credentials | Unknown |\n| [Azure Support - Network Watcher](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a1836fdc-9378-4ab2-8581-694dad419d63/appId/341b7f3d-69b3-47f9-9ce7-5b7f4945fdbd) | Password Credentials | Unknown |\n| [Microsoft Teams VSTS](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a707f870-287e-4099-8423-1f709c15c95a/appId/a855a166-fd92-4c76-b60d-a791e0762432) | Password Credentials | Unknown |\n| [Azure Cost Management Scheduled Actions](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b324a6e9-213e-4cf7-90ba-d47cf7c536dd/appId/6b3368c6-61d2-4a72-854c-42d1c4e71fed) | Password Credentials | Unknown |\n| [Office365 Shell SS-Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b588d256-f2d0-42a5-bd6b-95078d6c0cb6/appId/e8bdeda8-b4a3-4eed-b307-5e2456238a77) | Password Credentials | Unknown |\n| [Intune Compliance Client Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b69b58b2-3a1a-4074-a42a-1924fd83eb6e/appId/a882f5bd-2492-44fe-bb55-a811aab59451) | Password Credentials | Unknown |\n| [Azure Portal](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bb6dafcf-0f3c-4398-95c7-e3e57db62bd2/appId/c44b4083-3bb0-49c1-b47d-974e53cbdf3c) | Password Credentials | Unknown |\n| [Managed Disks Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bc3f7f8d-eab7-4d24-b8a2-7237e37475e2/appId/60e6cd67-9c8c-4951-9b3c-23c25a2169af) | Password Credentials | Unknown |\n| [Intune Grouping and Targeting Client Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bee3deb4-5b5c-4bc3-bb77-ed093e83f7c6/appId/fd14a986-6fe4-409a-883e-cdec1009cd54) | Password Credentials | Unknown |\n| [Skype Teams Firehose](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bfde90f3-45cb-474c-8a1c-06f769266c29/appId/cdccd920-384b-4a25-897d-75161a4b74c1) | Password Credentials | Unknown |\n| [Azure Advisor](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c2cdfe60-7d10-4a2b-98ef-c4d77962026f/appId/c39c9bac-9d1f-4dfb-aa29-27f6365e5cb7) | Password Credentials | Unknown |\n| [Groupies Web Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c6d6644e-5d3d-4974-9ce2-aecb1246ef5f/appId/925eb0d0-da50-4604-a19f-bd8de9147958) | Password Credentials | Unknown |\n| [Azure Storage Insights Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c6ed7af0-c7b2-4d11-b922-0dd0e95b2c7f/appId/b15f3d14-f6d1-4c0d-93da-d4136c97f006) | Password Credentials | Unknown |\n| [Azure Storage](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c8113a93-9309-44d0-aef8-47652d9b49d8/appId/e406a681-f3d4-42a8-90b6-c2b029497af1) | Password Credentials | Unknown |\n| [Microsoft People Cards Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d43a1923-8046-4493-8183-0acdba763e20/appId/394866fc-eedb-4f01-8536-3ff84b16be2a) | Password Credentials | Unknown |\n| [Azure Multi-Factor Auth Client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d4c4b39f-886c-4d45-b655-f7e35cbce62c/appId/981f26a1-7f43-403b-a875-f8b09b8cd720) | Password Credentials | Unknown |\n| [Bing](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d689063e-4cbb-417d-a82d-eb394ae057ce/appId/9ea1ad79-fdb6-4f9a-8bc3-2b70f96e34c7) | Password Credentials | Unknown |\n| [Azure Key Vault Managed HSM](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d7d7597a-c159-47a7-bb6a-b08a3efdfab2/appId/589d5083-6f11-4d30-a62a-a4b316a14abf) | Password Credentials | Unknown |\n| [Microsoft.OfficeModernCalendar](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/da7c15cf-32f9-46ec-a4dd-d88be9adcfb8/appId/ab27a73e-a3ba-4e43-8360-8bcc717114d8) | Password Credentials | Unknown |\n| [Azure AD Notification](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dceef423-11ec-47f5-9287-4f8a539e3844/appId/fc03f97a-9db0-4627-a216-ec98ce54e018) | Password Credentials | Unknown |\n| [Azure Multi-Factor Auth Connector](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ddbaea8e-2949-4c81-b413-262b37246259/appId/1f5530b3-261a-47a9-b357-ded261e17918) | Password Credentials | Unknown |\n| [Skype Business Voice Directory](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e278ed69-8320-4380-a24f-6d1ab7bde0ba/appId/27b24f1f-688b-4661-9594-0fdfde972edc) | Password Credentials | Unknown |\n| [TI-1P-APP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e3f3acb5-43ef-4d20-a82c-6eabeabca876/appId/b6a1fec6-8029-456b-81ed-de7754615362) | Password Credentials | Unknown |\n| [Microsoft Forms](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ea91234a-bac1-4ca3-a015-efa3dcee1ed1/appId/c9a559d2-7aab-4f13-a6ed-e7e9c52aec87) | Password Credentials | Unknown |\n| [Office Delve](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fb457dda-8ac6-4655-877d-988fd65aa300/appId/94c63fef-13a3-47bc-8074-75af8c65887a) | Password Credentials | Unknown |\n| [Microsoft 365 Security and Compliance Center](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fd33236b-57a8-4370-a90c-92282b4cec80/appId/80ccca67-54bd-44ab-8625-4b79c4dc7775) | Password Credentials | Unknown |\n| [Office 365 Client Admin](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/02ab9364-9c62-4557-87d7-02702d4e07ae/appId/3cf6df92-2745-4f6f-bbcf-19b59bcdb62a) | Password Credentials | Unknown |\n| [SubscriptionRP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/03402dbf-1737-42eb-98de-a01a034e62d4/appId/e3335adb-5ca0-40dc-b8d3-bedc094e523b) | Password Credentials | Unknown |\n| [ConnectionsService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/047d1a96-45cb-4623-b667-eb30248a7d5f/appId/b7912db9-aa33-4820-9d4f-709830fdd78f) | Password Credentials | Unknown |\n| [MDC Data Sensitivity](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/09646b5e-6512-4390-a11d-6b8f8e87fdf5/appId/bd6d9218-235b-4abd-b3be-9ff157dcf36c) | Password Credentials | Unknown |\n| [M365DataAtRestEncryption](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0ad353a2-ddbc-449f-8ada-80019feb6d6c/appId/c066d759-24ae-40e7-a56f-027002b5d3e4) | Password Credentials | Unknown |\n| [IAM Supportability](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0b098141-61f8-4ca2-a302-d19bcc79b081/appId/a57aca87-cbc0-4f3c-8b9e-dc095fdc8978) | Password Credentials | Unknown |\n| [Microsoft Device Directory Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0ec3f05b-549b-444d-9602-cdfdd1bef2a0/appId/8f41dc7c-542c-4bdd-8eb3-e60543f607ca) | Password Credentials | Unknown |\n| [Microsoft Stream Portal](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0f549ca0-8373-4489-87e4-9d3392b4620d/appId/cf53fce8-def6-4aeb-8d30-b158e7b1cf83) | Password Credentials | Unknown |\n| [Compute Usage Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/13723c4f-c0da-48eb-895d-59fbc943a8f2/appId/a303894e-f1d8-4a37-bf10-67aa654a0596) | Password Credentials | Unknown |\n| [PPE-DataResidencyService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1396b8f9-762f-4be7-a688-c8558688b665/appId/dc457883-bafe-4f8b-a333-29685e7eaa9e) | Password Credentials | Unknown |\n| [Device Registration Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/13eb47c7-44ef-45db-8d04-a40b4e2b04ef/appId/01cb2876-7ebd-4aa4-9cc9-d28bd4d359a9) | Password Credentials | Unknown |\n| [Power Platform Data Analytics](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1d568f40-01dc-473b-a16e-ff33ac1b375b/appId/7dcff627-a295-4553-9229-b1f3513f82a8) | Password Credentials | Unknown |\n| [Azure Security for IoT](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1d98fbc5-1b7f-4a29-9100-767e930c3b2a/appId/cfbd4387-1a16-4945-83c0-ec10e46cd4da) | Password Credentials | Unknown |\n| [Microsoft Teams AuthSvc](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/23282f1f-78e8-43d4-9594-23513eeabad9/appId/a164aee5-7d0a-46bb-9404-37421d58bdf7) | Password Credentials | Unknown |\n| [Microsoft Stream Mobile Native](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2753d425-b546-4149-93d7-91ef8747328a/appId/844cca35-0656-46ce-b636-13f48b0eecbd) | Password Credentials | Unknown |\n| [MaintenanceResourceProvider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2b5f3823-4c85-4b29-b3d6-337e7698a8a4/appId/f18474f2-a66a-4bb0-a3c9-9b8d892092fa) | Password Credentials | Unknown |\n| [Dynamic Alerts](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2ce57b39-670f-41d8-81e1-6c3fd9aae8c4/appId/707be275-6b9d-4ee7-88f9-c0c2bd646e0f) | Password Credentials | Unknown |\n| [Skype for Business Online](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2d0bfe60-b023-470c-aae5-02bb404e86a3/appId/00000004-0000-0ff1-ce00-000000000000) | Password Credentials | Unknown |\n| [Microsoft Flow CDS Integration Service TIP1](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/396dab69-0975-4f64-a7c7-1de5b1e713ca/appId/eacba838-453c-4d3e-8c6a-eb815d3469a3) | Password Credentials | Unknown |\n| [Microsoft Defender for Cloud Apps MIP Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3cca8935-ee2b-448f-b4e4-a0b1c5c3c070/appId/0858ddce-8fca-4479-929b-4504feeed95e) | Password Credentials | Unknown |\n| [M365 Pillar Diagnostics Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/45dfa3ae-7efe-4a20-bb14-96befc1c644b/appId/58ea322b-940c-4d98-affb-345ec4cccb92) | Password Credentials | Unknown |\n| [Microsoft Office Licensing Service vNext](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/47e991a7-0b3a-413b-b68a-5cf01caf30c8/appId/db55028d-e5ba-420f-816a-d18c861aefdf) | Password Credentials | Unknown |\n| [Teams EHR Connector](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4b869bf5-0463-44e1-9169-1c45645996c1/appId/e97edbaf-39b2-4546-ba61-0a24e1bef890) | Password Credentials | Unknown |\n| [Microsoft Azure App Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/569d76a2-156b-4277-b8d7-27e60127d585/appId/abfa0a7c-a6b6-4736-8310-5855508787cd) | Password Credentials | Unknown |\n| [Messaging Bot API Application](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5712cef3-2f9b-4655-8788-e7554750222f/appId/5a807f24-c9de-44ee-a3a7-329e88a00ffc) | Password Credentials | Unknown |\n| [Viva Learning](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/576ac9b4-6398-40e2-b464-35d710421d7f/appId/2c9e12e5-a56c-4ba1-b768-7a141586c6fe) | Password Credentials | Unknown |\n| [Cloud Infrastructure Entitlement Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/58fe9623-cd54-412d-a894-4c121ac73937/appId/b46c3ac5-9da6-418f-a849-0a07a10b3c6c) | Password Credentials | Unknown |\n| [Metrics Monitor API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5afe4063-71ea-474e-bc73-9f5e9d0e18d3/appId/12743ff8-d3de-49d0-a4ce-6c91a4245ea0) | Password Credentials | Unknown |\n| [Microsoft Defender for Cloud Scanner Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/67dbf0c8-8934-4866-961a-570f0e261433/appId/e0ccf59d-5a20-4a87-a122-f42842cdb86a) | Password Credentials | Unknown |\n| [Microsoft Graph Connectors Core](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6d290ffc-7e07-4f80-b7cf-7ce39fb77a62/appId/f8f7a2aa-e116-4ba6-8aea-ca162cfa310d) | Password Credentials | Unknown |\n| [People Profile Event Proxy](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/74d7355a-f5b6-40a3-9bc2-69132c367478/appId/65c8bd9e-caac-4816-be98-0692f41191bc) | Password Credentials | Unknown |\n| [Azure Resource Graph](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/779ae9e3-736c-4a0d-960f-eeecec3bb7ac/appId/509e4652-da8d-478d-a730-e9d4a1996ca4) | Password Credentials | Unknown |\n| [Microsoft Teams Chat Aggregator](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/79ee2920-3e29-48b5-88f2-bc06f1fe1c4d/appId/b1379a75-ce5e-4fa3-80c6-89bb39bf646c) | Password Credentials | Unknown |\n| [Office 365 Enterprise Insights](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7f67829e-b364-45e8-bd87-7a999d426d0a/appId/f9d02341-e7aa-456d-926d-4a0ca599fbee) | Password Credentials | Unknown |\n| [ProjectWorkManagement](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/83c7aa98-c501-4fd9-ba5b-c1a72ee26d4d/appId/09abbdfd-ed23-44ee-a2d9-a627aa1c90f3) | Password Credentials | Unknown |\n| [Microsoft.SMIT](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/84ca59dd-b48b-4520-856b-31e263c27997/appId/8fca0a66-c008-4564-a876-ab3ae0fd5cff) | Password Credentials | Unknown |\n| [CPIM Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/896b612c-0c68-48a7-819b-b8be3b5c42e0/appId/bb2a2e3a-c5e7-4f0a-88e0-8e01fd3fc1f4) | Password Credentials | Unknown |\n| [IC3 Gateway TestClone](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8a257826-16c7-48e2-9635-fdcaa211a2f4/appId/55bdc56c-2b15-4538-aa37-d0c008c8c430) | Password Credentials | Unknown |\n| [Azure RBAC Data Plane](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8e3d9755-38d6-4eae-8f31-4409c483d8b4/appId/5861f7fb-5582-4c1a-83c0-fc5ffdb531a6) | Password Credentials | Unknown |\n| [Media Recording for Dynamics 365 Sales](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f348bda-4376-4bfa-b0df-e6e961eb173d/appId/f448d7e5-e313-4f90-a3eb-5dbb3277e4b3) | Password Credentials | Unknown |\n| [Automated Call Distribution](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f66a600-7907-4ffc-b724-f134f25759fb/appId/11cd3e2e-fccb-42ad-ad00-878b93575e07) | Password Credentials | Unknown |\n| [Microsoft.MileIQ.Dashboard](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/91a65da9-2a04-4e6d-9e65-5a332c9d58bf/appId/f7069a8d-9edc-4300-b365-ae53c9627fc4) | Password Credentials | Unknown |\n| [Microsoft Teams Shifts](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9ae1b4d8-fe47-4ef4-b1e4-98fe736c60b7/appId/aa580612-c342-4ace-9055-8edee43ccb89) | Password Credentials | Unknown |\n| [OneNote](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a1648eaa-56b8-44b8-9648-c2c1d45c5cd0/appId/2d4d3d8e-2be3-4bef-9f87-7875a61c29de) | Password Credentials | Unknown |\n| [O365SBRM Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a85748db-29ce-42b0-999a-42c64f8c6578/appId/9d06afd9-66c9-49a6-b385-ea7509332b0b) | Password Credentials | Unknown |\n| [AzureSupportCenter](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ae708c59-7ec1-4a0e-8a72-dd63f1d6c539/appId/37182072-3c9c-4f6a-a4b3-b3f91cacffce) | Password Credentials | Unknown |\n| [CIWebService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/af7366b8-dac1-48b8-8e02-bb7d16ee6af3/appId/e1335bb1-2aec-4f92-8140-0e6e61ae77e5) | Password Credentials | Unknown |\n| [MicrosoftEndpointDLP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/af7febb6-1536-4b74-b39c-71923334170a/appId/c98e5057-edde-4666-b301-186a01b4dc58) | Password Credentials | Unknown |\n| [Microsoft Azure Workflow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b1b8aabd-6273-4f87-a809-b8150231a024/appId/00000005-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [Office365 Shell SS-Server Default](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b550b27c-3cef-410f-86cc-0160e3486d14/appId/6872b314-67ab-4a16-98e7-a663b0f772c3) | Password Credentials | Unknown |\n| [Azure Lab Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/be2c026e-1656-4424-9109-78932a089db0/appId/1a14be2a-e903-4cec-99cf-b2e209259a0f) | Password Credentials | Unknown |\n| [OfficeFeedProcessors](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bec5843e-894a-4582-bd6f-6a3e4a1c322c/appId/98c8388a-4e86-424f-a176-d1288462816f) | Password Credentials | Unknown |\n| [M365 License Manager](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c0e230a3-3e72-47aa-8258-7ddac87c4551/appId/aeb86249-8ea3-49e2-900b-54cc8e308f85) | Password Credentials | Unknown |\n| [Microsoft Workplace Search Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c5fa4261-faad-4ca1-84cf-b4f63491ef97/appId/f3a218b7-5c8f-460b-93af-56b072788c15) | Password Credentials | Unknown |\n| [Microsoft Intune Advanced Threat Protection Integration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c6ec7deb-a058-4aa3-9fcc-56056577a8d0/appId/794ded15-70c6-4bcd-a0bb-9b7ad530a01a) | Password Credentials | Unknown |\n| [OCPS Checkin Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c846777a-0fa9-4ecf-b891-00fe28ad6cd9/appId/23c898c1-f7e8-41da-9501-f16571f8d097) | Password Credentials | Unknown |\n| [SharePoint Online Web Client Extensibility](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c8f7030e-0eb2-4986-9343-1e87d3e60168/appId/08e18876-6177-487e-b8b5-cf950c1e598c) | Password Credentials | Unknown |\n| [Power Platform Global Discovery Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ca35e7e6-7b4a-4ef8-a8a7-dd15b7e450f1/appId/93bd1aa4-c66b-4587-838c-ffc3174b5f13) | Password Credentials | Unknown |\n| [Dynamics Lifecycle services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d0b67b5e-38b4-4ffe-8a75-a170777770e3/appId/913c6de4-2a4a-4a61-a9ce-945d2b2ce2e0) | Password Credentials | Unknown |\n| [Azure Data Warehouse Polybase](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d3898f26-50b5-4fdc-9413-8b50edb0715c/appId/0130cc9f-7ac5-4026-bd5f-80a08a54e6d9) | Password Credentials | Unknown |\n| [Teams ACL management service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d68dbfb4-ba6d-4635-a1df-23efabad36de/appId/6208afad-753e-4995-bbe1-1dfd204b3030) | Password Credentials | Unknown |\n| [Microsoft Cloud App Security](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d9dc1bf2-74cf-4908-8a36-3a082ccf41a4/appId/05a65629-4c1b-48c1-a78b-804c4abdd4af) | Password Credentials | Unknown |\n| [MS-PIM](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dce4b7ca-f181-4ae7-9e1a-6dd600a9907b/appId/01fc33a7-78ba-4d2f-a4b7-768e336e890e) | Password Credentials | Unknown |\n| [Skype Teams Calling API Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e24d4ccc-ceca-4292-8fd4-4bdd12eb426d/appId/26a18ebc-cdf7-4a6a-91cb-beb352805e81) | Password Credentials | Unknown |\n| [Teams User Engagement Profile Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e2fd27c8-9a20-4b37-8c70-e9f16deb49f7/appId/0f54b75d-4d29-4a92-80ae-106a60cd8f5d) | Password Credentials | Unknown |\n| [MCAPI Authorization Prod](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fba57ac7-578d-44b5-81d1-8e800d36d465/appId/d73f4b35-55c9-48c7-8b10-651f6f2acb2e) | Password Credentials | Unknown |\n| [O365Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ffe4ecc7-e5e0-4132-b055-93bf39461e00/appId/1cda9b54-9852-4a5a-96d4-c2ab174f9edf) | Password Credentials | Unknown |\n| [StreamToSubstrateRepl](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/038b9adf-db0c-474f-a4b2-dd14bbb11eb9/appId/607e1f95-b519-4bac-8a15-6196f40e8977) | Password Credentials | Unknown |\n| [Office 365 Reports](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/047b459f-0512-44bb-91b5-8d7ad80f7a35/appId/507bc9da-c4e2-40cb-96a7-ac90df92685c) | Password Credentials | Unknown |\n| [Network Watcher](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/05aed2de-87ad-4acc-8d85-031b92059f35/appId/7c33bfcb-8d33-48d6-8e60-dc6404003489) | Password Credentials | Unknown |\n| [Skype Team Substrate connector](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/063c8746-d330-4742-b27d-edaccd2af2e5/appId/1c0ae35a-e2ec-4592-8e08-c40884656fa5) | Password Credentials | Unknown |\n| [AzUpdateCenterBilling](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0b137f2d-613a-4f81-8bfe-a5024bb38dd3/appId/c476eb34-4c94-43bc-97fc-94ede0534615) | Password Credentials | Unknown |\n| [Azure Key Vault](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1556778a-8f72-449e-a6db-d037c3457df6/appId/cfa8b339-82a2-471a-a3c9-0fc0be7a4093) | Password Credentials | Unknown |\n| [OMSAuthorizationServicePROD](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1965dd1b-bd93-49e3-a9b0-e4f345fe6bb9/appId/50d8616b-fd4f-4fac-a1c9-a6a9440d7fe0) | Password Credentials | Unknown |\n| [Microsoft Teams Mailhook](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/230e80e7-4423-4077-a8fb-1917b2c9bca2/appId/51133ff5-8e0d-4078-bcca-84fb7f905b64) | Password Credentials | Unknown |\n| [Microsoft Dynamics CRM Learning Path](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/237b642a-24fe-4535-9ddf-aebefab9f826/appId/2db8cb1d-fb6c-450b-ab09-49b6ae35186b) | Password Credentials | Unknown |\n| [Microsoft Teams Graph Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/25e7c70b-c0aa-44d2-a1f2-a9e4f3e3fbea/appId/ab3be6b7-f5df-413d-ac2d-abf1e3fd9c0b) | Password Credentials | Unknown |\n| [Exchange Office Graph Client for AAD - Noninteractive](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/26d8de19-4fd7-4b97-8f43-d372c565dde2/appId/765fe668-04e7-42ba-aec0-2c96f1d8b652) | Password Credentials | Unknown |\n| [Cloud Hybrid Search](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2a7922e0-9c26-49f3-9a0c-0d4b98bcaa42/appId/feff8b5b-97f3-4374-a16a-1911ae9e15e9) | Password Credentials | Unknown |\n| [Azure Management Groups](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/32798e82-b25b-46cd-80b9-e834105107fc/appId/f2c304cf-8e7e-4c3f-8164-16299ad9d272) | Password Credentials | Unknown |\n| [Microsoft Intune SCCM Connector](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3bbb2f0d-6056-4779-97f9-462250fce5c5/appId/63e61dc2-f593-4a6f-92b9-92e4d2c03d4f) | Password Credentials | Unknown |\n| [Skype for Business Application Configuration Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/41f83552-719a-4dad-bf52-664b922094bf/appId/00f82732-f451-4a01-918c-0e9896e784f9) | Password Credentials | Unknown |\n| [Dynamics 365 Resource Scheduling Optimization](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/437658d7-ed07-4669-8dce-0d7d170d18cd/appId/2f6713e6-1e21-4a83-91b4-5bf9a2378f81) | Password Credentials | Unknown |\n| [Azure MFA StrongAuthenticationService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4a0bdd13-938a-45d0-915c-ea5733227f94/appId/b5a60e17-278b-4c92-a4e2-b9262e66bb28) | Password Credentials | Unknown |\n| [Microsoft.MileIQ](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4e0c9fea-33af-47b1-b111-92c2a8044b30/appId/a25dbca8-4e60-48e5-80a2-0664fdb5c9b6) | Password Credentials | Unknown |\n| [Dynamics 365 Business Central](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/561b19c4-ce0d-47d1-a02b-4f16b5f36cb8/appId/996def3d-b36c-4153-8607-a6fd3c01b89f) | Password Credentials | Unknown |\n| [Microsoft Azure Container Apps - Data Plane](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/57b67cb7-9bcf-4bc2-b0e9-5cb58bc70fdc/appId/3734c1a4-2bed-4998-a37a-ff1a9e7bf019) | Password Credentials | Unknown |\n| [Networking-MNC](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5be6067e-e92c-4220-9846-4ff782b54f8a/appId/6d057c82-a784-47ae-8d12-ca7b38cf06b4) | Password Credentials | Unknown |\n| [Microsoft Remote Desktop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5d9d773b-bb5d-4f91-b2df-1f24667172d9/appId/a4a365df-50f1-4397-bc59-1a1564b8bb9c) | Password Credentials | Unknown |\n| [Federated Profile Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/622b0dc2-f87f-44f4-9fca-54a4064bb242/appId/7e468355-e4db-46a9-8289-8d414c89c43c) | Password Credentials | Unknown |\n| [Microsoft Teams Admin Portal Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/62f5ba5e-32e2-426d-a13c-4580468893a3/appId/2ddfbe71-ed12-4123-b99b-d5fc8a062a79) | Password Credentials | Unknown |\n| [Microsoft Intune AndroidSync](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/64e26d02-7976-4510-94a2-0e7da436cc10/appId/d8877f27-09c0-43aa-8113-40151dae8b14) | Password Credentials | Unknown |\n| [Call Quality Dashboard](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/679abc5d-95ee-4d79-a5d3-307b7d290a26/appId/c61d67cf-295a-462c-972f-33af37008751) | Password Credentials | Unknown |\n| [Microsoft Graph](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6a4b1625-abe5-4b67-91f7-7e1312d17059/appId/00000003-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [Internet resources with Global Secure Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6cae9150-ed14-4551-83f3-48aab7a8a880/appId/5dc48733-b5df-475c-a49b-fa307ef00853) | Password Credentials | Unknown |\n| [Azure Managed HSM RP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/778cfaa1-ba1d-4ce0-a478-e94a490a2869/appId/1341df96-0b28-43da-ba24-7a6ce39be816) | Password Credentials | Unknown |\n| [SalesInsightsWebApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8d506bb4-488a-4600-a63e-6904da52db86/appId/b20d0d3a-dc90-485b-ad11-6031e769e221) | Password Credentials | Unknown |\n| [Microsoft Flow Portal](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/92884702-035f-4759-944e-22b2461208fe/appId/6204c1d1-4712-4c46-a7d9-3ed63d992682) | Password Credentials | Unknown |\n| [Microsoft Invoicing](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/93f1491f-d5bd-4dc4-b24b-f3d60d4bd8f3/appId/b6b84568-6c01-4981-a80f-09da9a20bbed) | Password Credentials | Unknown |\n| [DWEngineV2](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/94a31976-a4ee-4939-89af-9bc960b65ae6/appId/441509e5-a165-4363-8ee7-bcf0b7d26739) | Password Credentials | Unknown |\n| [Microsoft Stream Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/97657c26-d520-4b83-8fa3-2cb62f3fceac/appId/2634dd23-5e5a-431c-81ca-11710d9079f4) | Password Credentials | Unknown |\n| [Power Apps API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a31322aa-35b9-4baa-9d1c-ade7a0ec43fc/appId/331cc017-5973-4173-b270-f0042fddfd75) | Password Credentials | Unknown |\n| [Azure Backup NRP Application](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a5a045f9-bb86-4718-90d2-9c64887c7d27/appId/9bdab391-7bbe-42e8-8132-e4491dc29cc0) | Password Credentials | Unknown |\n| [SubstrateActionsService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a758aa8e-742e-4168-b5c5-c19db445d65f/appId/06dd8193-75af-46d0-84bb-9b9bcaa89e8b) | Password Credentials | Unknown |\n| [CCM TAGS](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ae21a077-b8b0-449d-aaef-2673bc0c0189/appId/997dc448-eeab-4c93-8811-6b2c80196a16) | Password Credentials | Unknown |\n| [Verifiable Credentials Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b0849e4b-53a8-4b35-8a23-684345f59eb6/appId/bb2a64ee-5d29-4b07-a491-25806dc854d3) | Password Credentials | Unknown |\n| [Exchange Rbac](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b7aa9d7c-bb18-48a9-8161-d5b5d8966db0/appId/789e8929-0390-42a2-8934-0f9dafb8ec89) | Password Credentials | Unknown |\n| [Microsoft App Access Panel](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ba5d0700-083f-4bae-8de6-47a3aaf5283d/appId/0000000c-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [Microsoft Approval Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c25207af-d01d-4bd5-add3-2707351f26f8/appId/65d91a3d-ab74-42e6-8a2f-0add61688c74) | Password Credentials | Unknown |\n| [Jarvis Transaction Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cc0899dc-f824-4e59-b7ed-3e0013ad43e0/appId/bf9fc203-c1ff-4fd4-878b-323642e462ec) | Password Credentials | Unknown |\n| [MicrosoftAzureActiveAuthn](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ccfa24f3-413a-4a34-b5bb-34974492cd85/appId/0000001a-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [Branch Connect Web Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cf63e00d-bd3e-4ad1-8366-ae0dd5281702/appId/57084ef3-d413-4087-a28f-f6f3b1ad7786) | Password Credentials | Unknown |\n| [M365 Admin Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d96e9d7d-e6e8-46ee-b13e-a98dc3230eaa/appId/6b91db1b-f05b-405a-a0b2-e3f60b28d645) | Password Credentials | Unknown |\n| [OfficeGraph](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d9c9438e-6e6c-40ab-9b86-0a19a6cf5b53/appId/ba23cd2a-306c-48f2-9d62-d3ecd372dfe4) | Password Credentials | Unknown |\n| [Microsoft Teams Web Client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dee32b9c-566f-4185-ad81-b835235b1f12/appId/5e3ce6c0-2b1f-4285-8d4b-75ee78787346) | Password Credentials | Unknown |\n| [PushChannel](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dfd536ec-a51f-4d1b-90ce-94f1f9abdfee/appId/4747d38e-36c5-4bc3-979b-b0ef74df54d1) | Password Credentials | Unknown |\n| [WindowsDefenderATP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e139c0ca-7df8-4e14-93c5-34476f81383f/appId/fc780465-2017-40d4-a0c5-307022471b92) | Password Credentials | Unknown |\n| [Intune DeviceActionService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e612f9fc-b805-45d5-b438-312de887b61e/appId/18a4ad1e-427c-4cad-8416-ef674e801d32) | Password Credentials | Unknown |\n| [Skype for Business Name Dictionary Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e9bcd28f-1e57-43b0-a230-2099db3f83ae/appId/e95d8bee-4725-4f59-910d-94d415da51b9) | Password Credentials | Unknown |\n| [Microsoft Defender for Cloud Defender Kubernetes Agent](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f0cd0c67-a2bd-4bee-9598-8ad451384e65/appId/6e2cffc9-52e7-4bfa-8155-be5c1dacd81c) | Password Credentials | Unknown |\n| [Microsoft O365 Scuba](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f6ca9f68-4aff-41e8-8122-0cbdf803a67c/appId/7ae5462d-d9d1-42f6-93ca-198d7b0ca997) | Password Credentials | Unknown |\n| [Dynamics CRM Online Administration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f9e22670-8cde-4fbf-b93a-c1255d00abe9/appId/637fcc9f-4a9b-4aaa-8713-a2a3cfda1505) | Password Credentials | Unknown |\n| [M365 Label Analytics](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fb6e1f49-598d-473a-ae19-d151f9921bf2/appId/75513c96-801d-4559-830a-6754de13dd19) | Password Credentials | Unknown |\n| [Microsoft Teams AadSync](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/feea0436-9e99-47dc-bc75-74bbdf1c4f62/appId/62b732f7-fc71-40bc-b27d-35efcb0509de) | Password Credentials | Unknown |\n| [My Staff](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/07177c58-8766-402a-824b-d6cb8f708c17/appId/ba9ff945-a723-4ab5-a977-bd8c9044fe61) | Password Credentials | Unknown |\n| [EDU Assignments](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1dcaf725-ab62-4568-8bd9-414f7ae1c127/appId/8f348934-64be-4bb2-bc16-c54c96789f43) | Password Credentials | Unknown |\n| [Teams and Skype for Business Administration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1fdff09a-47e3-4247-9c93-396a06c352b6/appId/39624784-6cbe-4a60-afbe-9f46d10fdb27) | Password Credentials | Unknown |\n| [IDS-PROD](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/287f3104-3ef1-42f6-a605-de04ae915064/appId/f36c30df-d241-4c14-a0ee-752c71e4d3da) | Password Credentials | Unknown |\n| [Microsoft Defender for Cloud CIEM](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2fb62c29-835f-4588-9516-1d80274a0e29/appId/a70c8393-7c0c-4c1e-916a-811bd476ee11) | Password Credentials | Unknown |\n| [Office 365 Exchange Online](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3076f48e-d100-408f-a8b2-5addb658bdc1/appId/00000002-0000-0ff1-ce00-000000000000) | Password Credentials | Unknown |\n| [Microsoft Partner](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31203ff1-1025-422e-a782-9f97a93ad95d/appId/4990cffe-04e8-4e8b-808a-1175604b879f) | Password Credentials | Unknown |\n| [Skype and Teams Tenant Admin API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31d1f484-57b8-4146-b0cb-e05b6f0c7c7a/appId/48ac35b8-9aa8-4d74-927d-1f4a14a0b239) | Password Credentials | Unknown |\n| [Graph Connector Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3337a3b0-5eec-47ea-880d-5175d50f5a21/appId/56c1da01-2129-48f7-9355-af6d59d42766) | Password Credentials | Unknown |\n| [Verifiable Credentials Issuer Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/342dba9e-ee0e-4242-b74b-8dba6ccbf220/appId/603b8c59-ba28-40ff-83d1-408eee9a93e5) | Password Credentials | Unknown |\n| [Microsoft Service Trust](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3eda0eed-d66b-4690-b325-eb7aadebd5e3/appId/d6fdaa33-e821-4211-83d0-cf74736489e1) | Password Credentials | Unknown |\n| [Office 365 Mover](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/44dd27a7-62c7-4bf1-a40b-91a7c2ecc53d/appId/d62121f3-e023-4972-b6b0-794190c0fd98) | Password Credentials | Unknown |\n| [AIGraphClient](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/451702aa-3918-473f-bc03-2f26bd9c8840/appId/0f6edad5-48f2-4585-a609-d252b1c52770) | Password Credentials | Unknown |\n| [Microsoft 365 Admin portal](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/47cc1b6e-6b5d-4ab2-b7ca-b748ef5a7606/appId/618dd325-23f6-4b6f-8380-4df78026e39b) | Password Credentials | Unknown |\n| [Microsoft Insider Risk Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/59a04efe-44bb-4652-b562-b8bbdfd93e39/appId/1fe0d6b3-81f0-4cf5-9dfd-fbb297d7848c) | Password Credentials | Unknown |\n| [Exchange Office Graph Client for AAD - Interactive](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5eb64348-feb3-47fa-aa54-b3ae3f3a6bb5/appId/6da466b6-1d13-4a2c-97bd-51a99e8d4d74) | Password Credentials | Unknown |\n| [teams contacts griffin processor](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/63787b04-ff11-41ef-ad0d-deb6e420d3b8/appId/e08ab642-962a-4175-913c-165f557d799a) | Password Credentials | Unknown |\n| [Office Change Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6384b2c5-abe2-4399-b249-219acde4d871/appId/601d4e27-7bb3-4dee-8199-90d47d527e1c) | Password Credentials | Unknown |\n| [Office 365 Import Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/677f9c77-356e-472e-8349-98d32c5d113a/appId/3eb95cef-b10f-46fe-94e0-969a3d4c9292) | Password Credentials | Unknown |\n| [Hyper-V Recovery Manager](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6960214d-e3f8-4c5e-b40b-36c44e074351/appId/b8340c3b-9267-498f-b21a-15d5547fd85e) | Password Credentials | Unknown |\n| [DirectoryLookupService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6f777722-c073-4592-b2ae-736ffbcdf457/appId/9cd0f7df-8b1a-4e54-8c0c-0ef3a51116f6) | Password Credentials | Unknown |\n| [Microsoft Intune AAD BitLocker Recovery Key Integration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/76e01c86-ef4e-40b0-a2e1-657053943815/appId/ccf4d8df-75ce-4107-8ea5-7afd618d4d8a) | Password Credentials | Unknown |\n| [IDML Graph Resolver Service and CAD](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/76e0eb8a-56e7-4fdf-99e3-e0bb76793e26/appId/d88a361a-d488-4271-a13f-a83df7dd99c2) | Password Credentials | Unknown |\n| [Microsoft Flow Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7b0077a4-b4e5-4201-b464-2635e5bc5348/appId/7df0a125-d3be-4c96-aa54-591f83ff541c) | Password Credentials | Unknown |\n| [Microsoft Parature Dynamics CRM](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7b52dc79-9b93-4d8d-9ab1-8049bd9f4c56/appId/8909aac3-be91-470c-8a0b-ff09d669af91) | Password Credentials | Unknown |\n| [Verifiable Credentials Service Admin](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7d2f4e56-7af9-407a-befe-55e0c3e67a47/appId/6a8b4b39-c021-437c-b060-5a14a3fd65f3) | Password Credentials | Unknown |\n| [Omnichannel for CS CRM ClientApp Primary](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7f834cce-f31f-44ac-9c5a-4c45aca393fd/appId/d9ce8cfa-8bd8-4ff1-b39b-5e5dd5742935) | Password Credentials | Unknown |\n| [M365 Pillar Diagnostics Service API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/85e241d2-d5d5-4fad-a136-03ca6a3a09fa/appId/8bea2130-23a1-4c09-acfb-637a9fb7c157) | Password Credentials | Unknown |\n| [Microsoft Policy Insights Provider Data Plane](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/887b0a85-44a7-4941-9c7b-8db4575a565d/appId/8cae6e77-e04e-42ce-b5cb-50d82bce26b1) | Password Credentials | Unknown |\n| [Skype Presence Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8a44476b-73b6-47c3-832b-34903badf8d1/appId/1e70cd27-4707-4589-8ec5-9bd20c472a46) | Password Credentials | Unknown |\n| [Backup Management Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/97f0892e-b039-4117-b2d9-c0c862b6ea6c/appId/262044b1-e2ce-469f-a196-69ab7ada62d3) | Password Credentials | Unknown |\n| [Azure Advanced Threat Protection](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9d3c9375-ffc0-44a9-bbef-9cc32a71af8d/appId/7b7531ad-5926-4f2d-8a1d-38495ad33e17) | Password Credentials | Unknown |\n| [SharePoint Online Web Client Extensibility Isolated](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a0baae05-6f55-431e-b224-e79cde64576a/appId/3bc2296e-aa22-4ed2-9e1e-946d05afa6a2) | Password Credentials | Unknown |\n| [Reply-At-Mention](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a187aec5-29f0-4fe7-b41b-b79832d9e730/appId/18f36947-75b0-49fb-8d1c-29584a55cac5) | Password Credentials | Unknown |\n| [Microsoft Azure Container Apps - Control Plane](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a2298b71-c5fd-4da9-9e61-d2e69200f7ee/appId/7e3bc4fd-85a3-4192-b177-5b8bfc87f42c) | Password Credentials | Unknown |\n| [Azure Linux VM Sign-In](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a6dc027b-0fce-4840-a40b-a2f9ae77b5cf/appId/ce6ff14a-7fdc-4685-bbe0-f6afdfcfa8e0) | Password Credentials | Unknown |\n| [Microsoft Teams Bots](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a891196f-baa6-478b-830b-9bc450816a65/appId/64f79cb9-9c82-4199-b85b-77e35b7dcbcb) | Password Credentials | Unknown |\n| [Microsoft Substrate Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a95c4f9d-21e2-4033-a89a-ccc39ba22946/appId/98db8bd6-0cc0-4e67-9de5-f187f1cd1b41) | Password Credentials | Unknown |\n| [API Connectors 1st Party](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/af6c7046-42d5-4f6d-bbfd-eaf9fcc85184/appId/972bb84a-1d27-4bd3-8306-6b8e57679e8c) | Password Credentials | Unknown |\n| [KaizalaActionsPlatform](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b0307470-e7e0-4b22-812f-eddab65f859c/appId/9bb724a5-4639-438c-969b-e184b2b1e264) | Password Credentials | Unknown |\n| [Azure AD Identity Governance - SPO Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b4009820-d005-40a6-9ed5-639a40919d3f/appId/396e7f4b-41ea-4851-b04d-65de6cf1b4a3) | Password Credentials | Unknown |\n| [Data Export Service for Microsoft Dynamics 365](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b5ec1c6a-287a-4c42-93d3-48efcba528f4/appId/b861dbcc-a7ef-4219-a005-0e4de4ea7dcf) | Password Credentials | Unknown |\n| [Microsoft Defender for Cloud Servers Scanner Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b820a060-345a-4ec4-8a63-7c6f23edb400/appId/0c7668b5-3260-4ad0-9f53-34ed54fa19b2) | Password Credentials | Unknown |\n| [Cortana at Work Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ba2e586f-5aec-4a74-82cb-7189af9a6e27/appId/2a486b53-dbd2-49c0-a2bc-278bdfc30833) | Password Credentials | Unknown |\n| [Office Enterprise Protection Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bb4420d4-eb2d-4f96-9a6d-7db9e69e5820/appId/55441455-2f54-42b5-bc99-93e21cd4ae28) | Password Credentials | Unknown |\n| [Search Federation Connector - Dataverse](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bf90365d-72b4-4045-a235-d812f0c698c6/appId/9c60a40b-b5c5-4d01-8588-776209c80db3) | Password Credentials | Unknown |\n| [Microsoft Social Engagement](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c0fd319d-2572-4958-9995-ffcdc5811b68/appId/e8ab36af-d4be-4833-a38b-4d6cf1cfd525) | Password Credentials | Unknown |\n| [Power Platform Governance Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c1b65b38-1d1e-4a0d-b7ff-54ddc4a14730/appId/342f61e2-a864-4c50-87de-86abc6790d49) | Password Credentials | Unknown |\n| [O365 UAP Processor](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c37f76cb-d657-4760-ac30-a348d659414a/appId/df09ff61-2178-45d8-888c-4210c1c7b0b2) | Password Credentials | Unknown |\n| [Microsoft AppPlat EMA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c6a30560-cc29-4815-ab2a-d8ddbd713a84/appId/dee7ba80-6a55-4f3b-a86c-746a9231ae49) | Password Credentials | Unknown |\n| [aciapi](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/c72866de-c2ca-4650-8902-5597d155cf5f/appId/c5b17a4f-cc6f-4649-9480-684280a2af3a) | Password Credentials | Unknown |\n| [Windows Store for Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d28e8e6f-159b-4626-9b26-5376fe3f2aba/appId/45a330b1-b1ec-4cc1-9161-9f03992aa49f) | Password Credentials | Unknown |\n| [Storage Data Management RP Prod FPA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d881829c-2075-4d8f-912b-0db1bd3334b7/appId/3a3b6b87-84e2-4ad2-aa37-d76c339371a4) | Password Credentials | Unknown |\n| [Policy Administration Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/da8ba3c6-9fa9-4d70-b99a-246e2590d391/appId/0469d4cd-df37-4d93-8a61-f8c75b809164) | Password Credentials | Unknown |\n| [Portfolios](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ea709e20-1583-4bbd-834a-f9606bbab603/appId/f53895d3-095d-408f-8e93-8f94b391404e) | Password Credentials | Unknown |\n| [Export to data lake](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/efa3205c-a52d-4708-b43c-2550c3a7ac66/appId/7f15f9d9-cad0-44f1-bbba-d36650e07765) | Password Credentials | Unknown |\n| [Power BI Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f41e3a86-c3ea-442f-8ab0-a6b1bbc14caf/appId/00000009-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [Microsoft.Azure.ActiveDirectoryIUX](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ff45265f-2403-4c2b-be59-7a01264d8093/appId/bb8f18b0-9c38-48c9-a847-e1ef3af0602d) | Password Credentials | Unknown |\n| [Azure Cost Management XCloud](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/06274a3a-099a-4084-89ed-113c2b763102/appId/3184af01-7a88-49e0-8b55-8ecdce0aa950) | Password Credentials | Unknown |\n| [SharePoint Online Client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/06d098b2-5fb2-467f-aef5-5c1bc3df19fb/appId/57fb890c-0dab-4253-a5e0-7188c88b2bb4) | Password Credentials | Unknown |\n| [Configuration Manager Microservice](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/07a400c3-57ff-4f29-86f2-68638422bb0c/appId/557c67cf-c916-4293-8373-d584996f60ae) | Password Credentials | Unknown |\n| [Azure Communication Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0b2864a6-cc1a-452a-8b8d-214a02ea932c/appId/1fd5118e-2576-4263-8130-9503064c837a) | Password Credentials | Unknown |\n| [PowerApps Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/13360cbe-5186-4a79-86c1-94106ff5932c/appId/475226c6-020e-4fb2-8a90-7a972cbfc1d4) | Password Credentials | Unknown |\n| [Office Scripts Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/18264c36-bbac-4f0f-94c0-b361de6c3873/appId/62fd1447-0ef3-4ab7-a956-7dd05232ecc1) | Password Credentials | Unknown |\n| [Microsoft Office 365 Portal](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1c6d111c-09b7-4d88-b7ec-f355998e8585/appId/00000006-0000-0ff1-ce00-000000000000) | Password Credentials | Unknown |\n| [Viva Engage](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/208c96bb-9f9b-498c-8898-ef422ccb78d8/appId/00000005-0000-0ff1-ce00-000000000000) | Password Credentials | Unknown |\n| [Production-DPS-1P-SQLIaaS](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/235b5298-3a6e-4693-aca1-74b74cb3a0f1/appId/56a02f66-b2ce-4568-954b-907d5476c479) | Password Credentials | Unknown |\n| [Microsoft Intune Service Discovery](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/23eaa37a-db12-48b8-9cc7-b63ef6d042a6/appId/9cb77803-d937-493e-9a3b-4b49de3f5a74) | Password Credentials | Unknown |\n| [SharePoint Notification Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2523611c-0c71-4178-9032-4d0f5b777f2c/appId/3138fe80-4087-4b04-80a6-8866c738028a) | Password Credentials | Unknown |\n| [ComplianceAuthServer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2609107d-8450-4961-8145-42d6586de395/appId/9e5d84af-8971-422f-968a-354cd675ae5b) | Password Credentials | Unknown |\n| [MicrosoftAzureADFulfillment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/28552b5a-d8ce-4991-a866-4a62739397bf/appId/f09d1391-098c-47d7-ac7e-6ed2afc5016b) | Password Credentials | Unknown |\n| [Dynamics 365 Viva Sales](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/29eebe74-a38c-449a-a740-6f116e93a0ff/appId/4787c7ff-7cea-43db-8d0d-919f15c6354b) | Password Credentials | Unknown |\n| [Lifecycle Workflows](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2a269396-dfba-427e-894c-a7398bac8e99/appId/ce79fdc4-cd1d-4ea5-8139-e74d7dbe0bb7) | Password Credentials | Unknown |\n| [Azure Graph](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2d5a84bf-cca0-4dea-8ec3-f53fa4c9cab9/appId/dbcbd02a-d7c4-42fb-8c27-b07e5118b848) | Password Credentials | Unknown |\n| [Request Approvals Read Platform](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2eb55d19-94a9-4e8c-8f98-9f46e858b9d1/appId/d8c767ef-3e9a-48c4-aef9-562696539b39) | Password Credentials | Unknown |\n| [Cortana at Work Bing Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/31380f3e-aeff-4c74-8caf-36ff962d63ec/appId/22d7579f-06c2-4baa-89d2-e844486adb9d) | Password Credentials | Unknown |\n| [Microsoft Modern Contact Master](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/322c36fc-1b48-4634-9909-c84896743a94/appId/224a7b82-46c9-4d6b-8db0-7360fb444681) | Password Credentials | Unknown |\n| [Microsoft Device Management Checkin](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/46ac276c-1c73-46b1-af33-bd424005770c/appId/ca0a114d-6fbc-46b3-90fa-2ec954794ddb) | Password Credentials | Unknown |\n| [Office MRO Device Manager Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/46af5f7f-d989-47f4-89d1-21ceefef8f7d/appId/ebe0c285-db95-403f-a1a3-a793bd6d7767) | Password Credentials | Unknown |\n| [Office365DirectorySynchronizationService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/46d8ed5f-70bd-45d1-a98d-d785574b9754/appId/18af356b-c4fd-4f52-9899-d09d21397ab7) | Password Credentials | Unknown |\n| [Discovery Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4ef272a2-7902-469e-b08c-7c6447293816/appId/d29a4c00-4966-492a-84dd-47e779578fb7) | Password Credentials | Unknown |\n| [Azure Bastion](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/544a486d-3705-467b-b287-8d6b5de5d49d/appId/79d7fb34-4bef-4417-8184-ff713af7a679) | Password Credentials | Unknown |\n| [Azure Application Change Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5612244b-1204-4e82-9953-92e6f9676c6f/appId/2cfc91a4-7baa-4a8f-a6c9-5f3d279060b8) | Password Credentials | Unknown |\n| [O365 Customer Monitoring](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5dfeabe6-4ebd-45c0-982c-977c6c3ed69f/appId/3aa5c166-136f-40eb-9066-33ac63099211) | Password Credentials | Unknown |\n| [Microsoft Mobile Application Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/650552f0-f12a-4d40-9f06-5a42e5640a84/appId/0a5f63c0-b750-4f38-a71c-4fc0d58b89e2) | Password Credentials | Unknown |\n| [O365 Secure Score](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/65f41e93-0e46-49f6-8cd8-02bbe8413417/appId/8b3391f4-af01-4ee8-b4ea-9871b2499735) | Password Credentials | Unknown |\n| [Office Store](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6765a66d-701c-443d-a795-860131936420/appId/c606301c-f764-4e6b-aa45-7caaaea93c9a) | Password Credentials | Unknown |\n| [Prod-AzureSustainability](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/67855bcf-09f1-4feb-b14d-ecb528148f7a/appId/d05a94d3-4ebf-4d16-a4b5-c5157fe79490) | Password Credentials | Unknown |\n| [Microsoft.Azure.SyncFabric](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/69c321fa-3d19-46bb-b715-4d4f3fbc725b/appId/00000014-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [Microsoft Exact Data Match Upload Agent](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6e6bf537-243a-4172-bfac-e541c568bef7/appId/b51a99a9-ccaa-4687-aa2c-44d1558295f4) | Password Credentials | Unknown |\n| [Microsoft Azure Network Copilot](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/737817ca-3073-44cb-9ce9-3c3f4b2b865d/appId/40c49ff3-c6ae-436d-b28e-b8e268841980) | Password Credentials | Unknown |\n| [Verifiable Credentials Service Request](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/76cda19e-6414-4f8c-bb44-aee5ba07741a/appId/3db474b9-6a0c-4840-96ac-1fceb342124f) | Password Credentials | Unknown |\n| [Skype for Business Management Reporting and Analytics - Legacy](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/793c02b6-c476-48ab-9862-9bebe97df850/appId/de17788e-c765-4d31-aba4-fb837cfff174) | Password Credentials | Unknown |\n| [Teams Calling Meeting Devices Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7a6bfc17-ab77-4454-be71-ebb1567ff646/appId/00edd498-7c0c-4e68-859c-5a55d518c9c0) | Password Credentials | Unknown |\n| [Diagnostic Services Data Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8089a4af-bf2d-413e-b699-aac110243c0d/appId/3603eff4-9141-41d5-ba8f-02fb3a439cd6) | Password Credentials | Unknown |\n| [Office Shredding Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/849f263f-0edd-4fb2-a23a-277554f8298c/appId/b97b6bd4-a49f-4a0c-af18-af507d1da76c) | Password Credentials | Unknown |\n| [Azure Monitor Restricted](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8b3e93b9-3852-40ba-97c1-8e4aff25aaaf/appId/035f9e1d-4f00-4419-bf50-bf2d87eb4878) | Password Credentials | Unknown |\n| [AzureDnsFrontendApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8bd27fcb-cada-4baa-af90-b37bb1b551e9/appId/a0be0c72-870e-46f0-9c49-c98333a996f7) | Password Credentials | Unknown |\n| [Microsoft Windows AutoPilot Service API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8d170b2c-594f-44bc-bcc5-20d0dda2698e/appId/cbfda01c-c883-45aa-aedc-e7a484615620) | Password Credentials | Unknown |\n| [Microsoft Intune Web Company Portal](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8e69d177-5365-413c-852d-e58c8b24502b/appId/74bcdadc-2fdc-4bb3-8459-76d06952a0e9) | Password Credentials | Unknown |\n| [Power BI Premium](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9563bb9f-f8a8-4b3e-92fc-95a7edc82136/appId/cb4dc29f-0bf4-402a-8b30-7511498ed654) | Password Credentials | Unknown |\n| [Group Configuration Processor](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/99ca0b55-46a0-4141-ae9b-d85ee02aeb22/appId/1690c5aa-925a-4d0e-836b-722c795bd0d0) | Password Credentials | Unknown |\n| [MSATenantRestrictions](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/aa1ec693-8b05-4cbc-875d-909bb6e4d36c/appId/1a4b5304-a0fd-4017-8a3d-466fc083b73e) | Password Credentials | Unknown |\n| [Billing RP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ab21dffb-2dd9-4611-9d4c-2c6b43f9e65b/appId/80dbdb39-4f33-4799-8b6f-711b5e3e61b6) | Password Credentials | Unknown |\n| [PowerAI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/af7e792e-dabe-4985-ac64-6cd810adf0dc/appId/8b62382d-110e-4db8-83a6-c7e8ee84296a) | Password Credentials | Unknown |\n| [policy enforcer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b176e034-6f83-4965-ada1-ff6dfc434b43/appId/fbb123dc-fe45-41fe-ad9f-e42ab0769328) | Password Credentials | Unknown |\n| [Media Analysis and Transformation Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b41a38b1-c323-485f-8854-5b7973175067/appId/0cd196ee-71bf-4fd6-a57c-b491ffd4fb1e) | Password Credentials | Unknown |\n| [ReportReplica](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b79bd267-95ec-42f6-a0d4-45626bf4c848/appId/f25a7567-8ec5-4582-8a65-bfd66b0530cc) | Password Credentials | Unknown |\n| [One Outlook](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ba862a79-85ba-407e-9f81-e7b113dbd3c5/appId/5d661950-3475-41cd-a2c3-d671a3162bc1) | Password Credentials | Unknown |\n| [ASM Campaign Servicing](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bcf984be-a86b-4c40-9ff3-5b476b9c649f/appId/0cb7b9ec-5336-483b-bc31-b15b5788de71) | Password Credentials | Unknown |\n| [Audit GraphAPI Application](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bfb70570-a847-4b4b-af14-f1e25a356aac/appId/4bfd5d66-9285-44a1-bb14-14953e8cdf5e) | Password Credentials | Unknown |\n| [Conferencing Virtual Assistant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cad0ccae-54e3-406f-92b5-26da78053e6f/appId/9e133cac-5238-4d1e-aaa0-d8ff4ca23f4e) | Password Credentials | Unknown |\n| [Dynamics Data Integration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d0952bdf-7003-49a3-9299-704796151a63/appId/2e49aa60-1bd3-43b6-8ab6-03ada3d9f08b) | Password Credentials | Unknown |\n| [Microsoft.MileIQ.RESTService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d3c4a900-f04e-41f2-8ba8-93ddb1cf4971/appId/b692184e-b47f-4706-b352-84b288d2d9ee) | Password Credentials | Unknown |\n| [Azure DNS](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d57a38f1-b38d-47a7-9219-30e7719aca6b/appId/19947cfd-0303-466c-ac3c-fcc19a7a1570) | Password Credentials | Unknown |\n| [Microsoft Dynamics 365 Apps Integration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d8eb122c-dff4-41f6-bec7-2ecbcd8a60ef/appId/44a02aaa-7145-4925-9dcd-79e6e1b94eff) | Password Credentials | Unknown |\n| [Azure SQL Managed Instance to Microsoft.Network](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/def0c33b-2228-4437-aea9-eeb4fc512e59/appId/76c7f279-7959-468f-8943-3954880e0d8c) | Password Credentials | Unknown |\n| [AzNet Security Guard](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/df357835-6992-4ff6-b2cf-ecaa471dd7e1/appId/38808189-fa7a-4d8a-807f-eba01edacca6) | Password Credentials | Unknown |\n| [IpAddressManager](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e11ff2a1-baa4-44d9-a94b-bcdffc7e6f4c/appId/60b2e7d5-a27f-426d-a6b1-acced0846fdf) | Password Credentials | Unknown |\n| [Azure Credential Configuration Endpoint Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e1a56fef-0c5f-465e-b6bf-2339137e7e2d/appId/ea890292-c8c8-4433-b5ea-b09d0668e1a6) | Password Credentials | Unknown |\n| [Defender for Storage Advanced Threat Protection Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e5dd0fce-e9fb-47f9-a35c-518b50d2e66b/appId/080765e3-9336-4461-b934-310acccb907d) | Password Credentials | Unknown |\n| [networkcopilotRP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e6ab919c-572b-4d9c-b888-72d3861c3214/appId/d66e9e8e-53a4-420c-866d-5bb39aaea675) | Password Credentials | Unknown |\n| [Azure AD Identity Governance - Entitlement Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e98ae1ec-52fe-4fea-b555-0bb33e4215ed/appId/810dcf14-1858-4bf2-8134-4c369fa3235b) | Password Credentials | Unknown |\n| [Microsoft Teams Wiki Images Migration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ee7703d4-b0a7-42bd-9b4f-7db6f313971b/appId/823dfde0-1b9a-415a-a35a-1ad34e16dd44) | Password Credentials | Unknown |\n| [Cortana Experience with O365](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f27e36f6-a89f-457b-9efd-7d74297d21c4/appId/0a0a29f9-0a25-49c7-94bf-c53c3f8fa69d) | Password Credentials | Unknown |\n| [Microsoft To-Do](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f2f4bbef-96ba-4e48-9831-b589c94de05f/appId/2087bd82-7206-4c0a-b305-1321a39e5926) | Password Credentials | Unknown |\n| [Sherlock](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f45ca046-85fc-4bfe-9e7d-8d6793377dd2/appId/0e282aa8-2770-4b6c-8cf8-fac26e9ebe1f) | Password Credentials | Unknown |\n| [My Apps](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fae83da1-a996-452f-8dac-78d66dfd8cb0/appId/2793995e-0a7d-40d7-bd35-6968ba142197) | Password Credentials | Unknown |\n| [Customer Experience Platform PROD](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fd2577db-33f7-4d24-8b5c-569d9ac33089/appId/2220bbc4-4518-4fef-aac6-c6f32e9f9fd1) | Password Credentials | Unknown |\n| [Microsoft Customer Engagement Portal](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/fdfe6f97-94d7-4863-87dc-5bcfd92237dd/appId/71234da4-b92f-429d-b8ec-6e62652e50d7) | Password Credentials | Unknown |\n| [Intune DeviceDirectory ConfidentialClient](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/070ec1ff-9f95-4817-9258-72d77d552e6d/appId/7e313d81-57dd-4bdd-906e-337963583de3) | Password Credentials | Unknown |\n| [ZTNA Network Access Control Plane](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/08f3ae44-0454-4206-8488-8582c88a2818/appId/9d4afbbc-06a4-49e0-8005-4e5afd1d4fec) | Password Credentials | Unknown |\n| [OCPS Admin Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/09af0a69-22c1-4923-b488-91b0c5e09e5e/appId/f416c5fc-9ac4-4f66-a8e5-cb203139cbe4) | Password Credentials | Unknown |\n| [MSAI Substrate Meeting Intelligence ](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0d888197-9d2c-4a47-b110-db6ec7fee4e9/appId/038187f5-ca69-4382-8c0b-8d87708d099f) | Password Credentials | Unknown |\n| [Teams Admin Monitoring Alerting Platform](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0fcf3df7-0f62-4001-9fd8-663cff17cbc1/appId/f2537abf-644e-4a0d-9f7b-c91c45c643db) | Password Credentials | Unknown |\n| [Microsoft Teams ADL](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/14032cfd-fb94-4b5c-b5d6-c468b84da689/appId/30e31aeb-977f-4f4f-a483-b61e8377b302) | Password Credentials | Unknown |\n| [Azure SQL Managed Instance to Azure AD Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/140c7a88-c4af-4b91-842d-59e70ef7f9f9/appId/9c8b80bc-6887-42d0-b1af-d0c40f9bf1fa) | Password Credentials | Unknown |\n| [Microsoft Mobile Application Management Backend](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1dc80134-5de8-4ff6-8ec6-7b911b11692f/appId/354b5b6d-abd6-4736-9f51-1be80049b91f) | Password Credentials | Unknown |\n| [Outlook Online Add-in App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2877c8dc-0bcc-4cbc-bb75-562bea70aaf3/appId/bc59ab01-8403-45c6-8796-ac3ef710b3e3) | Password Credentials | Unknown |\n| [Skype for Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/32b1a859-ffeb-4d47-9cb3-0fd2516cb7c8/appId/7557eb47-c689-4224-abcf-aef9bd7573df) | Password Credentials | Unknown |\n| [Azure DevOps](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/377ce264-ba0c-480d-8c6d-e946b6b987e8/appId/499b84ac-1321-427f-aa17-267ca6975798) | Password Credentials | Unknown |\n| [Defender for Cloud - Private Link Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3e8f2398-e49c-4b38-b3cf-bd2b6be156b7/appId/d0ef82bb-244a-4458-9eb4-24a9f093f2c4) | Password Credentials | Unknown |\n| [AI Builder Authorization Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/42289f60-8be5-44ac-b368-2a8d8b915b40/appId/ad40333e-9910-4b61-b281-e3aeeb8c3ef3) | Password Credentials | Unknown |\n| [Microsoft.SecurityDevOps Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/46a7dd3d-45c1-4a6f-8d2c-092b9805ff81/appId/7bf610f7-ecaf-43a2-9dbc-33b14314d6fe) | Password Credentials | Unknown |\n| [SharePoint Home Notifier](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/47c3eb21-495a-429e-a323-c2b8a7d0b56c/appId/4e445925-163e-42ca-b801-9073bfa46d17) | Password Credentials | Unknown |\n| [Teams Application Gateway](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4f7d7026-dc28-4344-b6ae-c002affe30f5/appId/8a753eec-59bc-4c6a-be91-6bf7bfe0bcdf) | Password Credentials | Unknown |\n| [Permission Service O365](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/50454e63-5b1f-4534-995a-e82706dfdf72/appId/6d32b7f8-782e-43e0-ac47-aaad9f4eb839) | Password Credentials | Unknown |\n| [AzureBackup_WBCM_Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/57d650e5-d5b2-4f1b-a0c1-3df5c457e05c/appId/c505e273-0ba0-47e7-a0bd-f48042b4524d) | Password Credentials | Unknown |\n| [Microsoft Intune API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/58d48f35-fddf-4088-b203-bad041cbc481/appId/c161e42e-d4df-4a3d-9b42-e7a3c31f59d4) | Password Credentials | Unknown |\n| [Microsoft Defender For Cloud](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5925b7df-38b8-49f9-962b-c4eadffe208c/appId/6b5b3617-ba00-46f6-8770-1849282a189a) | Password Credentials | Unknown |\n| [CompliancePolicy](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/64df3296-03b2-441b-bad5-7139f688ae41/appId/644c1b11-f63f-45fa-826b-a9d2801db711) | Password Credentials | Unknown |\n| [GatewayRP](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/65a820a8-ac48-46b4-80b2-413f97f13ff4/appId/486c78bf-a0f7-45f1-92fd-37215929e116) | Password Credentials | Unknown |\n| [ISV Portal](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6616bae9-ebb3-47a9-8596-07bf4704e8cc/appId/c6871074-3ded-4935-a5dc-b8f8d91d7d06) | Password Credentials | Unknown |\n| [Office 365 Information Protection](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/661b49af-7812-42bb-abfb-a76218b5edfe/appId/2f3f02c9-5679-4a5c-a605-0de55b07d135) | Password Credentials | Unknown |\n| [Microsoft Rights Management Services Default](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/669d2289-5b75-4f9e-8886-4ae4bf825b23/appId/934d626a-1ead-4a36-a77d-12ec63b87a0d) | Password Credentials | Unknown |\n| [Azure AD Identity Governance Insights](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/680bdef1-aebe-4bc7-91a4-3dc1746a3cc2/appId/58c746b0-a0b0-4647-a8f6-12dde5981638) | Password Credentials | Unknown |\n| [MicrosoftGuestConfiguration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/691a35d0-9d51-4c5a-b524-10b95dbf42e8/appId/e935b4a5-8968-416d-8414-caed51c782a9) | Password Credentials | Unknown |\n| [Microsoft Information Protection API](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6a869d3c-53ec-459f-9db7-4f4383e81833/appId/40775b29-2688-46b6-a3b5-b256bd04df9f) | Password Credentials | Unknown |\n| [Microsoft Rights Management Services](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6fba8b5a-2cd8-48dc-ba25-a0cfc1738152/appId/00000012-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [Azure Notification Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/73398902-1dec-4a3a-955d-7a11a5e6ad9e/appId/b503eb83-1222-4dcc-b116-b98ed5216e05) | Password Credentials | Unknown |\n| [Microsoft Teams User Profile Search Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7575cdeb-377d-4f05-a2d6-3f7e6064244d/appId/a47591ab-e23e-4ffa-9e1b-809b9067e726) | Password Credentials | Unknown |\n| [Azure AD Application Proxy](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/776b207d-90e0-43ae-b11b-096a16cc9f83/appId/47ee738b-3f1a-4fc7-ab11-37e4822b007e) | Password Credentials | Unknown |\n| [Microsoft Discovery Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/78780920-1b57-42d0-b6b5-6ec4a5e14b00/appId/6f82282e-0070-4e78-bc23-e6320c5fa7de) | Password Credentials | Unknown |\n| [Common Data Service License Management](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/793683e9-c0be-4bd3-a997-10edcdbbea51/appId/1c2909a7-6432-4263-a70d-929a3c1f9ee5) | Password Credentials | Unknown |\n| [CABProvisioning](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7a4859a9-c2c9-4f40-898c-a0fd768df655/appId/5da7367f-09c8-493e-8fd4-638089cddec3) | Password Credentials | Unknown |\n| [Narada Notification Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/83c2d5e7-25e4-43c9-8cb3-16e10e3eea9e/appId/51b5e278-ed7e-42c6-8787-7ff93e92f577) | Password Credentials | Unknown |\n| [Dynamics Provision](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/9294d999-93b6-4696-9753-98aa1ab87227/appId/39e6ea5b-4aa4-4df2-808b-b6b5fb8ada6f) | Password Credentials | Unknown |\n| [AADPremiumService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/98105391-3893-4cf4-a710-3d9cdf804475/appId/bf4fa6bf-d24c-4d1c-8cfd-12063dd646b2) | Password Credentials | Unknown |\n| [Microsoft Seller Dashboard](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/98c3d1dc-0849-4472-9c54-4ad46ca47564/appId/0000000b-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [OneDrive Web](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a1898ba2-1474-4966-be6a-dd69bd63b7ed/appId/33be1cef-03fb-444b-8fd3-08ca1b4d803f) | Password Credentials | Unknown |\n| [Connectors](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a511793d-82f0-4966-9a4b-d2f913f8dc8c/appId/48af08dc-f6d2-435f-b2a7-069abd99c086) | Password Credentials | Unknown |\n| [Microsoft Teams Task Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a5cbc7c6-6728-49fd-ab39-0e28b13e0e1e/appId/d0597157-f0ae-4e23-b06c-9e65de434c4f) | Password Credentials | Unknown |\n| [Microsoft Fluid Framework Preview](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a726c920-17af-4091-98a9-c0685f6e1045/appId/660d4be7-2665-497f-9611-a42c2668dbce) | Password Credentials | Unknown |\n| [Microsoft Teams ATP Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ac7b4a4b-9880-42a9-9320-a9a0a7832411/appId/0fa37baf-7afc-4baf-ab2d-d5bb891d53ef) | Password Credentials | Unknown |\n| [Cortana Runtime Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b26c2477-5919-44da-b847-b38addc11d28/appId/81473081-50b9-469a-b9d8-303109583ecb) | Password Credentials | Unknown |\n| [Omnichannel for CS Provisioning App Primary](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b3e39f94-2742-464f-b82f-95e92bdaaf2c/appId/3957683c-3a48-4a6c-8706-a6e2d6883b02) | Password Credentials | Unknown |\n| [IAMTenantCrawler](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b8b3bdc4-490e-4289-8e07-56fc7985f83c/appId/66244124-575c-4284-92bc-fdd00e669cea) | Password Credentials | Unknown |\n| [PROD Microsoft Defender For Cloud XDR](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bc042abe-59d4-4a92-8ef6-21a4d198587b/appId/3f6aecb4-6dbf-4e45-9141-440abdced562) | Password Credentials | Unknown |\n| [Power Query Online GCC-L2](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bc225983-dfdd-4136-8034-0504e4cc815c/appId/939fe80f-2eef-464f-b0cf-705d254a2cf2) | Password Credentials | Unknown |\n| [Azure Information Protection](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bc900003-3253-4e9c-b8c8-1796b0919bbe/appId/5b20c633-9a48-4a5f-95f6-dae91879051f) | Password Credentials | Unknown |\n| [Office Hive](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d390a7f5-83ca-494c-a784-2ebc12941ae4/appId/166f1b03-5b19-416f-a94b-1d7aa2d247dc) | Password Credentials | Unknown |\n| [Microsoft Azure AD Identity Protection](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d4c4ebab-9ed9-48cc-93d3-e5ac638d9cdc/appId/a3dfc3c6-2c7d-4f42-aeec-b2877f9bce97) | Password Credentials | Unknown |\n| [Microsoft.ExtensibleRealUserMonitoring](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d791b3f5-65ef-491a-a5e8-3e5418c03be3/appId/e3583ad2-c781-4224-9b91-ad15a8179ba0) | Password Credentials | Unknown |\n| [App Studio for Microsoft Teams](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d9c01c25-3519-4130-af9b-9b618e0af377/appId/e1979c22-8b73-4aed-a4da-572cc4d0b832) | Password Credentials | Unknown |\n| [PowerApps-Advisor](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/da5cd935-47ec-4351-832b-4b8c76207127/appId/c9299480-c13a-49db-a7ae-cdfe54fe0313) | Password Credentials | Unknown |\n| [Azure SQL Virtual Network to Network Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dc8a60ab-df3d-4e21-b373-b7422ee84d54/appId/76cd24bf-a9fc-4344-b1dc-908275de6d6d) | Password Credentials | Unknown |\n| [Radius Aad Syncer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ddf76454-acee-410e-8c39-cffd8e60eee0/appId/60ca1954-583c-4d1f-86de-39d835f3e452) | Password Credentials | Unknown |\n| [Microsoft Teams Targeting Application](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/de9cfafb-1589-4946-ad6f-a273c294a6af/appId/8e14e873-35ba-4720-b787-0bed94370b17) | Password Credentials | Unknown |\n| [Windows Azure Security Resource Provider](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/deddc0fa-7d9a-4b53-ad10-de2af03c7729/appId/8edd93e1-2103-40b4-bd70-6e34e586362d) | Password Credentials | Unknown |\n| [Microsoft Visio Data Visualizer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/dfd4512c-9405-47ed-8db4-0b2c9a92e645/appId/00695ed2-3202-4156-8da1-69f60065e255) | Password Credentials | Unknown |\n| [Power Query Online GCC-L4](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e11eb56e-6221-4532-a003-04d4a972f4b1/appId/ef947699-9b52-4b31-9a37-ef325c6ffc47) | Password Credentials | Unknown |\n| [Microsoft Intune Checkin](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ea7d058d-b42d-4608-874e-1db715374304/appId/26a4ae64-5862-427f-a9b0-044e62572a4f) | Password Credentials | Unknown |\n| [Azns AAD Webhook](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/eaa31a30-b662-41eb-92b6-e15508db517b/appId/461e8683-5575-4561-ac7f-899cc907d62a) | Password Credentials | Unknown |\n| [OCaaS Experience Management Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/eaf30607-9d0e-4470-a2ff-9468d514dc4d/appId/6e99704e-62d5-40f6-b2fe-90aafbe3a710) | Password Credentials | Unknown |\n| [Microsoft Power BI Information Service](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/edd95e4d-8b5f-4e1d-a761-b12d1a41fa46/appId/0000001b-0000-0000-c000-000000000000) | Password Credentials | Unknown |\n| [CAS API Security RP Dev](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ee6d046b-9677-4968-bca7-2762635fe393/appId/cb250467-fc8f-4c42-8349-9ff9e9a17b02) | Password Credentials | Unknown |\n| [Azure Smart Alerts](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f2c3e108-fbb1-4521-953d-d3cd9ef25197/appId/3af5a1e8-2459-45cb-8683-bcd6cccbcc13) | Password Credentials | Unknown |\n| [OfficeClientService](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f3bea0c1-5c1c-4788-a8dc-311d5a731aae/appId/0f698dd4-f011-4d23-a33e-b36416dcb1e6) | Password Credentials | Unknown |\n| [Microsoft Defender For Cloud Discovery](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ffd25a11-4349-4a13-83e7-1cf14e7f22e0/appId/ee45196f-bd15-4010-9a66-c8497a97a873) | Password Credentials | Unknown |\n\n\n\n",
      "TestDescription": "Microsoft services applications that operate in your tenant are identified as service principals with the owner organization ID \"f8cdef31-a31e-4b4a-93e4-5f571e91255a.\" When these service principals have credentials configured in your tenant, they might create potential attack vectors that threat actors can exploit. If an administrator added the credentials and they're no longer needed, they can become a target for attackers. Although less likely when proper preventive and detective controls are in place on privileged activities, threat actors can also maliciously add credentials. In either case, threat actors can use these credentials to authenticate as the service principal, gaining the same permissions and access rights as the Microsoft service application. This initial access can lead to privilege escalation if the application has high-level permissions, allowing lateral movement across the tenant. Attackers can then proceed to data exfiltration or persistence establishment through creating other backdoor credentials.\n\nWhen credentials (like client secrets or certificates) are configured for these service principals in your tenant, it means someone - either an administrator or a malicious actor - enabled them to authenticate independently within your environment. These credentials should be investigated to determine their legitimacy and necessity. If they're no longer needed, they should be removed to reduce the risk. \n\nIf this check doesn't pass, the recommendation is to \"investigate\" because you need to identify and review any applications with unused credentials configured.\n\n**Remediation action**\n\n- Confirm if the credentials added are still valid use cases. If not, remove credentials from Microsoft service applications to reduce security risk. \n    - In the Microsoft Entra admin center, browse to **Entra ID** > **App registrations** and select the affected application.\n    - Go to the **Certificates & secrets** section and remove any credentials that are no longer needed.",
      "TestStatus": "Investigate",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Use cloud authentication",
      "TestRisk": "High",
      "TestId": "21829",
      "TestResult": "\nAll domains are using cloud authentication.\n\n\n\n",
      "TestDescription": "An on-premises federation server introduces a critical attack surface by serving as a central authentication point for cloud applications. Threat actors often gain a foothold by compromising a privileged user such as a help desk representative or an operations engineer through attacks like phishing, credential stuffing, or exploiting weak passwords. They might also target unpatched vulnerabilities in infrastructure, use remote code execution exploits, attack the Kerberos protocol, or use pass-the-hash attacks to escalate privileges. Misconfigured remote access tools like remote desktop protocol (RDP), virtual private network (VPN), or jump servers provide other entry points, while supply chain compromises or malicious insiders further increase exposure. Once inside, threat actors can manipulate authentication flows, forge security tokens to impersonate any user, and pivot into cloud environments. Establishing persistence, they can disable security logs, evade detection, and exfiltrate sensitive data.\n\n**Remediation action**\n\n- [Migrate from federation to cloud authentication like Microsoft Entra Password hash synchronization (PHS)](https://learn.microsoft.com/entra/identity/hybrid/connect/migrate-from-federation-to-cloud-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestStatus": "Passed",
      "TestImpact": "High"
    },
    {
      "TestTags": [
        "PrivilegedIdentity"
      ],
      "TestSkipped": "",
      "TestCategory": "Privileged access",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Privileged accounts are cloud native identities",
      "TestRisk": "High",
      "TestId": "21814",
      "TestResult": "\nValidated that standing or eligible privileged accounts are cloud only accounts.\n\n## Privileged Roles\n\n| Role Name | User | Source | Status |\n| :--- | :--- | :--- | :---: |\n| Global Administrator | [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165) | Cloud native identity | ✅ |\n| Global Administrator | [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e) | Cloud native identity | ✅ |\n| Global Administrator | [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a) | Cloud native identity | ✅ |\n| Global Administrator | [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7) | Cloud native identity | ✅ |\n| Global Administrator | [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003) | Cloud native identity | ✅ |\n| Global Administrator | [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a) | Cloud native identity | ✅ |\n| Global Administrator | [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d) | Cloud native identity | ✅ |\n| Global Administrator | [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854) | Cloud native identity | ✅ |\n| Global Administrator | [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6) | Cloud native identity | ✅ |\n\n\n",
      "TestDescription": "If an on-premises account is compromised and is synchronized to Microsoft Entra, the attacker might gain access to the tenant as well. This risk increases because on-premises environments typically have more attack surfaces due to older infrastructure and limited security controls. Attackers might also target the infrastructure and tools used to enable connectivity between on-premises environments and Microsoft Entra. These targets might include tools like Microsoft Entra Connect or Active Directory Federation Services, where they could impersonate or otherwise manipulate other on-premises user accounts.\n\nIf privileged cloud accounts are synchronized with on-premises accounts, an attacker who acquires credentials for on-premises can use those same credentials to access cloud resources and move laterally to the cloud environment.\n\n**Remediation action**\n\n- [Protecting Microsoft 365 from on-premises attacks](https://learn.microsoft.com/entra/architecture/protect-m365-from-on-premises-attacks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#specific-security-recommendations)\n\nFor each role with high privileges (assigned permanently or eligible through Microsoft Entra Privileged Identity Management), you should do the following actions:\n\n- Review the users that have onPremisesImmutableId and onPremisesSyncEnabled set. See [Microsoft Graph API user resource type](https://learn.microsoft.com/graph/api/resources/user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Create cloud-only user accounts for those individuals and remove their hybrid identity from privileged roles.\n",
      "TestStatus": "Passed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Monitoring",
      "SkippedReason": null,
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All high-risk users are triaged",
      "TestRisk": "High",
      "TestId": "21861",
      "TestResult": "\nAll high-risk users are properly triaged in Entra ID Protection.\n\n",
      "TestDescription": "Users considered at high risk by Microsoft Entra ID Protection have a high probability of compromise by threat actors. Threat actors can gain initial access via compromised valid accounts, where their suspicious activities continue despite triggering risk indicators. This oversight can enable persistence as threat actors perform activities that normally warrant investigation, such as unusual login patterns or suspicious inbox manipulation. \n\nA lack of triage of these risky users allows for expanded reconnaissance activities and lateral movement, with anomalous behavior patterns continuing to generate uninvestigated alerts. Threat actors become emboldened as security teams show they aren't actively responding to risk indicators.\n\n**Remediation action**\n\n- [Investigate high risk users](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in Microsoft Entra ID Protection\n- [Remediate high risk users and unblock](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-remediate-unblock?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in Microsoft Entra ID Protection\n",
      "TestStatus": "Passed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Restrict access to high risk users",
      "TestRisk": "High",
      "TestId": "21797",
      "TestResult": "\nPolicies to restrict access for high risk users are properly implemented.\n## Passwordless Authentication Methods allowed in tenant\n\n| Authentication Method Name | State | Additional Info |\n| :------------------------ | :---- | :-------------- |\n| Fido2 | enabled |  |\n\n## Conditional Access Policies targeting high risk users\n\n| Conditional Access Policy Name | Status | Conditions |\n| :--------------------- | :----- | :--------- |\n| [Require password change for high-risk users](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/ddbc3bb1-3749-474f-b8c3-0d997118b24b) | Enabled | User Risk Level: High, Control: Password Change |\n| [CISA SCuBA.MS.AAD.2.3: Users detected as high risk SHALL be blocked.](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/94c7d8d0-5c8c-460d-8ace-364374250893) | Enabled | User Risk Level: High, Control: Block |\n| [Force Password Change](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/5848211d-96f2-40ae-92a4-af1aa8f48572) | Disabled | User Risk Level: High, Control: Password Change |\n\n\n",
      "TestDescription": "Assume any users at high risk are compromised by threat actors. Without investigation and remediation, threat actors can execute scripts, deploy malicious applications, or manipulate API calls to establish persistence, based on the potentially compromised user's permissions. Threat actors can then exploit misconfigurations or abuse OAuth tokens to move laterally across workloads like documents, SaaS applications, or Azure resources. Threat actors can gain access to sensitive files, customer records, or proprietary code and exfiltrate it to external repositories while maintaining stealth through legitimate cloud services. Finally, threat actors might disrupt operations by modifying configurations, encrypting data for ransom, or using the stolen information for further attacks, resulting in financial, reputational, and regulatory consequences.\n\n**Remediation action**\n\n- Create a Conditional Access policy to [require a secure password change for elevated user risk](https://learn.microsoft.com/entra/identity/conditional-access/policy-risk-based-user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Use Microsoft Entra ID Protection to [further investigate risk](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestStatus": "Passed",
      "TestImpact": "High"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Global Administrator role activation triggers an approval workflow",
      "TestRisk": "High",
      "TestId": "21817",
      "TestResult": "\n✅ **Pass**: Approval required with 2 primary approver(s) configured.\n\n\n## Global Administrator role activation and approval workflow\n\n\n| Approval Required | Primary Approvers | Escalation Approvers |\n| :---------------- | :---------------- | :------------------- |\n| Yes | Aleksandar Nikolic, Merill Fernando |  |\n\n\n\n",
      "TestDescription": "Without approval workflows, threat actors who compromise Global Administrator credentials through phishing, credential stuffing, or other authentication bypass techniques can immediately activate the most privileged role in a tenant without any other verification or oversight. Privileged Identity Management (PIM) allows eligible role activations to become active within seconds, so compromised credentials can allow near-instant privilege escalation. Once activated, threat actors can use the Global Administrator role to use the following attack paths to gain persistent access to the tenant:\n- Create new privileged accounts\n- Modify Conditional Access policies to exclude those new accounts\n- Establish alternate authentication methods such as certificate-based authentication or application registrations with high privileges\n\nThe Global Administrator role provides access to administrative features in Microsoft Entra ID and services that use Microsoft Entra identities, including Microsoft Defender XDR, Microsoft Purview, Exchange Online, and SharePoint Online. Without approval gates, threat actors can rapidly escalate to complete tenant takeover, exfiltrating sensitive data, compromising all user accounts, and establishing long-term backdoors through service principals or federation modifications that persist even after the initial compromise is detected. \n\n**Remediation action**\n\n- [Configure role settings to require approval for Global Administrator activation](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Set up approval workflow for privileged roles](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-approval-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestStatus": "Passed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Monitoring",
      "SkippedReason": null,
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All high-risk sign-ins are triaged",
      "TestRisk": "High",
      "TestId": "21863",
      "TestResult": "\nNo untriaged risky sign ins in the tenant.\n\n",
      "TestDescription": "Risky sign-ins flagged by Microsoft Entra ID Protection indicate a high probability of unauthorized access attempts. Threat actors use these sign-ins to gain an initial foothold. If these sign-ins remain uninvestigated, adversaries can establish persistence by repeatedly authenticating under the guise of legitimate users. \n\nA lack of response lets attackers execute reconnaissance, attempt to escalate their access, and blend into normal patterns. When untriaged sign-ins continue to generate alerts and there's no intervention, security gaps widen, facilitating lateral movement and defense evasion, as adversaries recognize the absence of an active security response.\n\n**Remediation action**\n\n- [Investigate risky sign-ins](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Remediate risks and unblock users](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-remediate-unblock?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Passed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Credential management",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Migrate from legacy MFA and SSPR policies",
      "TestRisk": "High",
      "TestId": "21803",
      "TestResult": "\nCombined registration is enabled.\n\n\n\n",
      "TestDescription": "Legacy multifactor authentication (MFA) and self-service password reset (SSPR) policies in Microsoft Entra ID manage authentication methods separately, leading to fragmented configurations and suboptimal user experience. Moreover, managing these policies independently increases administrative overhead and the risk of misconfiguration.  \n\nMigrating to the combined Authentication Methods policy consolidates the management of MFA, SSPR, and passwordless authentication methods into a single policy framework. This unification allows for more granular control, enabling administrators to target specific authentication methods to user groups and enforce consistent security measures across the organization. Additionally, the unified policy supports modern authentication methods, such as FIDO2 security keys and Windows Hello for Business, enhancing the organization's security posture.\n\nMicrosoft announced the deprecation of legacy MFA and SSPR policies, with a retirement date set for September 30, 2025. Organizations are advised to complete the migration to the Authentication Methods policy before this date to avoid potential disruptions and to benefit from the enhanced security and management capabilities of the unified policy.\n\n**Remediation action**\n\n- [Enable combined security information registration](https://learn.microsoft.com/entra/identity/authentication/howto-registration-mfa-sspr-combined?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [How to migrate MFA and SSPR policy settings to the Authentication methods policy for Microsoft Entra ID](https://learn.microsoft.com/entra/identity/authentication/how-to-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Passed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Tenant restrictions v2 policy is configured",
      "TestRisk": "High",
      "TestId": "21793",
      "TestResult": "\nTenant Restrictions v2 policy is properly configured.\n\n\n## Tenant restriction settings\n\n\n| Policy Configured | External users and groups | External applications |\n| :---------------- | :------------------------ | :-------------------- |\n| [Yes](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/TenantRestrictions.ReactView/isDefault~/true/name//id/) | All external users and groups | All external applications |\n\n\n\n",
      "TestDescription": "Tenant Restrictions v2 (TRv2) allows organizations to enforce policies that restrict access to specified Microsoft Entra tenants, preventing unauthorized exfiltration of corporate data to external tenants using local accounts. Without TRv2, threat actors can exploit this vulnerability, which leads to potential data exfiltration and compliance violations, followed by credential harvesting if those external tenants have weaker controls. Once credentials are obtained, threat actors can gain initial access to these external tenants. TRv2 provides the mechanism to prevent users from authenticating to unauthorized tenants. Otherwise, threat actors can move laterally, escalate privileges, and potentially exfiltrate sensitive data, all while appearing as legitimate user activity that bypasses traditional data loss prevention controls focused on internal tenant monitoring.\n\nImplementing TRv2 enforces policies that restrict access to specified tenants, mitigating these risks by ensuring that authentication and data access are confined to authorized tenants only. \n\nIf this check passes, your tenant has a TRv2 policy configured but more steps are required to validate the scenario end-to-end.\n\n**Remediation action**\n- [Set up Tenant Restrictions v2](https://learn.microsoft.com/en-us/entra/external-id/tenant-restrictions-v2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestStatus": "Passed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Require multifactor authentication for device join and device registration using user action",
      "TestRisk": "High",
      "TestId": "21872",
      "TestResult": "\n**Properly configured Conditional Access policies found** that require MFA for device registration/join actions.\n## Device Settings Configuration\n\n| Setting | Value | Recommended Value | Status |\n| :------ | :---- | :---------------- | :----- |\n| Require Multi-Factor Authentication to register or join devices | No | No | ✅ Correctly configured |\n\n## Device Registration/Join Conditional Access Policies\n\n| Policy Name | State | Requires MFA | Status |\n| :---------- | :---- | :----------- | :----- |\n| [testdevicereg21872](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/620a9c5c-09c4-4558-a0fe-7fc8b3540992) | enabled | Yes | ✅ Properly configured |\n\n\n",
      "TestDescription": "Threat actors can exploit the lack of multifactor authentication during new device registration. Once authenticated, they can register rogue devices, establish persistence, and circumvent security controls tied to trusted endpoints. This foothold enables attackers to exfiltrate sensitive data, deploy malicious applications, or move laterally, depending on the permissions of the accounts being used by the attacker. Without MFA enforcement, risk escalates as adversaries can continuously reauthenticate, evade detection, and execute objectives.\n\n**Remediation action**\n\n- Create a Conditional Access policy to [require multifactor authentication for device registration](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-device-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestStatus": "Passed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": null,
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Authentication transfer is blocked",
      "TestRisk": "High",
      "TestId": "21828",
      "TestResult": "\nAuthentication transfer is blocked by Conditional Access Policy(s).\n## Conditional Access Policies targeting Authentication Transfer\n\n\n| Policy Name | Policy ID | State | Created | Modified |\n| :---------- | :-------- | :---- | :------ | :------- |\n| [Block Device Code](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/db2153a1-40a2-457f-917c-c280b204b5cd) | db2153a1-40a2-457f-917c-c280b204b5cd | enabled | 02/28/2024 00:22:50 | 04/16/2025 08:28:40 |\n\n\n",
      "TestDescription": "Blocking authentication transfer in Entra ID is a critical security control that helps protect against token theft and replay attacks by preventing the use of device tokens to silently authenticate on other devices or browsers. When authentication transfer is enabled, a threat actor who gains access to one device can access resources to non-approved devices, bypassing standard authentication and device compliance checks. By blocking this flow, organizations can ensure that each authentication request must originate from the original device, maintaining the integrity of the device compliance and user session context.\n\n**Remediation action**\n- [Block authentication flows with Conditional Access policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-block-authentication-flows)\n",
      "TestStatus": "Passed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "ConditionalAccess"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Restrict device code flow",
      "TestRisk": "High",
      "TestId": "21808",
      "TestResult": "\nDevice code flow is properly restricted in the tenant.\n## Conditional Access Policies targeting Device Code Flow\n\n| Policy Name | Status | Target Users | Target Resources | Grant Controls |\n| :---------- | :----- | :----------- | :--------------- | :------------ |\n| [Block Device Code](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/db2153a1-40a2-457f-917c-c280b204b5cd) | Enabled | All Users, Excluded: 3 users/groups | All Applications | Block (ANY) |\n\n## Inactive Conditional Access Policies targeting Device Code Flow\nThese policies are not contributing to your security posture because they are not enabled:\n\n| Policy Name | Status | Target Users | Target Resources | Grant Controls |\n| :---------- | :----- | :----------- | :--------------- | :------------ |\n| [Block DCF](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/b5ff217b-3d84-4581-bd92-5d8f8b8bab6a) | Disabled | All Users | All Applications | Block (ANY) |\n\n\n",
      "TestDescription": "Device code flow is a cross-device authentication flow designed for input-constrained devices. It can be exploited in phishing attacks, where an attacker initiates the flow and tricks a user into completing it on their device, thereby sending the user's tokens to the attacker. Given the security risks and the infrequent legitimate use of device code flow, you should enable a Conditional Access policy to block this flow by default.\n\n**Remediation action**\n\n- Create a Conditional Access policy to [block device code flow](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-authentication-flows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#device-code-flow-policies).\n- [Learn more about device code flow](https://learn.microsoft.com/entra/identity/conditional-access/concept-authentication-flows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#device-code-flow)\n",
      "TestStatus": "Passed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Require password reset notifications for administrator roles",
      "TestRisk": "High",
      "TestId": "21891",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestDescription": "Configuring password reset notifications for administrator roles in Microsoft Entra ID enhances security by notifying privileged administrators when another administrator resets their password. This visibility helps detect unauthorized or suspicious activity that could indicate credential compromise or insider threats. Without these notifications, malicious actors could exploit elevated privileges to establish persistence, escalate access, or extract sensitive data. Proactive notifications support quick action, preserve privileged access integrity, and strengthen the overall security posture.   \n\n**Remediation action**\n\n- [Notify all admins when other admins reset their passwords](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-howitworks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#notify-all-admins-when-other-admins-reset-their-passwords) \n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Azure subscriptions used by Identity Governance are secured consistently with Identity Governance roles",
      "TestRisk": "High",
      "TestId": "21881",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All risk detections are triaged",
      "TestRisk": "High",
      "TestId": "21864",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All risky workload identity sign ins are triaged",
      "TestRisk": "High",
      "TestId": "22659",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "ID Protection notifications are enabled",
      "TestRisk": "High",
      "TestId": "21798",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestDescription": "If you don't enable ID Protection notifications, your organization loses critical real-time alerts when threat actors compromise user accounts or conduct reconnaissance activities. When Microsoft Entra ID Protection detects accounts at risk, it sends email alerts with **Users at risk detected** as the subject and links to the **Users flagged for risk** report. Without these notifications, security teams remain unaware of active threats, allowing threat actors to maintain persistence in compromised accounts without being detected. You can feed these risks into tools like Conditional Access to make access decisions or send them to a security information and event management (SIEM) tool for investigation and correlation. Threat actors can use this detection gap to conduct lateral movement activities, privilege escalation attempts, or data exfiltration operations while administrators remain unaware of the ongoing compromise. The delayed response enables threat actors to establish more persistence mechanisms, change user permissions, or access sensitive resources before you can fix the issue. Without proactive notification of risk detections, organizations must rely solely on manual monitoring of risk reports, which significantly increases the time it takes to detect and respond to identity-based attacks.   \n\n**Remediation action**\n\n- [Configure users at risk detected alerts](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-notifications?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-users-at-risk-detected-alerts)  \n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Authentication"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Privileged access",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Privileged users sign in with phishing-resistant methods",
      "TestRisk": "High",
      "TestId": "21781",
      "TestResult": "\nFound Accounts have not registered phishing resistant methods\n\n\n\n",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Azure resources used by Microsoft Entra only allow access from privileged roles",
      "TestRisk": "High",
      "TestId": "21912",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Device management",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Limit the maximum number of devices per user to 10",
      "TestRisk": "Low",
      "TestId": "21837",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Temporary access pass is enabled",
      "TestRisk": "Low",
      "TestId": "21845",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Security key authentication method enabled",
      "TestRisk": "Low",
      "TestId": "21838",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Privileged access",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "High Global Administrator to privileged user ratio",
      "TestRisk": "Low",
      "TestId": "21813",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Manage the local administrators on Microsoft Entra joined devices",
      "TestRisk": "Low",
      "TestId": "21955",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Enable Microsoft Entra ID Protection policy to enforce multifactor authentication registration",
      "TestRisk": "Low",
      "TestId": "21893",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Privileged access",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Maximum number of Global Administrators doesn't exceed eight users",
      "TestRisk": "Low",
      "TestId": "21812",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Enable SSPR",
      "TestRisk": "Low",
      "TestId": "21870",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All enterprise applications have owners",
      "TestRisk": "Low",
      "TestId": "21867",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Block legacy Microsoft Online PowerShell module",
      "TestRisk": "Low",
      "TestId": "21843",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Directory sync account is locked down to specific named location",
      "TestRisk": "Low",
      "TestId": "21834",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Passkey authentication method enabled",
      "TestRisk": "Low",
      "TestId": "21839",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Tenant app management policy is configured",
      "TestRisk": "Low",
      "TestId": "21775",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Block administrators from using SSPR",
      "TestRisk": "Low",
      "TestId": "21842",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Enable custom banned passwords",
      "TestRisk": "Low",
      "TestId": "21848",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All certificates Microsoft Entra Application Registrations and Service Principals must be issued by an approved certification authority",
      "TestRisk": "Low",
      "TestId": "21894",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Privileged access",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All privileged role assignments are managed with PIM",
      "TestRisk": "Low",
      "TestId": "21816",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "No Active low priority Entra recommendations found",
      "TestRisk": "Low",
      "TestId": "21984",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Enable protected actions to secure Conditional Access policy creation and changes",
      "TestRisk": "Low",
      "TestId": "21964",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Block legacy Azure AD PowerShell module",
      "TestRisk": "Low",
      "TestId": "21844",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Privileged access",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Activation alert for all privileged role assignments",
      "TestRisk": "Low",
      "TestId": "21820",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Restrict nonadministrator users from recovering the BitLocker keys for their owned devices",
      "TestRisk": "Low",
      "TestId": "21954",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Privileged access",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Directory Sync account credentials haven't been rotated recently",
      "TestRisk": "Low",
      "TestId": "21833",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Temporary access pass restricted to one-time use",
      "TestRisk": "Low",
      "TestId": "21846",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Authenticator app report suspicious activity is enabled",
      "TestRisk": "Low",
      "TestId": "21841",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Local Admin Password Solution is deployed",
      "TestRisk": "Low",
      "TestId": "21953",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Privileged access",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Emergency account exists",
      "TestRisk": "Low",
      "TestId": "21835",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Application Certificate Credentials are managed using HSM",
      "TestRisk": "Low",
      "TestId": "21895",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Security key attestation is enforced",
      "TestRisk": "Low",
      "TestId": "21840",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Reduce the user-visible password surface area",
      "TestRisk": "Low",
      "TestId": "21889",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "User",
        "Credential"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Block legacy authentication policy is configured",
      "TestRisk": "Medium",
      "TestId": "21796",
      "TestResult": "\nPolicies to block legacy authentication were found but are not properly configured.\n\n  - [Block legacy authentication](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/4086128c-3850-48ac-8962-e19a956828bd) (Report-only)\n  - [Block legacy authentication - Testing](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/bedecc1e-85c9-4d54-b885-cefe6bcc8763) (Report-only)\n\n\n",
      "TestDescription": "Legacy authentication protocols such as basic authentication for SMTP and IMAP don't support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This lack of protection makes accounts using these protocols vulnerable to password-based attacks, and provides attackers with a means to gain initial access using stolen or guessed credentials.\n\nWhen an attacker successfully gains unauthorized access to credentials, they can use them to access linked services, using the weak authentication method as an entry point. Attackers who gain access through legacy authentication might make changes to Microsoft Exchange, such as configuring mail forwarding rules or changing other settings, allowing them to maintain continued access to sensitive communications.\n\nLegacy authentication also provides attackers with a consistent method to reenter a system using compromised credentials without triggering security alerts or requiring reauthentication.\n\nFrom there, attackers can use legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement. Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.\n\n**Remediation action**\n\nDeploy the following Conditional Access policy:\n\n- [Block legacy authentication](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Failed",
      "TestImpact": "High"
    },
    {
      "TestTags": [
        "Application"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Applications don't have certificates with expiration longer than 180 days",
      "TestRisk": "Medium",
      "TestId": "21773",
      "TestResult": "\nFound 6 applications and 3 service principals with certificates longer than 180 days\n\n\n## Applications with long-lived credentials\n\n| Application | Certificate expiry |\n| :--- | :--- |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2125-03-03 00:00:00 |\n\n\n## Service principals with long-lived credentials\n\n| Service principal | App owner tenant | Certificate expiry |\n| :--- | :--- | :--- |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-01-07 00:00:00 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/15/2027 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/26/2028 |\n\n\n",
      "TestDescription": "Certificates, if not securely stored, can be extracted and exploited by attackers, leading to unauthorized access. Long-lived certificates are more likely to be exposed over time. Credentials, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the privileges of the application.\n\n**Remediation action**\n\n- [Define certificate based application configuration](https://devblogs.microsoft.com/identity/app-management-policy/)\n- [Define trusted certificate authorities for apps and service principals in the tenant](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Define application management policies](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Enforce secret and certificate standards](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/tutorial-enforce-secret-standards?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create a least-privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Resource-specific consent is restricted",
      "TestRisk": "Medium",
      "TestId": "21810",
      "TestResult": "\nResource-Specific Consent is not restricted.\n\nThe current state is ManagedByMicrosoft.\n\n\n",
      "TestDescription": "Letting group owners consent to applications in Microsoft Entra ID creates a lateral escalation path that lets threat actors persist and steal data without admin credentials. If an attacker compromises a group owner account, they can register or use a malicious application and consent to high-privilege Graph API permissions scoped to the group. Attackers can potentially read all Teams messages, access SharePoint files, or manage group membership. This consent action creates a long-lived application identity with delegated or application permissions. The attacker maintains persistence with OAuth tokens, steals sensitive data from team channels and files, and impersonates users through messaging or email permissions. Without centralized enforcement of app consent policies, security teams lose visibility, and malicious applications spread under the radar, enabling multi-stage attacks across collaboration platforms.\n\n**Remediation action**\nConfigure preapproval of Resource-Specific Consent (RSC) permissions.\n- [Preapproval of RSC permissions](https://learn.microsoft.com/microsoftteams/platform/graph-api/rsc/preapproval-instruction-docs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Failed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Workload Identities are configured with risk-based policies",
      "TestRisk": "Medium",
      "TestId": "21883",
      "TestResult": "\nWorkload identities based on risk policy is not configured.\n\n",
      "TestDescription": "Set up risk-based Conditional Access policies for workload identities based on risk policy in Microsoft Entra ID to make sure only trusted and verified workloads use sensitive resources. Without these policies, threat actors can compromise workload identities with minimal detection and perform further attacks. Without conditional controls to detect anomalous activity and other risks, there's no check against malicious operations like token forgery, access to sensitive resources, and disruption of workloads. The lack of automated containment mechanisms increases dwell time and affects the confidentiality, integrity, and availability of critical services.   \n\n**Remediation action**\nCreate a risk-based Conditional Access policy for workload identities.\n- [Create a risk-based Conditional Access policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-risk-based-conditional-access-policy)   \n",
      "TestStatus": "Failed",
      "TestImpact": "High"
    },
    {
      "TestTags": [
        "Credential"
      ],
      "TestSkipped": "",
      "TestCategory": "Credential management",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Users have strong authentication methods configured",
      "TestRisk": "Medium",
      "TestId": "21801",
      "TestResult": "\nFound users that have not yet registered phishing resistant authentication methods\n\n## Users strong authentication methods\n\nFound users that have not registered phishing resistant authentication methods.\n\nUser | Last sign in | Phishing resistant method registered |\n| :--- | :--- | :---: |\n|[Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true)| 2025-09-07 16:49:10 | ❌ |\n|[Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Anna Jorayew](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/58d9ed99-93ca-4674-8c5f-ec770f5ba17d/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Bagul Atayewa](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5655cf54-34bc-4f36-bb74-44da35547975/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true)| 01/20/2024 08:00:27 | ❌ |\n|[Daniel Nguyen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ddfb9311-801e-4a84-9466-a18086768b73/hidePreviewBanner~/true)| Unknown | ❌ |\n|[David Kim](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1b156c3d-79c5-44d2-a88c-23f69216777f/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Emma Johnson](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e498eab5-b6b5-493f-8353-b8c350083791/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Faiza Malkia](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/36bf7e02-3abc-46aa-895f-cf95227377fd/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true)| 11/15/2023 18:36:22 | ❌ |\n|[Hamisi Khari](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/494995bf-5510-450c-a317-6d24f63cd15b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Henrietta Mueller](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/eb6a4040-3ff6-4911-a80d-68c701384c38/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Isaiah Langer](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2a054082-8f05-4e05-8fce-4e35c3bb40cc/hidePreviewBanner~/true)| 2023-12-12 21:32:39 | ❌ |\n|[Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0145d508-50fd-4f86-a47a-bf1c043c8358/hidePreviewBanner~/true)| Unknown | ❌ |\n|[James Thompson](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ba635de8-4625-42eb-a59a-87f507ad9a9e/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Jane Doe](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/57c41b80-a96a-4c06-8ab9-9539818a637f/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Jessica Taylor](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/983164a3-87fa-4071-aa67-ff1530092df1/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Johanna Lorenz](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/8994aee7-8c36-4e04-9116-8f21d8acdeb7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John Doe Test 1](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/69a2da18-6395-4a90-bde8-72e8aaa6c775/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John Doe Test 1](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/fcebe3cc-ca26-49c6-9bb1-c9eafb243634/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John1 Doe](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/77d4be98-c05d-4478-be25-3ee710b5247e/hidePreviewBanner~/true)| 2024-04-11 20:02:45 | ❌ |\n|[Joni Sherman](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2da436f2-952a-47de-9dfe-84bd2f0d93e9/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Lee Gu](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0a9e313b-8777-4741-ba14-0f2724179117/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Lidia Holloway](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/9188d3d3-386c-4145-a811-0d777a288e11/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Lynne Robbins](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/8e5f7749-d5e7-46fc-8eb7-3b8ab7e20ae5/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true)| 2025-07-07 09:48:49 | ❌ |\n|[Megan Bowen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/96d29f01-873c-46a3-b542-f7ee192cc675/hidePreviewBanner~/true)| 06/28/2025 12:47:54 | ❌ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a0883b7a-c6a8-440f-84f0-d6e1b79aaf4c/hidePreviewBanner~/true)| 2024-10-05 03:19:56 | ❌ |\n|[Michael Wong](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/63e4e634-15e4-4a85-bc9c-532855574377/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Miriam Graham](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f5745554-1894-4fb0-9560-65d6fc489724/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Nestor Wilke](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/24b9254d-1bc5-435c-ad3d-7dbee86f8b9a/hidePreviewBanner~/true)| Unknown | ❌ |\n|[New User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/6eef8ea0-1263-4973-9b0b-1e7aed0d21cd/hidePreviewBanner~/true)| Unknown | ❌ |\n|[No Location](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/696743fa-055b-42fb-aac4-ab451a4617d6/hidePreviewBanner~/true)| Unknown | ❌ |\n|[NoMail Enabled](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a740d122-ee21-4354-9423-adccf8b6b233/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Olivia Patel](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/03a5c332-4d75-47fd-b211-838e8cd0ee1b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f/hidePreviewBanner~/true)| 06/17/2024 04:12:01 | ❌ |\n|[Patti Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/3bae3a95-7605-4271-8418-e35733991834/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Pradeep Gupta](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ac712f60-0052-4911-8c5d-146cf9d4dc59/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Rhea Stone](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ac49a6e5-09c1-404b-915e-0d28574b3d72/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Richard Wilkings](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c27e2b23-c322-4a79-8c6f-9dba8fd9f4e2/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Roi Fraguela](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e0a814e5-5169-4af2-bb19-63930b42ac41/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Ryan Chen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/9605b9f8-9823-4c33-8018-57ad32d9fcb9/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Sandy](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d5e32d0c-3f3c-43ef-abe1-75890a73f40c/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Sarah Mitchell](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0ca3a9f0-7e3c-44c5-9638-250be0d94621/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Shonali Balakrishna](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/305bbf73-eee4-4e0c-9c7d-627e00ed3665/hidePreviewBanner~/true)| 2025-05-05 23:28:41 | ❌ |\n|[Simon Burn](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c3aab1a2-0733-438d-bc14-90dc8f6d876d/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Sophia Rodriguez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d5d9f31f-c8d7-4b6c-bfca-b25b1cd4c1f1/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Tegra Núnez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/25e54254-3719-4c07-a880-3aee6bc60876/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Tracy yu](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/80153e0b-dcce-42de-9df6-59a3fc89479b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true)| 2025-04-02 23:17:44 | ❌ |\n|[Unlicensed User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7804b01c-1223-4045-a393-43171298fa6b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[usernonick](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/b531f68f-8d01-467b-9db6-a57438b0e8af/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Wilna Rossouw](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/62cd4528-8e5d-4789-84f6-8b33d0af5ca7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Yakup Meredow](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/767bcbda-28a0-4e5f-841d-e918c5a1c229/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Alex Wilber](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f10bc459-0bcf-49d0-8f86-4553b8f015b8/hidePreviewBanner~/true)| 06/28/2025 23:45:45 | ✅ |\n|[Diego Siciliani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/cdfa577c-972f-4399-98aa-1ec4be7fa6d1/hidePreviewBanner~/true)| 06/28/2025 23:31:12 | ✅ |\n|[Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true)| 06/23/2025 02:34:41 | ✅ |\n|[Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true)| 2025-09-07 00:50:46 | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| 2025-09-07 12:33:22 | ✅ |\n\n\n",
      "TestDescription": "Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.\n\nAttackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.\n\n**Remediation action**\n\n- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policies to enforce authentication strength](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestStatus": "Failed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Application"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Inactive applications don’t have highly privileged Microsoft Graph API permissions",
      "TestRisk": "Medium",
      "TestId": "21770",
      "TestResult": "\nInactive Application(s) with high privileges were found\n\n\n## Apps with privileged Graph permissions\n\n| | Name | Risk | Delegate Permission | Application Permission | App owner tenant | Last sign in|\n| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n| ❌ | [Reset Viral Users Redemption Status](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3a8785da-9965-473f-a97c-25fefdc39fee/appId/cc7b0696-1956-408b-876a-ad6bf2b9890b) | High | User.Read, User.Invite.All, User.ReadWrite.All, Directory.ReadWrite.All, offline_access, profile, openid |  |  | Unknown | \n| ❌ | [Microsoft Sample Data Packs](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/63e1f0d4-bc2c-497a-bfe2-9eb4c8c2600e/appId/a1cffbc6-1cb3-44e4-a1d2-cee9cce700f1) | High | Files.ReadWrite, User.ReadWrite | Contacts.ReadWrite, Sites.Manage.All, Sites.FullControl.All, Calendars.ReadWrite.All, Mail.ReadWrite, User.ReadWrite.All, Mail.Send, Application.ReadWrite.OwnedBy, Calendars.ReadWrite, MailboxSettings.ReadWrite, Sites.ReadWrite.All, Directory.ReadWrite.All, Files.ReadWrite.All, Group.ReadWrite.All |  | Unknown | \n| ❌ | [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6d2e8d37-82b8-41e7-aa95-443a7401e8b8/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | High | User.Read | User.ReadWrite.All, User.Read.All, Sites.FullControl.All, TermStore.Read.All |  | Unknown | \n| ❌ | [Graph Explorer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f8f300a-870a-46ff-bdab-934e1436920d/appId/d3ce4cf8-6810-442d-b42e-375e14710095) | High | User.Read, Directory.AccessAsUser.All |  |  | Unknown | \n| ❌ | [Modern Workplace Concierge](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad1c51e8-f8a8-4bf2-ac09-a3a20cba5fa5/appId/c65c4011-1b90-4ec9-b5e9-1ee17786ad84) | High | openid, profile, RoleManagement.Read.Directory, Application.Read.All, User.ReadBasic.All, Group.ReadWrite.All, DeviceManagementRBAC.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, Policy.Read.All, User.Read, DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All |  |  | Unknown | \n| ❌ | [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bac0ba57-1876-448e-96bf-6f0481c99fda/appId/fef811e1-2354-43b0-961b-248fe15e737d) | High | User.Read, Directory.Read.All |  |  | Unknown | \n| ❌ | [Azure AD Assessment (Test)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d4cf4286-0fbe-424d-b4f2-65aa2c568631/appId/c62a9fcb-53bf-446e-8063-ea6e2bfcc023) | High | AuditLog.Read.All, Directory.AccessAsUser.All, Directory.ReadWrite.All, Group.ReadWrite.All, IdentityProvider.ReadWrite.All, Policy.ReadWrite.TrustFramework, PrivilegedAccess.ReadWrite.AzureAD, PrivilegedAccess.ReadWrite.AzureResources, TrustFrameworkKeySet.ReadWrite.All, User.Invite.All, offline_access, openid, profile |  |  | Unknown | \n| ❌ | [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f79df990-9ad2-4142-b5fd-8945ff334da3/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | High | User.Read | Directory.ReadWrite.All |  | Unknown | \n| ❌ | [Cool New for Telstra](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3d6c91cf-d48f-4272-ac4c-9f989bbec779/appId/d77611ee-5051-4383-9af3-5ba3627306a7) | High |  | Application.Read.All |  | Unknown | \n| ❌ | [test public client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5e80ea33-31fa-49fd-9a94-61894bd1a6c9/appId/79a0c604-f215-4c52-8fbe-641d08aa7937) | High |  | User.Read.All |  | Unknown | \n| ❌ | [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6bf7c616-88e8-4f7c-bdad-452e561fa777/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | High |  | User.ReadWrite.All |  | Unknown | \n| ❌ | [Windows Virtual Desktop AME](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8369f33c-da25-4a8a-866d-b0145e29ef29/appId/5a0aa725-4958-4b0c-80a9-34562e23f3b7) | High |  | User.Read.All, Directory.Read.All |  | Unknown | \n| ❌ | [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/35cbeecb-be21-4596-9869-0157d84f2d67/appId/c823a25d-fe94-494c-91f6-c7d51bf2df82) | High | User.Read | Sites.FullControl.All |  | Unknown | \n| ✅ | [AppProxyDemoLocalhost](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2425e515-5720-4071-9fae-fd50f153c0aa/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c) | Unranked | User.Read |  |  | 2022-07-13 11:32:12 | \n| ✅ | [BlazorMultiDemo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/77198970-f1eb-4574-9a1a-6af175a283af/appId/2e311a1d-f5c0-41c6-b866-77af3289871e) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-02-06 20:13:55 | \n| ✅ | [Microsoft Assessment React](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0a8b4459-b0c2-4cb8-baeb-c4c5a6a8f14b/appId/c4b110d7-6f1d-473d-aa9e-6e74b8b8bd4b) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-02-25 22:23:01 | \n| ✅ | [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/043dd83b-94ce-4d12-b54b-45d77979f05a/appId/0b75bb7b-d365-4c29-92ea-e2799d2a3fce) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-03-11 07:25:24 | \n| ✅ | [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/30aa6cd2-1aab-42fd-a235-0521713f4532/appId/afe793df-19e0-455a-8403-2e863379bfaa) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-03-11 09:46:07 | \n| ✅ | [My Doc Gen](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a445d652-f72d-4a88-9493-79d3c3c23d1b/appId/e580347d-d0aa-4aa1-9113-5daa0bb1c805) | High | User.Read, openid, profile, offline_access, Directory.Read.All, Policy.Read.All, Agreement.Read.All, CrossTenantInformation.ReadBasic.All |  |  | 2023-03-17 19:02:35 | \n| ✅ | [graph-developer-proxy-samples](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e6570bb8-fdea-4329-82e2-2809d8fb67a7/appId/3658d9e9-dc87-4345-b59b-184febcf6781) | Unranked | User.Read.All, Presence.Read.All |  |  | 2023-04-20 01:53:56 | \n| ✅ | [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/aa64efdb-2d05-4c81-a9e5-80294bf0afac/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) | High | Policy.Read.All, User.Read, Directory.ReadWrite.All, Mail.ReadWrite | Directory.ReadWrite.All, Mail.ReadWrite |  | 2023-04-20 02:28:51 | \n| ✅ | [Canva](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/37ae3acb-5850-49e8-a0f8-cb06f5a77417/appId/2c0bebe0-bdb3-4909-8955-7ef311f0db22) | Unranked | email, openid, profile, User.Read |  |  | 2023-04-27 13:05:18 | \n| ✅ | [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b66231c2-9568-46f1-b61e-c5f8fd9edee4/appId/50827722-4f53-48ba-ae58-db63bb53626b) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  |  | 2023-07-05 19:49:07 | \n| ✅ | [MyTokenTestApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/60923f18-748f-42bb-a0b2-ee60d44e17fc/appId/6a846cb7-35ad-41b2-b10a-0c5decde9855) | Unranked | profile, openid |  |  | 2023-07-05 21:10:54 | \n| ✅ | [Microsoft Graph PowerShell - Used by Team Incredibles](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e67821d9-a20b-43ef-9c34-76a321643b4f/appId/2935f660-810c-41ff-b9ad-168cc649e36f) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-08-15 22:44:19 | \n| ✅ | [MyZt](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/716038b1-2811-40fc-8622-93e093890af0/appId/eee51d92-0bb5-4467-be6a-8f24ef677e4d) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, DeviceManagementServiceConfig.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementApps.Read.All, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, PrivilegedEligibilitySchedule.Read.AzureADGroup, openid, profile, offline_access |  |  | 2023-09-01 21:32:23 | \n| ✅ | [MyZtA\\[\\[](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d2a2a09d-7562-45fc-a950-36fedfb790f8/appId/d159fcf5-a613-435b-8195-8add3cdf4bff) | High | RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, Policy.Read.All, Agreement.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, User.Read, Directory.Read.All, PrivilegedEligibilitySchedule.Read.AzureADGroup, CrossTenantInformation.ReadBasic.All |  |  | 2023-09-05 20:08:37 | \n| ✅ | [idPowerToys - Release](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4654e05d-9f59-4925-807c-8eb2306e1cb1/appId/904e4864-f3c3-4d2f-ace2-c37a4ed55145) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  |  | 2023-10-24 21:05:56 | \n| ✅ | [Azure AD Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6c74be7f-bcc9-4541-bfe1-f113b90b0497/appId/68bc31c0-f891-4f4c-9309-c6104f7be41b) | High | Organization.Read.All, RoleManagement.Read.Directory, Application.Read.All, User.Read.All, Group.Read.All, Policy.Read.All, Directory.Read.All, SecurityEvents.Read.All, UserAuthenticationMethod.Read.All, AuditLog.Read.All, Reports.Read.All, openid, offline_access, profile |  |  | 2023-10-27 14:17:26 | \n| ✅ | [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/666a58ef-c3e5-4efc-828a-2ab3c0120677/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | High | User.Read | Sites.Read.All, Sites.Read.All |  | 2023-11-17 14:58:06 | \n| ✅ | [CachingSampleApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/59187561-8df5-4792-b3a4-f6ca8b54bfc7/appId/3d6835ff-f7f4-4a83-adb5-67ccdd934717) | Unranked | User.Read, openid, profile, offline_access |  |  | 2024-01-23 22:02:00 | \n| ✅ | [EAM Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24b12ae7-4648-4aae-b00c-6349a565d24c/appId/e6e0be31-7040-4084-ac44-600b67661f2c) | Unranked | profile, openid |  |  | 2024-01-30 09:06:19 | \n| ✅ | [elapora-Maester-54d3ea01-5a07-45d0-8d69-e5f5b0b20098](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4faa0456-5ecb-49f3-bb9a-2dbe516e939a/appId/a8c184ae-8ddf-41f3-8881-c090b43c385f) | High |  | Mail.Send, DirectoryRecommendations.Read.All, Reports.Read.All, Directory.Read.All, Policy.Read.All |  | 2024-05-11 10:00:27 | \n| ✅ | [Azure Static Web Apps](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6b1f4a00-db4e-43ae-b62b-2286d4fcc4ea/appId/d414ee2d-73e5-4e5b-bb16-03ef55fea597) | Unranked | openid, profile, email |  |  | 2024-05-27 20:23:23 | \n| ✅ | [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e31cd01e-afaf-4cc3-8d15-d3f9f7eb61e8/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) | High |  | Reports.Read.All, Mail.Send, Directory.Read.All, Policy.Read.All |  | 2024-06-09 10:43:08 | \n| ✅ | [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d54232da-de3b-4874-aef2-5203dbd7342a/appId/d99dd249-6ab3-4e92-be40-81af11658359) | High | User.Read | DirectoryRecommendations.Read.All, PrivilegedAccess.Read.AzureAD, Reports.Read.All, Mail.Send, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All |  | 2024-06-09 11:03:40 | \n| ✅ | [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/89bd9c7a-0c81-4a0a-9153-ff7cd0b81352/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) | High |  | GroupMember.Read.All, User.Read.All |  | 2024-09-10 17:56:46 | \n| ✅ | [FIDO2-passkeys-MFA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1aa7e155-cbf8-4970-8458-05a0c7a2d1a5/appId/4fabcfc0-5c44-45a1-8c80-8537f0625949) | Unranked | profile, openid |  |  | 2024-09-25 11:55:22 | \n| ✅ | [Graph PS - Zero Trust Workshop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f6e8dfdd-4c84-441f-ae6e-f2f51fd20699/appId/a9632ced-c276-4c2b-9288-3a34b755eaa9) | High | AuditLog.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, UserAuthenticationMethod.Read.All, openid, profile, offline_access |  |  | 2024-11-25 19:49:09 | \n| ✅ | [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e9fca357-cccd-4ec4-840f-7482f6f02818/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) | High |  | User.Read.All |  | 2024-12-09 19:51:04 | \n| ✅ | [idpowerelectron](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cb64f850-a076-42d5-8dd8-cfd67d9e67f1/appId/909fff82-5b0a-4ce5-b66d-db58ee1a925d) | Unranked | openid, profile, offline_access |  |  | 2025-02-15 13:57:15 | \n| ✅ | [idPowerToys for Desktop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24cc58d8-2844-4974-b7cd-21c8a470e6bb/appId/520aa3af-bd78-4631-8f87-d48d356940ed) | High | Directory.Read.All, Policy.Read.All, Agreement.Read.All, CrossTenantInformation.ReadBasic.All, openid, profile, offline_access |  |  | 2025-02-16 07:30:08 | \n| ✅ | [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3dde25cc-223f-4a16-8e8f-6695940b9680/appId/e7dfcbb6-fe86-44a2-b512-8d361dcc3d30) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, DeviceManagementServiceConfig.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementApps.Read.All, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, PrivilegedEligibilitySchedule.Read.AzureADGroup, openid, profile, offline_access |  |  | 2025-04-23 01:20:40 | \n| ✅ | [Maester DevOps Account - GitHub](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ce3af345-b0e0-4b15-808c-937d825bcf03/appId/f050a85f-390b-4d43-85a0-2196b706bfd6) | High |  | DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, Mail.Send, Policy.Read.ConditionalAccess, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All |  | 2025-05-06 00:42:50 | \n| ✅ | [entraChatAppMultiTenant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/855a57ff-88a6-4ad0-85d7-4f46d742730e/appId/5e00b345-a805-42a0-9caa-7d6cb761c668) | High | User.Read, openid, profile, offline_access, APIConnectors.Read.All, Application.ReadWrite.All, Policy.ReadWrite.AuthenticationFlows, Policy.Read.All, EventListener.ReadWrite.All, Policy.ReadWrite.AuthenticationMethod, Group.Read.All, AuditLog.Read.All, Policy.ReadWrite.ConditionalAccess, IdentityUserFlow.Read.All, Policy.ReadWrite.TrustFramework, TrustFrameworkKeySet.Read.All, Directory.ReadWrite.All |  |  | 2025-05-08 09:49:16 | \n| ✅ | [Maester DevOps Account - New GitHub Action](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7c1885fd-fdf8-413a-86a6-f8867914272f/appId/143cb1b1-81af-4999-a292-a8c537601119) | High | User.Read | DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, Policy.Read.ConditionalAccess, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All |  | 2025-05-10 11:07:29 | \n| ✅ | [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad36b6e2-273d-4652-a505-8481f096e513/appId/6ce0484b-2ae6-4458-b2b9-b3369f42fd6f) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  |  | 2025-05-30 12:52:18 | \n| ✅ | [Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/552daa69-8057-4684-8c93-2c41963aff01/appId/f864cc86-0f4f-4861-9583-2580817e4f88) | Unranked | openid, profile |  |  | 2025-06-30 21:42:50 | \n| ✅ | [Lokka](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1abc3899-a5df-40ab-8aa7-95d31edd4c01/appId/f581405a-9e57-4e81-91f1-40cd62f7595e) | High |  | PrivilegedAccess.Read.AzureADGroup, IdentityRiskEvent.Read.All, Policy.Read.All, User.Read.All, DirectoryRecommendations.Read.All, Policy.ReadWrite.Authorization, PrivilegedAccess.Read.AzureAD, Reports.Read.All, DeviceManagementConfiguration.ReadWrite.All, Mail.Read, Directory.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, UserAuthenticationMethod.Read.All, Mail.Send |  | 2025-07-05 18:49:16 | \n| ✅ | [Entra.News Automation Script - Message Center](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/158f6ef9-a65d-45f2-bdf0-b0a1db70ebd4/appId/83f76a08-fa60-48e6-9cb5-fd8ced5ae314) | Medium | User.Read | ServiceMessage.Read.All |  | 2025-07-06 17:02:10 | \n| ✅ | [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7c32eaee-ff26-4435-be3d-b4ced08f9edc/appId/303774c1-3c6f-4dfd-8505-f24e82f9212a) | High | User.Read | Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All |  | 2025-07-09 11:15:20 | \n| ✅ | [Maester Automation App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e3972142-1d36-4e7d-a777-ecd64619fcab/appId/55635484-743e-42e2-a78e-6bc15050ebde) | High | User.Read | Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, Mail.Send, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All |  | 2025-07-09 17:43:07 | \n| ✅ | [GitHub Actions App for Microsoft Info script](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/852b4218-67d2-4046-a9a6-f8b47430ccdf/appId/38535360-9f3e-4b1e-a41e-b4af46afcb0c) | High |  | Application.Read.All |  | 2025-07-10 03:43:49 | \n| ✅ | [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a15dc834-08ce-4fd8-85de-3729fff8e34f/appId/d36fe320-bc28-40c8-a141-a512d65d112c) | High | User.Read | Application.Read.All |  | 2025-07-10 03:47:43 | \n| ✅ | [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/427b14ca-13b3-4911-b67e-9ff626614781/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) | Medium |  | ServiceMessage.Read.All |  | 2025-07-10 09:16:04 | \n| ✅ | [AppProxy Header Test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/53c7bdb1-cae2-43b0-9e2e-d8605395ceec/appId/19a70df3-cddf-48c7-be44-97b25b9857f1) | Unranked | User.Read |  |  | Unknown | \n| ✅ | [WebApplication4](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5bc56e47-7a8a-4e71-b25f-8c4e373f40a6/appId/b2d1f868-27ee-4ecd-ae81-0ee96b028605) | Unranked | User.Read |  |  | Unknown | \n| ✅ | [Entry Kiosk](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/83adcc80-3a35-4fdc-9c5b-1f6b9061508e/appId/b903f17a-87b0-460b-9978-962c812e4f98) | Unranked | User.Read |  |  | Unknown | \n| ✅ | [Calendar Pro](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/36e156e4-4566-44a0-b05c-a112017086b5/appId/fb507a6d-2eaa-4f1f-b43a-140f388c4445) | Unranked | profile, offline_access, email, openid, User.Read, User.ReadBasic.All |  |  | Unknown | \n| ✅ | [Contoso Access Verifier](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/41d3b041-9859-4830-8feb-72ffd7afad65/appId/a6af3433-bc44-4d27-9b35-81d10fd51315) | Unranked | openid, profile, User.Read |  |  | Unknown | \n\n\n",
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they’re legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Failed",
      "TestImpact": "High"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Monitoring",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All Microsoft Entra recommendations are addressed",
      "TestRisk": "Medium",
      "TestId": "21866",
      "TestResult": "\nFound 9 unaddressed Entra recommendations.\n\n\n## Unaddressed Entra recommendations\n\n| Display Name | Status | Insights | Priority |\n| :--- | :--- | :--- | :--- |\n| Protect your tenant with Insider Risk condition in Conditional Access policy | active | You have 61 of 61 users that aren’t covered by the Insider Risk condition in a Conditional Access policy. | medium |\n| Protect all users with a user risk policy  | active | You have 2 of 61 users that don’t have a user risk policy enabled.  | high |\n| Protect all users with a sign-in risk policy | active | You have 61 of 61 users that don't have a sign-in risk policy turned on. | high |\n| Enable password hash sync if hybrid | active | You have disabled password hash sync. | medium |\n| Ensure all users can complete multifactor authentication | active | You have 46 of 61 users that aren’t registered with MFA.  | high |\n| Enable policy to block legacy authentication | active | You have 2 of 61 users that don’t have legacy authentication blocked.  | high |\n| Require multifactor authentication for administrative roles | active | You have 5 of 11 users with administrative roles that aren’t registered and protected with MFA. | high |\n| Remove unused credentials from applications | active | Your tenant has applications with credentials which have not been used in more than 30 days. | medium |\n| Remove unused applications | active | This recommendation will surface if your tenant has applications that have not been used for over 90 days. Applications that were created but never used, client applications which have not been issued a token or resource apps that have not been a target of a token request, will show under this recommendation. | medium |\n\n\n",
      "TestDescription": "Microsoft Entra recommendations give organizations opportunities to implement best practices and optimize their security posture. Not acting on these items might result in an increased attack surface area, suboptimal operations, or poor user experience.\n\n**Remediation action**\n\n- [Address all active or postponed recommendations in the Microsoft Entra admin center](https://learn.microsoft.com/entra/identity/monitoring-health/overview-recommendations?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-does-it-work)\n",
      "TestStatus": "Failed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Application"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Creating new applications and service principles is restricted to privileged users",
      "TestRisk": "Medium",
      "TestId": "21807",
      "TestResult": "\nTenant is configured to prevent users from registering applications.\n\n**[Users can register applications](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)** → **No** ✅\n\n",
      "TestDescription": "If nonprivileged users can create applications and service principals, these accounts might be misconfigured or be granted more permissions than necessary, creating new vectors for attackers to gain initial access. Attackers can exploit these accounts to establish valid credentials in the environment and bypass some security controls.\n\nIf these nonprivileged accounts are mistakenly granted elevated application owner permissions, attackers can use them to move from a lower level of access to a more privileged level of access. Attackers who compromise nonprivileged accounts might add their own credentials or change the permissions associated with the applications created by the nonprivileged users to ensure they can continue to access the environment undetected.\n\nAttackers can use service principals to blend in with legitimate system processes and activities. Because service principals often perform automated tasks, malicious activities carried out under these accounts might not be flagged as suspicious.\n\n**Remediation action**\n\n- [Block nonprivileged users from creating apps](https://learn.microsoft.com/entra/identity/role-based-access-control/delegate-app-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Passed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "ExternalCollaboration"
      ],
      "TestSkipped": "",
      "TestCategory": "External collaboration",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Guests can’t invite other guests",
      "TestRisk": "Medium",
      "TestId": "21791",
      "TestResult": "\nTenant restricts who can invite guests.\n\n**Guest invite settings**\n\n  * Guest invite restrictions → Member users and users assigned to specific admin roles can invite guest users including guests with member permissions\n\n",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.  \n\nAllowing external users to onboard other external users increases the risk of unauthorized access. If an attacker compromises an external user's account, they can use it to create more external accounts, multiplying their access points and making it harder to detect the intrusion.\n\n**Remediation action**\n\n- [Restrict who can invite guests to only users assigned to specific admin roles](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-invite-settings)\n",
      "TestStatus": "Passed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Application"
      ],
      "TestSkipped": "",
      "TestCategory": "External collaboration",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Guests have restricted access to directory objects",
      "TestRisk": "Medium",
      "TestId": "21792",
      "TestResult": "\n✅ Validated guest user access is restricted.\n\n",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.  \n\nExternal accounts with permissions to read directory object permissions provide attackers with broader initial access if compromised. These accounts allow attackers to gather additional information from the directory for reconnaissance.\n\n**Remediation action**\n\n- [Restrict guest access to their own directory objects](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-user-access)\n",
      "TestStatus": "Passed",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Access control",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Authenticator app shows sign-in context",
      "TestRisk": "Medium",
      "TestId": "21802",
      "TestResult": "\nMicrosoft Authenticator shows application name and geographic location in push notifications.\n\n\n## Microsoft Authenticator settings\n\n\nFeature Settings:\n\n✅ **Application Name**\n- Status: Enabled\n- Include Target: All users\n- Exclude Target: No exclusions\n\n✅ **Geographic Location**\n- Status: Enabled\n- Include Target: All users\n- Exclude Target: No exclusions\n\n\n",
      "TestDescription": "Without sign-in context, threat actors can exploit authentication fatigue by flooding users with push notifications, increasing the chance that a user accidentally approves a malicious request. When users get generic push notifications without the application name or geographic location, they don't have the information they need to make informed approval decisions. This lack of context makes users vulnerable to social engineering attacks, especially when threat actors time their requests during periods of legitimate user activity. This vulnerability is especially dangerous when threat actors gain initial access through credential harvesting or password spraying attacks and then try to establish persistence by approving multifactor authentication (MFA) requests from unexpected applications or locations. Without contextual information, users can't detect unusual sign-in attempts, allowing threat actors to maintain access and escalate privileges by moving laterally through systems after bypassing the initial authentication barrier. Without application and location context, security teams also lose valuable telemetry for detecting suspicious authentication patterns that can indicate ongoing compromise or reconnaissance activities.   \n\n**Remediation action**\nGive users the context they need to make informed approval decisions. Configure Microsoft Authenticator notifications by setting the Authentication methods policy to include the application name and geographic location.  \n- [Use additional context in Authenticator notifications - Authentication methods policy](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-additional-context?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Passed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "",
      "TestCategory": "Application management",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Named locations are configured",
      "TestRisk": "Medium",
      "TestId": "21865",
      "TestResult": "\n✅ **Pass**: Trusted named locations are configured in Microsoft Entra ID to support location-based security controls.\n\n\n## All named locations\n\n5 [named locations](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations/menuId//fromNav/) found.\n\n| Name | Location type | Trusted | Creation date | Modified date |\n| :--- | :------------ | :------ | :------------ | :------------ |\n| Melbourne Branch | IP-based | Yes | Unknown | Unknown |\n| Boston Head Office | IP-based | Yes | Unknown | Unknown |\n| Untrusted Locations | Country-based | No | Unknown | Unknown |\n| Corporate IPs | IP-based | Yes | Unknown | Unknown |\n| Merill home | IP-based | Yes | 04/16/2025 04:55:11 | 04/16/2025 04:55:11 |\n\n\n\n",
      "TestDescription": "Without named locations configured in Microsoft Entra ID, threat actors can exploit the absence of location intelligence to conduct attacks without triggering location-based risk detections or security controls. When organizations fail to define named locations for trusted networks, branch offices, and known geographic regions, Microsoft Entra ID Protection can't assess location-based risk signals. Not having these policies in place can lead to increased false positives that create alert fatigue and potentially mask genuine threats. This configuration gap prevents the system from distinguishing between legitimate and illegitimate locations. For example, legitimate sign-ins from corporate networks and suspicious authentication attempts from high-risk locations (anonymous proxy networks, Tor exit nodes, or regions where the organization has no business presence). Threat actors can use this uncertainty to conduct credential stuffing attacks, password spray campaigns, and initial access attempts from malicious infrastructure without triggering location-based detections that would normally flag such activity as suspicious. Organizations can also lose the ability to implement adaptive security policies that could automatically apply stricter authentication requirements or block access entirely from untrusted geographic regions. Threat actors can maintain persistence and conduct lateral movement from any global location without encountering location-based security barriers, which should serve as an extra layer of defense against unauthorized access attempts.\n\n**Remediation action**\n\n- [Configure named locations to define trusted IP ranges and geographic regions for enhanced location-based risk detection and Conditional Access policy enforcement](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestStatus": "Passed",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All user sign in activity uses phishing-resistant authentication methods",
      "TestRisk": "Medium",
      "TestId": "21784",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All groups in Conditional Access policies belong to a restricted management administrative unit",
      "TestRisk": "Medium",
      "TestId": "21832",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All sign-in activity comes from managed devices",
      "TestRisk": "Medium",
      "TestId": "21892",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "High"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Guest access is limited to approved tenants",
      "TestRisk": "Medium",
      "TestId": "21822",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Application management",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Use recent versions of Microsoft Applications",
      "TestRisk": "Medium",
      "TestId": "21779",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All entitlement management packages that apply to guests have expirations or access reviews configured in their assignment policies",
      "TestRisk": "Medium",
      "TestId": "21929",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Turn off Seamless SSO if there are is no usage",
      "TestRisk": "Medium",
      "TestId": "21985",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All privileged role assignments have a recipient that can receive notifications",
      "TestRisk": "Medium",
      "TestId": "21899",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "No nested groups in PIM for groups",
      "TestRisk": "Medium",
      "TestId": "21882",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All entitlement management policies that apply to External users require approval",
      "TestRisk": "Medium",
      "TestId": "21879",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Guest self-service sign up via user flow is disabled",
      "TestRisk": "Medium",
      "TestId": "21823",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Application management",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Workload identities assigned privileged roles",
      "TestRisk": "Medium",
      "TestId": "21836",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All entitlement management policies have an expiration date",
      "TestRisk": "Medium",
      "TestId": "21878",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Guest identities are lifecycle managed with access reviews",
      "TestRisk": "Medium",
      "TestId": "21857",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Applications that use Microsoft Entra for authentication and support provisioning are configured",
      "TestRisk": "Medium",
      "TestId": "21886",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All registered redirect URIs must have proper DNS records and ownerships",
      "TestRisk": "Medium",
      "TestId": "21887",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Smart lockout duration is set to a minimum of 60",
      "TestRisk": "Medium",
      "TestId": "21849",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Password expiration is disabled",
      "TestRisk": "Medium",
      "TestId": "21811",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Self-Service Password Reset does not use Q & A",
      "TestRisk": "Medium",
      "TestId": "22072",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Password protection for on-premises is enabled",
      "TestRisk": "Medium",
      "TestId": "21847",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Guests don't own apps in the tenant",
      "TestRisk": "Medium",
      "TestId": "21868",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Service principals don't have certificates or credentials associated with them",
      "TestRisk": "Medium",
      "TestId": "21896",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "No Active Medium priority Entra recommendations found",
      "TestRisk": "Medium",
      "TestId": "21983",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "User consent settings are restricted",
      "TestRisk": "Medium",
      "TestId": "21776",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Enterprise applications must require explicit assignment or scoped provisioning",
      "TestRisk": "Medium",
      "TestId": "21869",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Privileged user sessions don't have long lived sign-in sessions",
      "TestRisk": "Medium",
      "TestId": "21825",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "GDAP admin least privilege",
      "TestRisk": "Medium",
      "TestId": "21859",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Conditional Access protected actions are enabled",
      "TestRisk": "Medium",
      "TestId": "21831",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Guest access is restricted",
      "TestRisk": "Medium",
      "TestId": "21821",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Smart lockout threshold isn't greater than 10",
      "TestRisk": "Medium",
      "TestId": "21850",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Workload identities based on known networks are configured",
      "TestRisk": "Medium",
      "TestId": "21884",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Token protection policies are configured",
      "TestRisk": "Medium",
      "TestId": "21941",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Tenant has all External organizations allowed to collaborate as Connected Organization",
      "TestRisk": "Medium",
      "TestId": "21875",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Application management",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Line-of-business and partner apps use MSAL",
      "TestRisk": "Medium",
      "TestId": "21778",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Monitoring",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All user sign-in activity uses strong authentication methods",
      "TestRisk": "Medium",
      "TestId": "21800",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestDescription": "Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.\n\nAttackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.\n\n**Remediation action**\n\n- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policies to enforce authentication strength](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Privileged roles have access reviews",
      "TestRisk": "Medium",
      "TestId": "21855",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Tenant does have controls to selectively onboard External organizations (cross-tenant access polices and domain-based allow/deny lists)",
      "TestRisk": "Medium",
      "TestId": "21874",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Privileged roles aren't assigned to stale identities",
      "TestRisk": "Medium",
      "TestId": "21854",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Monitoring",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Tenant creation events are triaged",
      "TestRisk": "Medium",
      "TestId": "21789",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All supported access lifecycle resources are managed with entitlement management packages",
      "TestRisk": "Medium",
      "TestId": "21898",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Use PIM for Microsoft Entra privileged roles",
      "TestRisk": "Medium",
      "TestId": "21876",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Application"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": null,
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Guest access is protected by strong authentication methods",
      "TestRisk": "Medium",
      "TestId": "21851",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your organization. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.\n\nAttackers might gain access with external user accounts, if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. They might also gain access by exploiting the vulnerabilities of weaker MFA methods like SMS and phone calls using social engineering techniques, such as SIM swapping or phishing, to intercept the authentication codes.\n\nOnce an attacker gains access to an account without MFA or a session with weak MFA methods, they might attempt to manipulate MFA settings (for example, registering attacker controlled methods) to establish persistence to plan and execute further attacks based on the privileges of the compromised accounts.\n\n**Remediation action**\n\n- [Deploy Conditional Access policies to enforce authentication strength for guests](https://learn.microsoft.com/entra/identity/conditional-access/policy-guests-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- For organizations with a closer business relationship and vetting on their MFA practices, consider deploying cross-tenant access settings to accept the MFA claim.\n   - [Configure B2B collaboration cross-tenant access settings](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-change-inbound-trust-settings-for-mfa-and-device-claims)\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Monitoring",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "No legacy authentication sign-in activity",
      "TestRisk": "Medium",
      "TestId": "21795",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestDescription": "Legacy authentication protocols such as basic authentication for SMTP and IMAP don't support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This lack of protection makes accounts using these protocols vulnerable to password-based attacks, and provides attackers with a means to gain initial access using stolen or guessed credentials.\n\nWhen an attacker successfully gains unauthorized access to credentials, they can use them to access linked services, using the weak authentication method as an entry point. Attackers who gain access through legacy authentication might make changes to Microsoft Exchange, such as configuring mail forwarding rules or changing other settings, allowing them to maintain continued access to sensitive communications.\n\nLegacy authentication also provides attackers with a consistent method to reenter a system using compromised credentials without triggering security alerts or requiring reauthentication.\n\nFrom there, attackers can use legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement. Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.\n\n**Remediation action**\n\n- [Exchange protocols can be deactivated in Exchange](https://learn.microsoft.com/exchange/clients-and-mobile-in-exchange-online/disable-basic-authentication-in-exchange-online?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Legacy authentication protocols can be blocked with Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Sign-ins using legacy authentication workbook to help determine whether it's safe to turn off legacy authentication](https://learn.microsoft.com/entra/identity/monitoring-health/workbook-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestStatus": "Planned",
      "TestImpact": "High"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Guests don't have long lived sign-in sessions",
      "TestRisk": "Medium",
      "TestId": "21824",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Require password reset notifications for user roles",
      "TestRisk": "Medium",
      "TestId": "21890",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Medium"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Application management",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "No usage of ADAL in the tenant",
      "TestRisk": "Medium",
      "TestId": "21780",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Inactive guest identities are removed from the tenant",
      "TestRisk": "Medium",
      "TestId": "21858",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All app assignment and group membership is governed",
      "TestRisk": "Medium",
      "TestId": "21897",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "High"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All guests have a sponsor",
      "TestRisk": "Medium",
      "TestId": "21877",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "High"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Privileged access",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "Activation alert for Global Administrator role assignments",
      "TestRisk": "Medium",
      "TestId": "21819",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    },
    {
      "TestTags": [
        "Identity"
      ],
      "TestSkipped": "UnderConstruction",
      "TestCategory": "Access control",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestTitle": "All risky workload identities are triaged",
      "TestRisk": "Medium",
      "TestId": "21862",
      "TestResult": "\nPlanned for future release.\n",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestStatus": "Planned",
      "TestImpact": "Low"
    }
  ],
  "TenantInfo": {
    "OverviewCaDevicesAllUsers": {
      "nodes": [
        {
          "source": "User sign in",
          "target": "Unmanaged",
          "value": 316
        },
        {
          "source": "User sign in",
          "target": "Managed",
          "value": 0
        },
        {
          "source": "Managed",
          "target": "Non-compliant",
          "value": 0
        },
        {
          "source": "Managed",
          "target": "Compliant",
          "value": 0
        }
      ],
      "description": "Over the past 30 days, 0% of sign-ins were from compliant devices."
    },
    "OverviewAuthMethodsAllUsers": {
      "nodes": [
        {
          "source": "Users",
          "target": "Single factor",
          "value": 43
        },
        {
          "source": "Users",
          "target": "Phishable",
          "value": 23
        },
        {
          "source": "Phishable",
          "target": "Phone",
          "value": 7
        },
        {
          "source": "Phishable",
          "target": "Authenticator",
          "value": 16
        },
        {
          "source": "Users",
          "target": "Phish resistant",
          "value": 6
        },
        {
          "source": "Phish resistant",
          "target": "Passkey",
          "value": 4
        },
        {
          "source": "Phish resistant",
          "target": "WHfB",
          "value": 2
        }
      ],
      "description": "Strongest authentication method registered by all users."
    },
    "OverviewCaMfaAllUsers": {
      "nodes": [
        {
          "source": "User sign in",
          "target": "No CA applied",
          "value": 162
        },
        {
          "source": "User sign in",
          "target": "CA applied",
          "value": 154
        },
        {
          "source": "CA applied",
          "target": "No MFA",
          "value": 0
        },
        {
          "source": "CA applied",
          "target": "MFA",
          "value": 154
        }
      ],
      "description": "Over the past 30 days, 48.7% of sign-ins were protected by conditional access policies enforcing multifactor."
    },
    "OverviewAuthMethodsPrivilegedUsers": {
      "nodes": [
        {
          "source": "Users",
          "target": "Single factor",
          "value": 4
        },
        {
          "source": "Users",
          "target": "Phishable",
          "value": 10
        },
        {
          "source": "Phishable",
          "target": "Phone",
          "value": 2
        },
        {
          "source": "Phishable",
          "target": "Authenticator",
          "value": 8
        },
        {
          "source": "Users",
          "target": "Phish resistant",
          "value": 5
        },
        {
          "source": "Phish resistant",
          "target": "Passkey",
          "value": 3
        },
        {
          "source": "Phish resistant",
          "target": "WHfB",
          "value": 2
        }
      ],
      "description": "Strongest authentication method registered by privileged users."
    }
  },
  "EndOfJson": "EndOfJson"
}
