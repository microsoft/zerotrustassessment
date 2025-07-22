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
  TestSfiPillar: string | null;
  SkippedReason: string | null;
  TestResult: string;
  TestSkipped: string;
  TestStatus: string;
  TestTags: string[];
  TestId: string;
  TestDescription: string;
}

export const reportData: ZeroTrustAssessmentReport = {
  "ExecutedAt": "2025-07-22T13:25:36.251257+10:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora Inc.",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "0.9.0",
  "LatestVersion": "0.9.0",
  "TestResultSummary": {
    "IdentityPassed": 17,
    "IdentityTotal": 47,
    "DevicesPassed": 0,
    "DevicesTotal": 0,
    "DataPassed": 0,
    "DataTotal": 0
  },
  "Tests": [
    {
      "SkippedReason": null,
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "The activity logs and reports in Microsoft Entra can help detect unauthorized access attempts or identify when tenant configuration changes. When logs are archived or integrated with Security Information and Event Management (SIEM) tools, security teams can implement powerful monitoring and detection security controls, proactive threat hunting, and incident response processes. The logs and monitoring features can be used to assess tenant health and provide evidence for compliance and audits.\n\nIf logs aren't regularly archived or sent to a SIEM tool for querying, it's challenging to investigate sign-in issues. The absence of historical logs means that security teams might miss patterns of failed sign-in attempts, unusual activity, and other indicators of compromise. This lack of visibility can prevent the timely detection of breaches, allowing attackers to maintain undetected access for extended periods.\n\n**Remediation action**\n\n- [Configure Microsoft Entra diagnostic settings](https://learn.microsoft.com/entra/identity/monitoring-health/howto-configure-diagnostic-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Integrate Microsoft Entra logs with Azure Monitor logs](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Stream Microsoft Entra logs to an event hub](https://learn.microsoft.com/entra/identity/monitoring-health/howto-stream-logs-to-event-hub?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21860",
      "TestCategory": "Monitoring",
      "TestTitle": "Diagnostic settings are configured for all Microsoft Entra logs",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Low",
      "TestResult": "\nSome Entra Logs are not configured with Diagnostic settings.\n\n## Log archiving\n\nLog | Archiving enabled |\n| :--- | :---: |\n|ADFSSignInLogs | ❌ |\n|AuditLogs | ❌ |\n|EnrichedOffice365AuditLogs | ❌ |\n|ManagedIdentitySignInLogs | ❌ |\n|MicrosoftGraphActivityLogs | ❌ |\n|NetworkAccessTrafficLogs | ❌ |\n|NonInteractiveUserSignInLogs | ❌ |\n|ProvisioningLogs | ❌ |\n|RemoteNetworkHealthLogs | ❌ |\n|RiskyServicePrincipals | ❌ |\n|RiskyUsers | ❌ |\n|ServicePrincipalRiskEvents | ❌ |\n|ServicePrincipalSignInLogs | ❌ |\n|SignInLogs | ❌ |\n|UserRiskEvents | ❌ |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "If privileged role activations aren't restricted to dedicated Privileged Access Workstations (PAWs), threat actors can exploit compromised endpoint devices to perform privileged escalation attacks from unmanaged or noncompliant workstations. Standard productivity workstations often contain attack vectors such as unrestricted web browsing, email clients vulnerable to phishing, and locally installed applications with potential vulnerabilities. When administrators activated privileged roles from these workstations, threat actors who gain initial access through malware, browser exploits, or social engineering can then use the locally cached privileged credentials or hijack existing authenticated sessions to escalate their privileges. Privileged role activations grant extensive administrative rights across Microsoft Entra ID and connected services, so attackers can create new administrative accounts, modify security policies, access sensitive data across all organizational resources, and deploy malware or backdoors throughout the environment to establish persistent access. This lateral movement from a compromised endpoint to privileged cloud resources represents a critical attack path that bypasses many traditional security controls. The privileged access appears legitimate when originating from an authenticated administrator's session.\n\nIf this check passes, your tenant has a Conditional Access policy that restricts privileged role access to PAW devices, but it isn't the only control required to fully enable a PAW solution. You also need to configure an Intune device configuration and compliance policy and a device filter.\n\n**Remediation action**\n\n- [Deploy a privileged access workstation solution](https://learn.microsoft.com/security/privileged-access-workstations/privileged-access-deployment?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - Provides guidance for configuring the Conditional Access and Intune device configuration and compliance policies.\n- [Configure device filters in Conditional Access to restrict privileged access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-condition-filters-for-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "High",
      "TestId": "21830",
      "TestCategory": "Application management",
      "TestTitle": "Conditional Access policies for Privileged Access Workstations are configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nNo Conditional Access policies found that restrict privileged roles to PAW device.\n\n**❌ Found 0 policy(s) with compliant device control targeting all privileged roles**\n\n\n**❌ Found 0 policy(s) with PAW/SAW device filter targeting all privileged roles**\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "When weak authentication methods like SMS and voice calls remain enabled in Microsoft Entra ID, threat actors can exploit these vulnerabilities through multiple attack vectors. Initially, attackers often conduct reconnaissance to identify organizations using these weaker authentication methods through social engineering or technical scanning. Then they can execute initial access through credential stuffing attacks, password spraying, or phishing campaigns targeting user credentials.\n\nOnce basic credentials are compromised, threat actors use these weaknesses in SMS and voice-based authentication. SMS messages can be intercepted through SIM swapping attacks, SS7 network vulnerabilities, or malware on mobile devices, while voice calls are susceptible to voice phishing (vishing) and call forwarding manipulation. With these weak second factors bypassed, attackers achieve persistence by registering their own authentication methods. Compromised accounts can be used to target higher-privileged users through internal phishing or social engineering, allowing attackers to escalate privileges within the organization. Finally, threat actors achieve their objectives through data exfiltration, lateral movement to critical systems, or deployment of other malicious tools, all while maintaining stealth by using legitimate authentication pathways that appear normal in security logs. \n\n**Remediation action**\n\n- [Deploy authentication method registration campaigns to encourage stronger methods](https://learn.microsoft.com/graph/api/authenticationmethodspolicy-update?view=graph-rest-beta&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Disable authentication methods](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Disable phone-based methods in legacy MFA settings](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-mfa-mfasettings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policies using authentication strength](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strength-how-it-works?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21804",
      "TestCategory": "Credential management",
      "TestTitle": "SMS and Voice Call authentication methods are disabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nFound weak authentication methods that are still enabled.\n\n## Weak authentication methods\n| Method ID | Is method weak? | State |\n| :-------- | :-------------- | :---- |\n| Sms | Yes | enabled |\n| Voice | Yes | disabled |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "App instance property lock prevents changes to sensitive properties of a multitenant application after the application is provisioned in another tenant. Without a lock, critical properties such as application credentials can be maliciously or unintentionally modified, causing disruptions, increased risk, unauthorized access, or privilege escalations.\n\n**Remediation action**\nEnable the app instance property lock for all multitenant applications and specify the properties to lock.\n- [Configure an app instance lock](https://learn.microsoft.com/en-us/entra/identity-platform/howto-configure-app-instance-property-locks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-an-app-instance-lock)   \n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21777",
      "TestCategory": "Access control",
      "TestTitle": "App instance property lock is configured for all multitenant applications",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nFound multi-tenant apps without app instance property lock configured.\n\n\n## Multi-tenant applications and their App Instance Property Lock setting\n\n\n| Application | Application ID | App Instance Property Lock configured |\n| :---------- | :------------- | :------------------------------------ |\n| [AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/2e311a1d-f5c0-41c6-b866-77af3289871e/isMSAApp~/false) | 2e311a1d-f5c0-41c6-b866-77af3289871e | False |\n| [Adatum Demo App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/d2934d2a-3fbc-44a1-bda0-13e8d8a73b15/isMSAApp~/false) | d2934d2a-3fbc-44a1-bda0-13e8d8a73b15 | False |\n| [EAM Provider](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/f8642471-b7d7-4432-9527-776071e69b8b/isMSAApp~/false) | f8642471-b7d7-4432-9527-776071e69b8b | True |\n| [ExtProperties](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/61a54643-d4b6-471d-bd7c-a55586155dfc/isMSAApp~/false) | 61a54643-d4b6-471d-bd7c-a55586155dfc | False |\n| [Graph Filter](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975/isMSAApp~/false) | c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975 | False |\n| [My Properties Bag](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/303b4699-5b62-451c-b951-7e10b01d9b6d/isMSAApp~/false) | 303b4699-5b62-451c-b951-7e10b01d9b6d | False |\n| [Tenant Extension Properties App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/7db77c2b-30c1-4379-838f-8767c1e0d619/isMSAApp~/false) | 7db77c2b-30c1-4379-838f-8767c1e0d619 | False |\n| [Tenant Extension Properties App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/271b9db4-6e96-430c-808f-973a776adeaf/isMSAApp~/false) | 271b9db4-6e96-430c-808f-973a776adeaf | False |\n| [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/e7dfcbb6-fe86-44a2-b512-8d361dcc3d30/isMSAApp~/false) | e7dfcbb6-fe86-44a2-b512-8d361dcc3d30 | True |\n| [graph-developer-proxy-samples](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/3658d9e9-dc87-4345-b59b-184febcf6781/isMSAApp~/false) | 3658d9e9-dc87-4345-b59b-184febcf6781 | False |\n| [idpowerelectron](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/909fff82-5b0a-4ce5-b66d-db58ee1a925d/isMSAApp~/false) | 909fff82-5b0a-4ce5-b66d-db58ee1a925d | True |\n| [test-mta](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/5ebc726d-e583-4822-b111-95ee05503c7e/isMSAApp~/false) | 5ebc726d-e583-4822-b111-95ee05503c7e | True |\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21783",
      "TestCategory": "Access control",
      "TestTitle": "Privileged Microsoft Entra built-in roles are targeted with Conditional Access policies to enforce phishing-resistant methods",
      "TestTags": [
        "AccessControl",
        "Authentication"
      ],
      "TestImpact": "Low",
      "TestResult": "\nFound Roles don’t have policies to enforce phishing resistant Credentials\n\n\n\n## Conditional Access Policies with phishing resistant authentication policies \n\nFound 4 phishing resistant conditional access policies.\n\n  - [AuthContext: Require FIDO2 ](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/854ff675-1eef-448d-8382-533788fae7e5) (Disabled)\n  - [MFA CA Policy](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/e589544c-0c92-432e-86ae-4e4ef103eac8)\n  - [Guest-Meferna-Woodgrove-PhishingResistantAuthStrength](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/0f0a0c1c-41b0-4c18-ae20-d02492d03737)\n  - [NewphishingCA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/3fe49849-5ab6-4717-a22d-aa42536eb560) (Disabled)\n\n\n## Privileged Roles\n\nFound 2 of 29 privileged roles protected by phishing resistant authentication.\n\n| Role Name | Phishing resistance enforced |\n| :--- | :---: |\n| Hybrid Identity Administrator | ✅ |\n| Security Administrator | ✅ |\n| Application Administrator | ❌ |\n| Application Developer | ❌ |\n| Attribute Provisioning Administrator | ❌ |\n| Attribute Provisioning Reader | ❌ |\n| Authentication Administrator | ❌ |\n| Authentication Extensibility Administrator | ❌ |\n| B2C IEF Keyset Administrator | ❌ |\n| Cloud Application Administrator | ❌ |\n| Cloud Device Administrator | ❌ |\n| Conditional Access Administrator | ❌ |\n| Directory Writers | ❌ |\n| Domain Name Administrator | ❌ |\n| ExamStudyTest | ❌ |\n| External Identity Provider Administrator | ❌ |\n| Global Administrator | ❌ |\n| Global Reader | ❌ |\n| Helpdesk Administrator | ❌ |\n| Intune Administrator | ❌ |\n| Lifecycle Workflows Administrator | ❌ |\n| Partner Tier1 Support | ❌ |\n| Partner Tier2 Support | ❌ |\n| Password Administrator | ❌ |\n| Privileged Authentication Administrator | ❌ |\n| Privileged Role Administrator | ❌ |\n| Security Operator | ❌ |\n| Security Reader | ❌ |\n| User Administrator | ❌ |\n## Authentication Strength Policies\n\nFound 2 custom phishing resistant authentication strength policies.\n\n  - [ACSC Maturity Level 3](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n  - [Phishing-resistant MFA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "A threat actor or a well-intentioned but uninformed employee can create a new Microsoft Entra tenant if there are no restrictions in place. By default, the user who creates a tenant is automatically assigned the Global Administrator role. Without proper controls, this action fractures the identity perimeter by creating a tenant outside the organization's governance and visibility. It introduces risk though a shadow identity platform that can be exploited for token issuance, brand impersonation, consent phishing, or persistent staging infrastructure. Since the rogue tenant might not be tethered to the enterprise’s administrative or monitoring planes, traditional defenses are blind to its creation, activity, and potential misuse.\n\n**Remediation action**\n\nEnable the **Restrict non-admin users from creating tenants** setting. For users that need the ability to create tenants, assign them the Tenant Creator role. You can also review tenant creation events in the Microsoft Entra audit logs.\n\n- [Restrict member users' default permissions](https://learn.microsoft.com/entra/fundamentals/users-default-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#restrict-member-users-default-permissions)\n- [Assign the Tenant Creator role](https://learn.microsoft.com/entra/identity/role-based-access-control/permissions-reference?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#tenant-creator)\n- [Review tenant creation events](https://learn.microsoft.com/entra/identity/monitoring-health/reference-audit-activities?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#core-directory). Look for OperationName==\"Create Company\", Category == \"DirectoryManagement\".\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21787",
      "TestCategory": "Privileged access",
      "TestTitle": "Permissions to create new tenants are limited to the Tenant Creator role",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nNon-privileged users are allowed to create tenants.\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Accelerate response and remediation",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "When high-risk sign-ins are not properly restricted through Conditional Access policies, organizations expose themselves to security vulnerabilities. Threat actors can exploit these gaps for initial access through compromised credentials, credential stuffing attacks, or anomalous sign-in patterns that Microsoft Entra ID Protection identifies as risky behaviors. Without appropriate restrictions, threat actors who successfully authenticate during high-risk scenarios can perform privilege escalation by misusing the authenticated session to access sensitive resources, modify security configurations, or conduct reconnaissance activities within the environment. Once threat actors establish access through uncontrolled high-risk sign-ins, they can achieve persistence by creating additional accounts, installing backdoors, or modifying authentication policies to maintain long-term access to the organization's resources. The unrestricted access enables threat actors to conduct lateral movement across systems and applications using the authenticated session, potentially accessing sensitive data stores, administrative interfaces, or critical business applications. Finally, threat actors achieve impact through data exfiltration, or compromise business-critical systems while maintaining plausible deniability by exploiting the fact that their risky authentication was not properly challenged or blocked.\n\n**Remediation action**\n- [Implement a Conditional Access policy to require MFA for elevated sign-in risk](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-risk-based-sign-in?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21799",
      "TestCategory": "Access control",
      "TestTitle": "Restrict high risk sign-ins",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nSome high-risk sign-in attempts are not adequately mitigated by Conditional Access policies.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Applications that use client secrets might store them in configuration files, hardcode them in scripts, or risk their exposure in other ways. The complexities of secret management make client secrets susceptible to leaks and attractive to attackers. Client secrets, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's client secret, they can escalate their privileges within the system, leading to broader access and control, depending on the permissions of the application.\n\nApplications and service principals that have permissions for Microsoft Graph APIs or other APIs have a higher risk because an attacker can potentially exploit these additional permissions.\n\n**Remediation action**\n\n- [Move applications away from shared secrets to managed identities and adopt more secure practices](https://learn.microsoft.com/entra/identity/enterprise-apps/migrate-applications-from-secrets?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n   - Use managed identities for Azure resources\n   - Deploy Conditional Access policies for workload identities\n   - Implement secret scanning\n   - Deploy application authentication policies to enforce secure authentication practices\n   - Create a least-privileged custom role to rotate application credentials\n   - Ensure you have a process to triage and monitor applications\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21772",
      "TestCategory": "Application management",
      "TestTitle": "Applications don't have client secrets configured",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Low",
      "TestResult": "\nFound 29 applications and 12 service principals with client secrets configured.\n\n\n## Applications with client secrets\n\n| Application | Secret expiry |\n| :--- | :--- |\n| [AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2e311a1d-f5c0-41c6-b866-77af3289871e) | 2024-11-02 |\n| [Atlassian - Jira](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c) | 2026-02-17 |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2325-01-01 |\n| [Entry Kiosk](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b903f17a-87b0-460b-9978-962c812e4f98) | 2021-11-25 |\n| [Graph Filter](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975) | 2024-09-16 |\n| [Graph PowerShell - Privileged Perms](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/c5338ce0-3e9e-4895-8f49-5e176836a348) | 2024-05-15 |\n| [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d36fe320-bc28-40c8-a141-a512d65d112c) | 2026-02-09 |\n| [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/fef811e1-2354-43b0-961b-248fe15e737d) | 2022-02-11 |\n| [Lokka](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/f581405a-9e57-4e81-91f1-40cd62f7595e) | 2026-01-10 |\n| [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | 2022-03-29 |\n| [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) | 2024-09-23 |\n| [Message Center](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/83f76a08-fa60-48e6-9cb5-fd8ced5ae314) | 2026-02-17 |\n| [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) | 2124-02-21 |\n| [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) | 2025-06-07 |\n| [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | 2022-03-29 |\n| [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) | 2023-10-16 |\n| [RemixTest](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d4588485-154e-4b32-935f-31ceaf993cdc) | 2024-06-24 |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | 2022-08-19 |\n| [SharePoint On-Prem App Proxy](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/19a70df3-cddf-48c7-be44-97b25b9857f1) | 2025-12-12 |\n| [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | 2024-05-15 |\n| [Trello](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d77611ee-5051-4383-9af3-5ba3627306a7) | 2022-08-16 |\n| [WebApplication3](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/bcdb1ed5-9470-41e6-821b-1fc42ae94cfb) | 2022-02-11 |\n| [WebApplication3_20210211261232](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/ac49e193-bd5f-40fe-b4ff-e62136419388) | 2022-02-11 |\n| [WebApplication4](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b2d1f868-27ee-4ecd-ae81-0ee96b028605) | 2022-03-04 |\n| [WingtipToys App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/56a89db1-6ed2-4171-88f6-b4f7597dbce3) | 2025-11-27 |\n| [aadgraphmggraph](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/24b66505-1142-452f-9472-2ecbb37deac1) | 2022-11-26 |\n| [entra-docs-email github DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/ae06b71a-a0aa-4211-b846-fd74f25ccd45) | 2027-07-14 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/4f50c653-dae4-44e7-ae2e-a081cce1f830) | 2023-02-25 |\n| [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) | 2025-03-09 |\n\n\n## Service Principals with client secrets\n\n| Service principal | App owner tenant | Secret expiry |\n| :--- | :--- | :--- |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-10-26 |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/dc7d83b5-d38b-4488-8952-7abf02e71590/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2027-03-03 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-02-17 |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-07-01 |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-11-06 |\n| [SPO Version](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/2d6d9bf1-1f6e-48cf-bb02-31beec2f442e/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-11-17 |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-02-10 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-11-17 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-02-15 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2027-02-15 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-02-26 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2025-10-10 |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Threat actors target privileged accounts because they have access to the data and resources they want. This might include more access to your Microsoft Entra tenant, data in Microsoft SharePoint, or the ability to establish long-term persistence. Without a just-in-time (JIT) activation model, administrative privileges remain continuously exposed, providing attackers with an extended window to operate undetected. Just-in-time access mitigates risk by enforcing time-limited privilege activation with extra controls such as approvals, justification, and Conditional Access policy, ensuring that high-risk permissions are granted only when needed and for a limited duration. This restriction minimizes the attack surface, disrupts lateral movement, and forces adversaries to trigger actions that can be specially monitored and denied when not expected. Without just-in-time access, compromised admin accounts grant indefinite control, letting attackers disable security controls, erase logs, and maintain stealth, amplifying the impact of a compromise.\n\nUse Microsoft Entra Privileged Identity Management (PIM) to provide time-bound just-in-time access to privileged role assignments. Use access reviews in Microsoft Entra ID Governance to regularly review privileged access to ensure continued need.\n\n**Remediation action**\n\n- [Start using Privileged Identity Management](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-getting-started?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create an access review of Azure resource and Microsoft Entra roles in PIM](https://learn.microsoft.com/entra/id-governance/privileged-identity-management/pim-create-roles-and-resource-roles-review?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "High",
      "TestId": "21815",
      "TestCategory": "Privileged access",
      "TestTitle": "All privileged role assignments are activated just in time and not permanently active",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPrivileged users with permanent role assignments were found.\n\n\n## Privileged users with permanent role assignments\n\n\n| User | UPN | Role Name | Assignment Type |\n| :--- | :-- | :-------- | :-------------- |\n| [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true) | emergency@elapora.com | Global Administrator | Permanent |\n| [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true) | damien.bowden@elapora.com | Global Administrator | Permanent |\n| [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true) | madura@elapora.com | Global Administrator | Permanent |\n| [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true) | joshua@elapora.com | Global Administrator | Permanent |\n| [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true) | tyler@elapora.com | Global Administrator | Permanent |\n| [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true) | ann@elapora.com | Global Administrator | Permanent |\n| [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true) | aleksandar@elapora.com | Global Administrator | Permanent |\n| [Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true) | GradyA@elapora.com | User Administrator | Permanent |\n| [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true) | merillf_gmail.com#EXT#@pora.onmicrosoft.com | Global Administrator | Permanent |\n| [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true) | merill@elapora.com | Global Administrator | Permanent |\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "If certificates aren't rotated regularly, they can give threat actors an extended window to extract and exploit them, leading to unauthorized access. When credentials like these are exposed, attackers can blend their malicious activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the application's privileges.\n\nQuery all of your service principals and application registrations that have certificate credentials. Make sure the certificate start date is less than 180 days.\n\n**Remediation action**\n\n- [Define an application management policy to manage certificate lifetimes](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Define a trusted certificate chain of trust](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create a least privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) \n- [Learn more about app management policies to manage certificate based credentials](https://devblogs.microsoft.com/identity/app-management-policy/)\n",
      "TestSkipped": "",
      "TestImplementationCost": "High",
      "TestId": "21992",
      "TestCategory": "Application management",
      "TestTitle": "Application certificates must be rotated on a regular basis",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nFound 4 applications and 9 service principals in your tenant with certificates that have not been rotated within 180 days.\n\n\n## Applications with certificates that have not been rotated within 180 days\n\n| Application | Certificate Start Date |\n| :--- | :--- |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2024-06-12 |\n| [InfinityDemo - Sample](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/20f152d5-856c-449d-aa07-81f5e510dfa7) | 2021-03-05 |\n| [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | 2021-02-28 |\n| [test public client](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/79a0c604-f215-4c52-8fbe-641d08aa7937) | 2021-10-22 |\n\n\n## Service principals with certificates that have not been rotated within 180 days\n\n| Service principal | App owner tenant | Certificate Start Date |\n| :--- | :--- | :--- |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-10-26 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/5eec0e98-b81a-422a-ab61-f8de2729330d/appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2021-02-17 |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/05c98ca9-d208-4d3e-ad24-911bfc3d028c/appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2023-11-06 |\n| [SPO Version](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/4c780b09-998f-4b35-b41f-b125dc9f729a/appId/2d6d9bf1-1f6e-48cf-bb02-31beec2f442e/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2023-11-17 |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/13720002-03b6-462f-ac2f-765f0f9b3f58/appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-02-10 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-11-17 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/9a8af246-0d94-42eb-aaaf-836a9f9a4974/appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2021-02-15 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2024-02-15 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2022-10-10 |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Leaving high-priority Microsoft Entra recommendations unaddressed can create a gap in an organization’s security posture, offering threat actors opportunities to exploit known weaknesses. Not acting on these items might result in an increased attack surface area, suboptimal operations, or poor user experience. \n\n**Remediation action**\n\n- [Address all high priority recommendations in the Microsoft Entra admin center](https://learn.microsoft.com/entra/identity/monitoring-health/overview-recommendations?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-does-it-work)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "22124",
      "TestCategory": "Monitoring",
      "TestTitle": "High priority Microsoft Entra recommendations are addressed",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nFound 5 unaddressed high priority Entra recommendations.\n\n\n## Unaddressed high priority Entra recommendations\n\n| Display Name | Status | Insights |\n| :--- | :--- | :--- |\n| Protect all users with a user risk policy  | active | You have 2 of 61 users that don’t have a user risk policy enabled.  |\n| Protect all users with a sign-in risk policy | active | You have 61 of 61 users that don't have a sign-in risk policy turned on. |\n| Ensure all users can complete multifactor authentication | active | You have 46 of 61 users that aren’t registered with MFA.  |\n| Enable policy to block legacy authentication | active | You have 2 of 61 users that don’t have legacy authentication blocked.  |\n| Require multifactor authentication for administrative roles | active | You have 5 of 11 users with administrative roles that aren’t registered and protected with MFA. |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they're legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable inactive privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases. If so, [analyze if a OAuth2 permission is a better fit](https://learn.microsoft.com/entra/identity-platform/v2-app-types?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21771",
      "TestCategory": "Application management",
      "TestTitle": "Inactive applications don’t have highly privileged built-in roles",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Low",
      "TestResult": "\nFound 1 inactive applications with privileged Entra built-in roles\n\n\n## Apps with privileged Entra built-in roles\n\n| | Name | Role | Assignment | App owner tenant | Last sign in|\n| :--- | :--- | :--- | :--- | :--- | :--- |\n| ❌ | [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d22f071d-e8d3-41fc-a516-b29753cdd1f6/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | Application Administrator | Permanent |  | Unknown | \n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Unmaintained or orphaned redirect URIs in app registrations create significant security vulnerabilities when they reference domains that no longer point to active resources. Threat actors can exploit these \"dangling\" DNS entries by provisioning resources at abandoned domains, effectively taking control of redirect endpoints. This vulnerability enables attackers to intercept authentication tokens and credentials during OAuth 2.0 flows, which can lead to unauthorized access, session hijacking, and potential broader organizational compromise.\n\n**Remediation action**\n\n- [Redirect URI (reply URL) outline and restrictions](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21888",
      "TestCategory": "Application management",
      "TestTitle": "App registrations must not have dangling or abandoned domain redirect URIs",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe Redirect URIs |\n| :--- | :--- | :--- |\n|  | [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/35cbeecb-be21-4596-9869-0157d84f2d67/appId/c823a25d-fe94-494c-91f6-c7d51bf2df82/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `https://127.0.0.1` |  |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Allowing unrestricted external collaboration with unverified organizations can increase the risk surface area of the tenant because it allows guest accounts that might not have proper security controls. Threat actors can attempt to gain access by compromising identities in these loosely governed external tenants. Once granted guest access, they can then use legitimate collaboration pathways to infiltrate resources in your tenant and attempt to gain sensitive information. Threat actors can also exploit misconfigured permissions to escalate privileges and try different types of attacks.\n\nWithout vetting the security of organizations you collaborate with, malicious external accounts can persist undetected, exfiltrate confidential data, and inject malicious payloads. This type of exposure can weaken organizational control and enable cross-tenant attacks that bypass traditional perimeter defenses and undermine both data integrity and operational resilience. Cross-tenant settings for outbound access in Microsoft Entra provide the ability to block collaboration with unknown organizations by default, reducing the attack surface.\n\n**Remediation action**\n\n- [Cross-tenant access overview](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure cross-tenant access settings](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-default-settings)\n- [Modify outbound access settings](https://learn.microsoft.com/en-us/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "High",
      "TestId": "21790",
      "TestCategory": "Application management",
      "TestTitle": "Outbound cross-tenant access settings are configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nTenant has a default cross-tenant access setting outbound policy with unrestricted access.\n## [Outbound access settings - Default settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/OutboundAccessSettings.ReactView/isDefault~/true/name//id/)\n### B2B Collaboration\nUsers and groups\n- Access status: blocked\n- Applies to: Selected users and groups (0 users, 1 groups)\n\nExternal applications\n- Access status: blocked\n- Applies to: Selected external applications (2 applications)\n\n### B2B Direct Connect\nUsers and groups\n- Access status: allowed\n- Applies to: All users\n\nExternal applications\n- Access status: allowed\n- Applies to: All external applications\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Without Conditional Access policies protecting security information registration, threat actors can exploit unprotected registration flows to compromise authentication methods. When users register multifactor authentication and self-service password reset methods without proper controls, threat actors can intercept these registration sessions through adversary-in-the-middle attacks or exploit unmanaged devices accessing registration from untrusted locations. Once threat actors gain access to an unprotected registration flow, they can register their own authentication methods, effectively hijacking the target's authentication profile. The threat actors can bypass security controls and potentially escalate privileges throughout the environment because they can maintain persistent access by controlling the MFA methods. The compromised authentication methods then become the foundation for lateral movement as threat actors can authenticate as the legitimate user across multiple services and applications.\n\n**Remediation action**\n- [Create a Conditional Access policy for security info registration](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-security-info-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Configure a Conditional Access policy for network assignment](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Enable combined security info registration](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-registration-mfa-sspr-combined?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21806",
      "TestCategory": "Access control",
      "TestTitle": "Secure the MFA registration (My Security Info) page",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nSecurity information registration is not protected by Conditional Access policies.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "When guest users are assigned highly privileged directory roles such as Global Administrator or Privileged Role Administrator, organizations create significant security vulnerabilities that threat actors can exploit for initial access through compromised external accounts or business partner environments. Since guest users originate from external organizations without direct control of security policies, threat actors who compromise these external identities can gain privileged access to the target organization's Microsoft Entra tenant.\n\nWhen threat actors obtain access through compromised guest accounts with elevated privileges, they can escalate their own privilege to create other backdoor accounts, modify security policies, or assign themselves permanent roles within the organization. The compromised privileged guest accounts enable threat actors to establish persistence and then make all the changes they need to remain undetected. For example they could create cloud-only accounts, bypass Conditional Access policies applied to internal users, and maintain access even after the guest's home organization detects the compromise. Threat actors can then conduct lateral movement using administrative privileges to access sensitive resources, modify audit settings, or disable security monitoring across the entire tenant. Threat actors can reach complete compromise of the organization's identity infrastructure while maintaining plausible deniability through the external guest account origin. \n\n**Remediation action**\n\n- [Remove Guest users from privileged roles](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/best-practices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "22128",
      "TestCategory": "Application management",
      "TestTitle": "Guests are not assigned high privileged directory roles",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nGuests with privileged roles were detected.\n\n\n## Users with assigned high privileged directory roles\n\n\n| Role Name | User Name | User Principal Name | User Type | Assignment Type |\n| :-------- | :-------- | :------------------ | :-------- | :-------------- |\n| Global Administrator | [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true) | aleksandar@elapora.com | Member | Permanent |\n| Global Administrator | [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true) | ann@elapora.com | Member | Permanent |\n| Global Administrator | [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true) | merillf_gmail.com#EXT#@pora.onmicrosoft.com | Guest | Permanent |\n| Global Administrator | [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true) | damien.bowden@elapora.com | Member | Permanent |\n| Global Administrator | [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true) | emergency@elapora.com | Member | Permanent |\n| Global Administrator | [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true) | joshua@elapora.com | Member | Permanent |\n| Global Administrator | [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true) | madura@elapora.com | Member | Permanent |\n| Global Administrator | [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true) | merill@elapora.com | Member | Permanent |\n| Global Administrator | [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true) | tyler@elapora.com | Member | Permanent |\n| User Administrator | [Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true) | GradyA@elapora.com | Member | Permanent |\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "OAuth applications configured with URLs that include wildcards, or URL shorteners increase the attack surface for threat actors. Insecure redirect URIs (reply URLs) might allow adversaries to manipulate authentication requests, hijack authorization codes, and intercept tokens by directing users to attacker-controlled endpoints. Wildcard entries expand the risk by permitting unintended domains to process authentication responses, while shortener URLs might facilitate phishing and token theft in uncontrolled environments. \n\nWithout strict validation of redirect URIs, attackers can bypass security controls, impersonate legitimate applications, and escalate their privileges. This misconfiguration enables persistence, unauthorized access, and lateral movement, as adversaries exploit weak OAuth enforcement to infiltrate protected resources undetected.\n\n**Remediation action**\n\n- [Check the redirect URIs for your application registrations.](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) Make sure the redirect URIs don't have *.azurewebsites.net, wildcards, or URL shorteners.\n",
      "TestSkipped": "",
      "TestImplementationCost": "High",
      "TestId": "21885",
      "TestCategory": "Application management",
      "TestTitle": "App registrations use safe redirect URIs",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe Redirect URIs |\n| :--- | :--- | :--- |\n|  | [Azure AD SAML Toolkit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/4317fd0a-dcee-45bf-8e94-9a66638b11e0/appId/6f5ed68c-9fad-4d78-bf88-2b16bbe16338/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://samltoolkit.azurewebsites.net/SAML/Consume` |  |\n|  | [My nice app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d41cfc13-11d1-4f93-835a-88e729725564/appId/2946f286-2b59-4f29-876c-0ed8bbe1c482/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://mysalmon.azurewebsites.net/login.saml` |  |\n|  | [saml test app](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/daa6074c-db6f-4bdc-a41b-bc0052c536a5/appId/c266d677-a5f8-47bc-9f0a-1b6fbe0bddad/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | `2️⃣ https://appclaims.azurewebsites.net/signin-saml`, `2️⃣ https://appclaims.azurewebsites.net/signin-oidc` |  |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Enabling the Admin consent workflow in a Microsoft Entra tenant is a vital security measure that mitigates risks associated with unauthorized application access and privilege escalation. This check is important because it ensures that any application requesting elevated permission undergoes a review process by designated administrators before consent is granted. The admin consent workflow in Microsoft Entra ID notifies reviewers who evaluate and approve or deny consent requests based on the application's legitimacy and necessity. If this check doesn't pass, meaning the workflow is disabled, any application can request and potentially receive elevated permissions without administrative review. This poses a substantial security risk, as malicious actors could exploit this lack of oversight to gain unauthorized access to sensitive data, perform privilege escalation, or execute other malicious activities.\n\n**Remediation action**\n\nFor admin consent requests, set the **Users can request admin consent to apps they are unable to consent to** setting to **Yes**. Specify other settings, such as who can review requests.\n\n- [Enable the admin consent workflow](https://learn.microsoft.com/entra/identity/enterprise-apps/configure-admin-consent-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#enable-the-admin-consent-workflow)\n- Or use the [Update adminConsentRequestPolicy](https://learn.microsoft.com/graph/api/adminconsentrequestpolicy-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) API to set the `isEnabled` property to true and other settings\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21809",
      "TestCategory": "Application management",
      "TestTitle": "Admin consent workflow is enabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nAdmin consent workflow is disabled.\n\nThe adminConsentRequestPolicy.isEnabled property is set to false.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Organizations without proper activation alerts for highly privileged roles lack visibility into when users access these critical permissions. Threat actors can exploit this monitoring gap to perform privilege escalation by activating highly privileged roles without detection, then establish persistence through admin account creation or security policy modifications. The absence of real-time alerts enables attackers to conduct lateral movement, modify audit configurations, and disable security controls without triggering immediate response procedures.\n\n**Remediation action**\n\n- [Configure Microsoft Entra role settings in Privileged Identity Management](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#require-justification-on-activation)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21818",
      "TestCategory": "Monitoring",
      "TestTitle": "Privileged role activations have monitoring and alerting configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nRole notifications are not properly configured.\n\n\n## Notifications for high privileged roles\n\n\n| Role Name | Notification Scenario | Notification Type | Default Recipients Enabled | Additional Recipients |\n| :-------- | :-------------------- | :---------------- | :------------------------- | :-------------------- |\n| Application Administrator | Send notifications when members are assigned as eligible to this role | Role assignment alert | True | aleksandar@elapora.com |\n| Application Administrator | Send notifications when members are assigned as eligible to this role | Notification to the assigned user (assignee) | True | merill@elapora.com |\n| Application Administrator | Send notifications when members are assigned as eligible to this role | Request to approve a role assignment renewal/extension | True |  |\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Non-Microsoft and multitenant applications configured with URLs that include wildcards, localhost, or URL shorteners increase the attack surface for threat actors. These insecure redirect URIs (reply URLs) might allow adversaries to manipulate authentication requests, hijack authorization codes, and intercept tokens by directing users to attacker-controlled endpoints. Wildcard entries expand the risk by permitting unintended domains to process authentication responses, while localhost and shortener URLs might facilitate phishing and token theft in uncontrolled environments.\n\nWithout strict validation of redirect URIs, attackers can bypass security controls, impersonate legitimate applications, and escalate their privileges. This misconfiguration enables persistence, unauthorized access, and lateral movement, as adversaries exploit weak OAuth enforcement to infiltrate protected resources undetected.\n\n**Remediation action**\n\n- [Check the redirect URIs for your application registrations.](https://learn.microsoft.com/entra/identity-platform/reply-url?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) Make sure the redirect URIs don't have localhost, *.azurewebsites.net, wildcards, or URL shorteners.\n",
      "TestSkipped": "",
      "TestImplementationCost": "High",
      "TestId": "23183",
      "TestCategory": "Application management",
      "TestTitle": "Service principals use safe redirect URIs",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nUnsafe redirect URIs found\n\n1️⃣ → Use of http(s) instead of https, 2️⃣ → Use of *.azurewebsites.net, 3️⃣ → Invalid URL, 4️⃣ → Domain not resolved\n\n| | Name | Unsafe Redirect URIs |App owner tenant |\n| :--- | :--- | :--- | :--- |\n|  | [EAM Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24b12ae7-4648-4aae-b00c-6349a565d24c/appId/e6e0be31-7040-4084-ac44-600b67661f2c) | `2️⃣ https://eamdemo.azurewebsites.net` | 1852b10f-a011-428b-98f9-d09c37d477cf |\n|  | [FIDO2-passkeys-MFA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1aa7e155-cbf8-4970-8458-05a0c7a2d1a5/appId/4fabcfc0-5c44-45a1-8c80-8537f0625949) | `2️⃣ https://fidomfaserver.azurewebsites.net/connect/authorize` | 1852b10f-a011-428b-98f9-d09c37d477cf |\n|  | [Graph Explorer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f8f300a-870a-46ff-bdab-934e1436920d/appId/d3ce4cf8-6810-442d-b42e-375e14710095) | `2️⃣ https://graphexplorer.azurewebsites.net/` | 5508eaf2-e7b4-4510-a4fb-9f5970550d80 |\n|  | [Graph explorer (official site)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cd2e9b58-eb21-4a50-a338-33f9daa1599c/appId/de8bc8b5-d9f9-48b1-a8ad-b748da725064) | `2️⃣ https://graphtryit.azurewebsites.net`, `2️⃣ https://graphtryit.azurewebsites.net/` | 72f988bf-86f1-41af-91ab-2d7cd011db47 |\n|  | [Internal_AccessScope](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/180a3ccb-3f2f-486f-8b56-025fc225166d/appId/3f9bd1ee-5a72-4ad3-b67d-cb016f935bcf) | `1️⃣ http://featureconfiguration.onmicrosoft.com/Internal_AccessScope` | 0d2db716-b331-4d7b-aa37-7f1ac9d35dae |\n|  | [Modern Workplace Concierge](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad1c51e8-f8a8-4bf2-ac09-a3a20cba5fa5/appId/c65c4011-1b90-4ec9-b5e9-1ee17786ad84) | `2️⃣ https://mwconcierge.azurewebsites.net/` | 7955e1b3-cbad-49eb-9a84-e14aed7f3400 |\n|  | [entraChatAppMultiTenant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/855a57ff-88a6-4ad0-85d7-4f46d742730e/appId/5e00b345-a805-42a0-9caa-7d6cb761c668) | `2️⃣ https://entrachatapp.azurewebsites.net`, `2️⃣ https://entrachatapp.azurewebsites.net/redirect` | 8b047ec6-6d2e-481d-acfa-5d562c09f49a |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "A threat actor can intercept or extract authentication tokens from memory, local storage on a legitimate device, or by inspecting network traffic. The attacker might replay those tokens to bypass authentication controls on users and devices, get unauthorized access to sensitive data, or run further attacks. Because these tokens are valid and time bound, traditional anomaly detection often fails to flag the activity, which might allow sustained access until the token expires or is revoked.\n\nToken protection, also called token binding, helps prevent token theft by making sure a token is usable only from the intended device. Token protection uses cryptography so that without the client device key, no one can use the token.\n\n**Remediation action**   \nCreate a Conditional Access policy to set up token protection.   \n- [Microsoft Entra Conditional Access: Token protection](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-token-protection?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21786",
      "TestCategory": "Access control",
      "TestTitle": "User sign-in activity uses token protection",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nThe tenant is missing properly configured Token Protection policies.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Global Administrators with persistent access to Azure subscriptions expand the attack surface for threat actors. If a Global Administrator account is compromised, attackers can immediately enumerate resources, modify configurations, assign roles, and exfiltrate sensitive data across all subscriptions. Requiring just-in-time elevation for subscription access introduces detectable signals, slows attacker velocity, and routes high-impact operations through observable control points.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths.md)\n\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity.md)",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21788",
      "TestCategory": "Privileged access",
      "TestTitle": "Global Administrators don't have standing access to Azure subscriptions",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nStanding access to Root Management group was found.\n\n\n## Entra ID objects with standing access to Root Management group\n\n\n| Entra ID Object | Object ID | Principal type |\n| :-------------- | :-------- | :------------- |\n| merill@elapora.com | 513f3db2-044c-41be-af14-431bf88a2b3e | User |\n| madura@elapora.com | 5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a | User |\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "High",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21782",
      "TestCategory": "Privileged access",
      "TestTitle": "Privileged accounts have phishing-resistant methods registered",
      "TestTags": [
        "Credential"
      ],
      "TestImpact": "Low",
      "TestResult": "\nFound privileged users that have not yet registered phishing resistant authentication methods\n\n## Privileged users\n\nFound privileged users that have not registered phishing resistant authentication methods.\n\nUser | Role Name | Phishing resistant method registered |\n| :--- | :--- | :---: |\n|[Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true)| User Administrator | ❌ |\n|[Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f/hidePreviewBanner~/true)| Directory Synchronization Accounts | ❌ |\n|[Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Attribute Definition Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Attribute Assignment Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Global Administrator | ✅ |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "Threat actors can exploit the lack of multifactor authentication during new device registration. Once authenticated, they can register rogue devices, establish persistence, and circumvent security controls tied to trusted endpoints. This foothold enables attackers to exfiltrate sensitive data, deploy malicious applications, or move laterally, depending on the permissions of the accounts being used by the attacker. Without MFA enforcement, risk escalates as adversaries can continuously reauthenticate, evade detection, and execute objectives.\n\n**Remediation action**\n\n- Create a Conditional Access policy to [require multifactor authentication for device registration](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-device-registration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21872",
      "TestCategory": "Access control",
      "TestTitle": "Require multifactor authentication for device join and device registration using user action",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\n**Properly configured Conditional Access policies found** that require MFA for device registration/join actions.\n## Device Settings Configuration\n\n| Setting | Value | Recommended Value | Status |\n| :------ | :---- | :---------------- | :----- |\n| Require Multi-Factor Authentication to register or join devices | No | No | ✅ Correctly configured |\n\n## Device Registration/Join Conditional Access Policies\n\n| Policy Name | State | Requires MFA | Status |\n| :---------- | :---- | :----------- | :----- |\n| [testdevicereg21872](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/620a9c5c-09c4-4558-a0fe-7fc8b3540992) | enabled | Yes | ✅ Properly configured |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "Users considered at high risk by Microsoft Entra ID Protection have a high probability of compromise by threat actors. Threat actors can gain initial access via compromised valid accounts, where their suspicious activities continue despite triggering risk indicators. This oversight can enable persistence as threat actors perform activities that normally warrant investigation, such as unusual login patterns or suspicious inbox manipulation. \n\nA lack of triage of these risky users allows for expanded reconnaissance activities and lateral movement, with anomalous behavior patterns continuing to generate uninvestigated alerts. Threat actors become emboldened as security teams show they aren't actively responding to risk indicators.\n\n**Remediation action**\n\n- [Investigate high risk users](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in Microsoft Entra ID Protection\n- [Remediate high risk users and unblock](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-remediate-unblock?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) in Microsoft Entra ID Protection\n",
      "TestSkipped": "",
      "TestImplementationCost": "High",
      "TestId": "21861",
      "TestCategory": "Monitoring",
      "TestTitle": "All high-risk users are triaged",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nAll high-risk users are properly triaged in Entra ID Protection.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "Blocking authentication transfer in Microsoft Entra ID is a critical security control. It helps protect against token theft and replay attacks by preventing the use of device tokens to silently authenticate on other devices or browsers. When authentication transfer is enabled, a threat actor who gains access to one device can access resources to nonapproved devices, bypassing standard authentication and device compliance checks. When administrators block this flow, organizations can ensure that each authentication request must originate from the original device, maintaining the integrity of the device compliance and user session context.\n\n**Remediation action**\n- [Block authentication flows with Conditional Access policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-block-authentication-flows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21828",
      "TestCategory": "Access control",
      "TestTitle": "Secure the MFA registration (My Security Info) page",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nAuthentication transfer is blocked by Conditional Access Policy(s).\n## Conditional Access Policies targeting Authentication Transfer\n\n\n| Policy Name | Policy ID | State | Created | Modified |\n| :---------- | :-------- | :---- | :------ | :------- |\n| [Block Device Code](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/db2153a1-40a2-457f-917c-c280b204b5cd) | db2153a1-40a2-457f-917c-c280b204b5cd | enabled | 2024-02-28 | 2025-04-16 |\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "Device code flow is a cross-device authentication flow designed for input-constrained devices. It can be exploited in phishing attacks, where an attacker initiates the flow and tricks a user into completing it on their device, thereby sending the user's tokens to the attacker. Given the security risks and the infrequent legitimate use of device code flow, you should enable a Conditional Access policy to block this flow by default.\n\n**Remediation action**\n\n- Create a Conditional Access policy to [block device code flow](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-authentication-flows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#device-code-flow-policies).\n- [Learn more about device code flow](https://learn.microsoft.com/entra/identity/conditional-access/concept-authentication-flows?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#device-code-flow)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21808",
      "TestCategory": "Access control",
      "TestTitle": "Restrict device code flow",
      "TestTags": [
        "ConditionalAccess"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nDevice code flow is properly restricted in the tenant.\n## Conditional Access Policies targeting Device Code Flow\n\n| Policy Name | Status | Target Users | Target Resources | Grant Controls |\n| :---------- | :----- | :----------- | :--------------- | :------------ |\n| [Block Device Code](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/db2153a1-40a2-457f-917c-c280b204b5cd) | Enabled | All Users, Excluded: 3 users/groups | All Applications | Block (ANY) |\n\n## Inactive Conditional Access Policies targeting Device Code Flow\nThese policies are not contributing to your security posture because they are not enabled:\n\n| Policy Name | Status | Target Users | Target Resources | Grant Controls |\n| :---------- | :----- | :----------- | :--------------- | :------------ |\n| [Block DCF](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/b5ff217b-3d84-4581-bd92-5d8f8b8bab6a) | Disabled | All Users | All Applications | Block (ANY) |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect networks",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "Tenant Restrictions v2 (TRv2) allows organizations to enforce policies that restrict access to specified Microsoft Entra tenants, preventing unauthorized exfiltration of corporate data to external tenants using local accounts. Without TRv2, threat actors can exploit this vulnerability, which leads to potential data exfiltration and compliance violations, followed by credential harvesting if those external tenants have weaker controls. Once credentials are obtained, threat actors can gain initial access to these external tenants. TRv2 provides the mechanism to prevent users from authenticating to unauthorized tenants. Otherwise, threat actors can move laterally, escalate privileges, and potentially exfiltrate sensitive data, all while appearing as legitimate user activity that bypasses traditional data loss prevention controls focused on internal tenant monitoring.\n\nImplementing TRv2 enforces policies that restrict access to specified tenants, mitigating these risks by ensuring that authentication and data access are confined to authorized tenants only. \n\nIf this check passes, your tenant has a TRv2 policy configured but more steps are required to validate the scenario end-to-end.\n\n**Remediation action**\n- [Set up Tenant Restrictions v2](https://learn.microsoft.com/en-us/entra/external-id/tenant-restrictions-v2?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21793",
      "TestCategory": "Application management",
      "TestTitle": "Tenant restrictions v2 policy is configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nTenant Restrictions v2 policy is properly configured.\n\n\n## Tenant restriction settings\n\n\n| Policy Configured | External users and groups | External applications |\n| :---------------- | :------------------------ | :-------------------- |\n| [Yes](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/TenantRestrictions.ReactView/isDefault~/true/name//id/) | All external users and groups | All external applications |\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "Without approval workflows, threat actors who compromise Global Administrator credentials through phishing, credential stuffing, or other authentication bypass techniques can immediately activate the most privileged role in a tenant without any other verification or oversight. Privileged Identity Management (PIM) allows eligible role activations to become active within seconds, so compromised credentials can allow near-instant privilege escalation. Once activated, threat actors can use the Global Administrator role to use the following attack paths to gain persistent access to the tenant:\n- Create new privileged accounts\n- Modify Conditional Access policies to exclude those new accounts\n- Establish alternate authentication methods such as certificate-based authentication or application registrations with high privileges\n\nThe Global Administrator role provides access to administrative features in Microsoft Entra ID and services that use Microsoft Entra identities, including Microsoft Defender XDR, Microsoft Purview, Exchange Online, and SharePoint Online. Without approval gates, threat actors can rapidly escalate to complete tenant takeover, exfiltrating sensitive data, compromising all user accounts, and establishing long-term backdoors through service principals or federation modifications that persist even after the initial compromise is detected. \n\n**Remediation action**\n\n- [Configure role settings to require approval for Global Administrator activation](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-how-to-change-default-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Set up approval workflow for privileged roles](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-approval-workflow?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21817",
      "TestCategory": "Application management",
      "TestTitle": "Global Administrator role activation triggers an approval workflow",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\n✅ **Pass**: Approval required with 2 primary approver(s) configured.\n\n\n## Global Administrator role activation and approval workflow\n\n\n| Approval Required | Primary Approvers | Escalation Approvers |\n| :---------------- | :---------------- | :------------------- |\n| Yes | Aleksandar Nikolic, Merill Fernando |  |\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "If an on-premises account is compromised and is synchronized to Microsoft Entra, the attacker might gain access to the tenant as well. This risk increases because on-premises environments typically have more attack surfaces due to older infrastructure and limited security controls. Attackers might also target the infrastructure and tools used to enable connectivity between on-premises environments and Microsoft Entra. These targets might include tools like Microsoft Entra Connect or Active Directory Federation Services, where they could impersonate or otherwise manipulate other on-premises user accounts.\n\nIf privileged cloud accounts are synchronized with on-premises accounts, an attacker who acquires credentials for on-premises can use those same credentials to access cloud resources and move laterally to the cloud environment.\n\n**Remediation action**\n\n- [Protecting Microsoft 365 from on-premises attacks](https://learn.microsoft.com/entra/architecture/protect-m365-from-on-premises-attacks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#specific-security-recommendations)\n\nFor each role with high privileges (assigned permanently or eligible through Microsoft Entra Privileged Identity Management), you should do the following actions:\n\n- Review the users that have onPremisesImmutableId and onPremisesSyncEnabled set. See [Microsoft Graph API user resource type](https://learn.microsoft.com/graph/api/resources/user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Create cloud-only user accounts for those individuals and remove their hybrid identity from privileged roles.\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21814",
      "TestCategory": "Privileged access",
      "TestTitle": "Privileged accounts are cloud native identities",
      "TestTags": [
        "PrivilegedIdentity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nValidated that standing or eligible privileged accounts are cloud only accounts.\n\n## Privileged Roles\n\n| Role Name | User | Source | Status |\n| :--- | :--- | :--- | :---: |\n| Global Administrator | [Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165) | Cloud native identity | ✅ |\n| Global Administrator | [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e) | Cloud native identity | ✅ |\n| Global Administrator | [Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a) | Cloud native identity | ✅ |\n| Global Administrator | [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7) | Cloud native identity | ✅ |\n| Global Administrator | [Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/7094fb23-003a-4f81-9796-5daeaa603003) | Cloud native identity | ✅ |\n| Global Administrator | [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a) | Cloud native identity | ✅ |\n| Global Administrator | [Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/bfaeba1e-1357-47de-9557-529caa103d5d) | Cloud native identity | ✅ |\n| Global Administrator | [Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/ceef37b7-c865-48fb-80c9-4def11201854) | Cloud native identity | ✅ |\n| Global Administrator | [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6) | Cloud native identity | ✅ |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Accelerate response and remediation",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "Assume any users at high risk are compromised by threat actors. Without investigation and remediation, threat actors can execute scripts, deploy malicious applications, or manipulate API calls to establish persistence, based on the potentially compromised user's permissions. Threat actors can then exploit misconfigurations or abuse OAuth tokens to move laterally across workloads like documents, SaaS applications, or Azure resources. Threat actors can gain access to sensitive files, customer records, or proprietary code and exfiltrate it to external repositories while maintaining stealth through legitimate cloud services. Finally, threat actors might disrupt operations by modifying configurations, encrypting data for ransom, or using the stolen information for further attacks, resulting in financial, reputational, and regulatory consequences.\n\n**Remediation action**\n\n- Create a Conditional Access policy to [require a secure password change for elevated user risk](https://learn.microsoft.com/entra/identity/conditional-access/policy-risk-based-user?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Use Microsoft Entra ID Protection to [further investigate risk](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21797",
      "TestCategory": "Access control",
      "TestTitle": "Restrict access to high risk users",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestResult": "\nPolicies to restrict access for high risk users are properly implemented.\n## Passwordless Authentication Methods allowed in tenant\n\n| Authentication Method Name | State | Additional Info |\n| :------------------------ | :---- | :-------------- |\n| Fido2 | enabled |  |\n\n## Conditional Access Policies targeting high risk users\n\n| Conditional Access Policy Name | Status | Conditions |\n| :--------------------- | :----- | :--------- |\n| [Require password change for high-risk users](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/ddbc3bb1-3749-474f-b8c3-0d997118b24b) | Enabled | User Risk Level: High, Control: Password Change |\n| [CISA SCuBA.MS.AAD.2.3: Users detected as high risk SHALL be blocked.](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/94c7d8d0-5c8c-460d-8ace-364374250893) | Enabled | User Risk Level: High, Control: Block |\n| [Force Password Change](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/5848211d-96f2-40ae-92a4-af1aa8f48572) | Disabled | User Risk Level: High, Control: Password Change |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "Legacy multifactor authentication (MFA) and self-service password reset (SSPR) policies in Microsoft Entra ID manage authentication methods separately, leading to fragmented configurations and suboptimal user experience. Moreover, managing these policies independently increases administrative overhead and the risk of misconfiguration.  \n\nMigrating to the combined Authentication Methods policy consolidates the management of MFA, SSPR, and passwordless authentication methods into a single policy framework. This unification allows for more granular control, enabling administrators to target specific authentication methods to user groups and enforce consistent security measures across the organization. Additionally, the unified policy supports modern authentication methods, such as FIDO2 security keys and Windows Hello for Business, enhancing the organization's security posture.\n\nMicrosoft announced the deprecation of legacy MFA and SSPR policies, with a retirement date set for September 30, 2025. Organizations are advised to complete the migration to the Authentication Methods policy before this date to avoid potential disruptions and to benefit from the enhanced security and management capabilities of the unified policy.\n\n**Remediation action**\n\n- [Enable combined security information registration](https://learn.microsoft.com/entra/identity/authentication/howto-registration-mfa-sspr-combined?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [How to migrate MFA and SSPR policy settings to the Authentication methods policy for Microsoft Entra ID](https://learn.microsoft.com/entra/identity/authentication/how-to-authentication-methods-manage?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21803",
      "TestCategory": "Credential management",
      "TestTitle": "Migrate from legacy MFA and SSPR policies",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nCombined registration is enabled.\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "Risky sign-ins flagged by Microsoft Entra ID Protection indicate a high probability of unauthorized access attempts. Threat actors use these sign-ins to gain an initial foothold. If these sign-ins remain uninvestigated, adversaries can establish persistence by repeatedly authenticating under the guise of legitimate users. \n\nA lack of response lets attackers execute reconnaissance, attempt to escalate their access, and blend into normal patterns. When untriaged sign-ins continue to generate alerts and there's no intervention, security gaps widen, facilitating lateral movement and defense evasion, as adversaries recognize the absence of an active security response.\n\n**Remediation action**\n\n- [Investigate risky sign-ins](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-investigate-risk?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Remediate risks and unblock users](https://learn.microsoft.com/entra/id-protection/howto-identity-protection-remediate-unblock?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "High",
      "TestId": "21863",
      "TestCategory": "Monitoring",
      "TestTitle": "All high-risk sign-ins are triaged",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nNo untriaged risky sign ins in the tenant.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "Microsoft services applications that operate in your tenant are identified as service principals with the owner organization ID \"f8cdef31-a31e-4b4a-93e4-5f571e91255a.\" When these service principals have credentials configured in your tenant, they might create potential attack vectors that threat actors can exploit. If an administrator added the credentials and they're no longer needed, they can become a target for attackers. Although less likely when proper preventive and detective controls are in place on privileged activities, threat actors can also maliciously add credentials. In either case, threat actors can use these credentials to authenticate as the service principal, gaining the same permissions and access rights as the Microsoft service application. This initial access can lead to privilege escalation if the application has high-level permissions, allowing lateral movement across the tenant. Attackers can then proceed to data exfiltration or persistence establishment through creating other backdoor credentials.\n\nWhen credentials (like client secrets or certificates) are configured for these service principals in your tenant, it means someone - either an administrator or a malicious actor - enabled them to authenticate independently within your environment. These credentials should be investigated to determine their legitimacy and necessity. If they're no longer needed, they should be removed to reduce the risk. \n\nIf this check doesn't pass, the recommendation is to \"investigate\" because you need to identify and review any applications with unused credentials configured.\n\n**Remediation action**\n\n- Confirm if the credentials added are still valid use cases. If not, remove credentials from Microsoft service applications to reduce security risk. \n    - In the Microsoft Entra admin center, browse to **Entra ID** > **App registrations** and select the affected application.\n    - Go to the **Certificates & secrets** section and remove any credentials that are no longer needed.",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21774",
      "TestCategory": "Application management",
      "TestTitle": "Microsoft services applications don't have credentials configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nNo Microsoft services applications have credentials configured in the tenant.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Passed",
      "TestRisk": "High",
      "TestDescription": "An on-premises federation server introduces a critical attack surface by serving as a central authentication point for cloud applications. Threat actors often gain a foothold by compromising a privileged user such as a help desk representative or an operations engineer through attacks like phishing, credential stuffing, or exploiting weak passwords. They might also target unpatched vulnerabilities in infrastructure, use remote code execution exploits, attack the Kerberos protocol, or use pass-the-hash attacks to escalate privileges. Misconfigured remote access tools like remote desktop protocol (RDP), virtual private network (VPN), or jump servers provide other entry points, while supply chain compromises or malicious insiders further increase exposure. Once inside, threat actors can manipulate authentication flows, forge security tokens to impersonate any user, and pivot into cloud environments. Establishing persistence, they can disable security logs, evade detection, and exfiltrate sensitive data.\n\n**Remediation action**\n\n- [Migrate from federation to cloud authentication like Microsoft Entra Password hash synchronization (PHS)](https://learn.microsoft.com/entra/identity/hybrid/connect/migrate-from-federation-to-cloud-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n",
      "TestSkipped": "",
      "TestImplementationCost": "High",
      "TestId": "21829",
      "TestCategory": "Access control",
      "TestTitle": "Use cloud authentication",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestResult": "\nAll domains are using cloud authentication.\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "High",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21864",
      "TestCategory": "Access control",
      "TestTitle": "All risk detections are triaged",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "High",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21912",
      "TestCategory": "Access control",
      "TestTitle": "Azure resources used by Microsoft Entra only allow access from privileged roles",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Planned",
      "TestRisk": "High",
      "TestDescription": "Without restricted user consent settings, threat actors can exploit permissive application consent configurations to gain unauthorized access to sensitive organizational data. When user consent is unrestricted, attackers can:\n\n- Use social engineering and illicit consent grant attacks to trick users into approving malicious applications.\n- Impersonate legitimate services to request broad permissions, such as access to email, files, calendars, and other critical business data.\n- Obtain legitimate OAuth tokens that bypass perimeter security controls, making access appear normal to security monitoring systems.\n- Establish persistent access to organizational resources, conduct reconnaissance across Microsoft 365 services, move laterally through connected systems, and potentially escalate privileges.\n\nUnrestricted user consent also limits an organization's ability to enforce centralized governance over application access, making it difficult to maintain visibility into which non-Microsoft applications have access to sensitive data. This gap creates compliance risks where unauthorized applications might violate data protection regulations or organizational security policies.\n\n**Remediation action**\n\n-  [Configure restricted user consent settings](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/configure-user-consent?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) to prevent illicit consent grants by disabling user consent or limiting it to verified publishers with low-risk permissions only.",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21776",
      "TestCategory": "Application management",
      "TestTitle": "User consent settings are restricted",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "High",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "22659",
      "TestCategory": "Access control",
      "TestTitle": "All risky workload identity sign ins are triaged",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Planned",
      "TestRisk": "High",
      "TestDescription": "If administrators assign privileged roles to workload identities, such as service principals or managed identities, the tenant can be exposed to significant risk if those identities are compromised. Threat actors who gain access to a privileged workload identity can perform reconnaissance to enumerate resources, escalate privileges, and manipulate or exfiltrate sensitive data. The attack chain typically begins with credential theft or abuse of a vulnerable application. Next step is privilege escalation through the assigned role, lateral movement across cloud resources, and finally persistence via other role assignments or credential updates. Workload identities are often used in automation and might not be monitored as closely as user accounts. Compromise can then go undetected, allowing threat actors to maintain access and control over critical resources. Workload identities aren't subject to user-centric protections like MFA, making least-privilege assignment and regular review essential. \n\n**Remediation action**\n- [Review and remove privileged roles assignments](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-resource-roles-assign-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#update-or-remove-an-existing-role-assignment).\n- [Follow the best practices for workload identities](https://learn.microsoft.com/en-us/entra/workload-id/workload-identities-overview?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#key-scenarios).\n- [Learn about privileged roles and permissions in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/privileged-roles-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21836",
      "TestCategory": "Application management",
      "TestTitle": "Workload Identities are not assigned privileged roles",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestStatus": "Planned",
      "TestRisk": "High",
      "TestDescription": "If you don't enable ID Protection notifications, your organization loses critical real-time alerts when threat actors compromise user accounts or conduct reconnaissance activities. When Microsoft Entra ID Protection detects accounts at risk, it sends email alerts with **Users at risk detected** as the subject and links to the **Users flagged for risk** report. Without these notifications, security teams remain unaware of active threats, allowing threat actors to maintain persistence in compromised accounts without being detected. You can feed these risks into tools like Conditional Access to make access decisions or send them to a security information and event management (SIEM) tool for investigation and correlation. Threat actors can use this detection gap to conduct lateral movement activities, privilege escalation attempts, or data exfiltration operations while administrators remain unaware of the ongoing compromise. The delayed response enables threat actors to establish more persistence mechanisms, change user permissions, or access sensitive resources before you can fix the issue. Without proactive notification of risk detections, organizations must rely solely on manual monitoring of risk reports, which significantly increases the time it takes to detect and respond to identity-based attacks.   \n\n**Remediation action**\n\n- [Configure users at risk detected alerts](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-notifications?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#configure-users-at-risk-detected-alerts)  \n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21798",
      "TestCategory": "Access control",
      "TestTitle": "ID Protection notifications are enabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestStatus": "Planned",
      "TestRisk": "High",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-strengths)\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21781",
      "TestCategory": "Privileged access",
      "TestTitle": "Privileged users sign in with phishing-resistant methods",
      "TestTags": [
        "Authentication"
      ],
      "TestImpact": "Low",
      "TestResult": "\nFound Accounts have not registered phishing resistant methods\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Planned",
      "TestRisk": "High",
      "TestDescription": "Configuring password reset notifications for administrator roles in Microsoft Entra ID enhances security by notifying privileged administrators when another administrator resets their password. This visibility helps detect unauthorized or suspicious activity that could indicate credential compromise or insider threats. Without these notifications, malicious actors could exploit elevated privileges to establish persistence, escalate access, or extract sensitive data. Proactive notifications support quick action, preserve privileged access integrity, and strengthen the overall security posture.   \n\n**Remediation action**\n\n- [Notify all admins when other admins reset their passwords](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-sspr-howitworks?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#notify-all-admins-when-other-admins-reset-their-passwords) \n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21891",
      "TestCategory": "Access control",
      "TestTitle": "Require password reset notifications for administrator roles",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "High",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21881",
      "TestCategory": "Access control",
      "TestTitle": "Azure subscriptions used by Identity Governance are secured consistently with Identity Governance roles",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21834",
      "TestCategory": "Access control",
      "TestTitle": "Directory sync account is locked down to specific named location",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21848",
      "TestCategory": "Access control",
      "TestTitle": "Enable custom banned passwords",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21813",
      "TestCategory": "Privileged access",
      "TestTitle": "High Global Administrator to privileged user ratio",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21839",
      "TestCategory": "Access control",
      "TestTitle": "Passkey authentication method enabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21844",
      "TestCategory": "Access control",
      "TestTitle": "Block legacy Azure AD PowerShell module",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21964",
      "TestCategory": "Access control",
      "TestTitle": "Enable protected actions to secure Conditional Access policy creation and changes",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21842",
      "TestCategory": "Access control",
      "TestTitle": "Block administrators from using SSPR",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21954",
      "TestCategory": "Access control",
      "TestTitle": "Restrict nonadministrator users from recovering the BitLocker keys for their owned devices",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21816",
      "TestCategory": "Privileged access",
      "TestTitle": "All privileged role assignments are managed with PIM",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21843",
      "TestCategory": "Access control",
      "TestTitle": "Block legacy Microsoft Online PowerShell module",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21837",
      "TestCategory": "Device management",
      "TestTitle": "Limit the maximum number of devices per user to 10",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21846",
      "TestCategory": "Access control",
      "TestTitle": "Temporary access pass restricted to one-time use",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21845",
      "TestCategory": "Access control",
      "TestTitle": "Temporary access pass is enabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21812",
      "TestCategory": "Privileged access",
      "TestTitle": "Maximum number of Global Administrators doesn't exceed eight users",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21984",
      "TestCategory": "Access control",
      "TestTitle": "No Active low priority Entra recommendations found",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21820",
      "TestCategory": "Privileged access",
      "TestTitle": "Activation alert for all privileged role assignments",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21838",
      "TestCategory": "Access control",
      "TestTitle": "Security key authentication method enabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21894",
      "TestCategory": "Access control",
      "TestTitle": "All certificates Microsoft Entra Application Registrations and Service Principals must be issued by an approved certification authority",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21775",
      "TestCategory": "Access control",
      "TestTitle": "Tenant app management policy is configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21889",
      "TestCategory": "Access control",
      "TestTitle": "Reduce the user-visible password surface area",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21870",
      "TestCategory": "Access control",
      "TestTitle": "Enable SSPR",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21833",
      "TestCategory": "Privileged access",
      "TestTitle": "Directory Sync account credentials haven't been rotated recently",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21840",
      "TestCategory": "Access control",
      "TestTitle": "Security key attestation is enforced",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21895",
      "TestCategory": "Access control",
      "TestTitle": "Application Certificate Credentials are managed using HSM",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21893",
      "TestCategory": "Access control",
      "TestTitle": "Enable Microsoft Entra ID Protection policy to enforce multifactor authentication registration",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21955",
      "TestCategory": "Access control",
      "TestTitle": "Manage the local administrators on Microsoft Entra joined devices",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21841",
      "TestCategory": "Access control",
      "TestTitle": "Authenticator app report suspicious activity is enabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21835",
      "TestCategory": "Privileged access",
      "TestTitle": "Emergency account exists",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21867",
      "TestCategory": "Access control",
      "TestTitle": "All enterprise applications have owners",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Low",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21953",
      "TestCategory": "Access control",
      "TestTitle": "Local Admin Password Solution is deployed",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "Medium",
      "TestDescription": "Legacy authentication protocols such as basic authentication for SMTP and IMAP don't support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This lack of protection makes accounts using these protocols vulnerable to password-based attacks, and provides attackers with a means to gain initial access using stolen or guessed credentials.\n\nWhen an attacker successfully gains unauthorized access to credentials, they can use them to access linked services, using the weak authentication method as an entry point. Attackers who gain access through legacy authentication might make changes to Microsoft Exchange, such as configuring mail forwarding rules or changing other settings, allowing them to maintain continued access to sensitive communications.\n\nLegacy authentication also provides attackers with a consistent method to reenter a system using compromised credentials without triggering security alerts or requiring reauthentication.\n\nFrom there, attackers can use legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement. Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.\n\n**Remediation action**\n\nDeploy the following Conditional Access policy:\n\n- [Block legacy authentication](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21796",
      "TestCategory": "Access control",
      "TestTitle": "Block legacy authentication policy is configured",
      "TestTags": [
        "User",
        "Credential"
      ],
      "TestImpact": "High",
      "TestResult": "\nPolicies to block legacy authentication were found but are not properly configured.\n\n  - [Block legacy authentication](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/4086128c-3850-48ac-8962-e19a956828bd) (Report-only)\n  - [Block legacy authentication - Testing](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/bedecc1e-85c9-4d54-b885-cefe6bcc8763) (Report-only)\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "Medium",
      "TestDescription": "Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.\n\nAttackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.\n\n**Remediation action**\n\n- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policies to enforce authentication strength](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21801",
      "TestCategory": "Credential management",
      "TestTitle": "Users have strong authentication methods configured",
      "TestTags": [
        "Credential"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nFound users that have not yet registered phishing resistant authentication methods\n\n## Users strong authentication methods\n\nFound users that have not registered phishing resistant authentication methods.\n\nUser | Last sign in | Phishing resistant method registered |\n| :--- | :--- | :---: |\n|[Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Aleksandar Nikolic](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/bfaeba1e-1357-47de-9557-529caa103d5d/hidePreviewBanner~/true)| 2025-07-21 | ❌ |\n|[Ann Quinzon](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2072badc-3cf0-4e84-b4c2-f9c065c46165/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Anna Jorayew](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/58d9ed99-93ca-4674-8c5f-ec770f5ba17d/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Bagul Atayewa](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5655cf54-34bc-4f36-bb74-44da35547975/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true)| 2024-01-20 | ❌ |\n|[Daniel Nguyen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ddfb9311-801e-4a84-9466-a18086768b73/hidePreviewBanner~/true)| Unknown | ❌ |\n|[David Kim](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/1b156c3d-79c5-44d2-a88c-23f69216777f/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Emma Johnson](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e498eab5-b6b5-493f-8353-b8c350083791/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Faiza Malkia](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/36bf7e02-3abc-46aa-895f-cf95227377fd/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true)| 2023-11-15 | ❌ |\n|[Hamisi Khari](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/494995bf-5510-450c-a317-6d24f63cd15b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Henrietta Mueller](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/eb6a4040-3ff6-4911-a80d-68c701384c38/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Isaiah Langer](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2a054082-8f05-4e05-8fce-4e35c3bb40cc/hidePreviewBanner~/true)| 2023-12-12 | ❌ |\n|[Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0145d508-50fd-4f86-a47a-bf1c043c8358/hidePreviewBanner~/true)| Unknown | ❌ |\n|[James Thompson](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ba635de8-4625-42eb-a59a-87f507ad9a9e/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Jane Doe](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/57c41b80-a96a-4c06-8ab9-9539818a637f/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Jessica Taylor](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/983164a3-87fa-4071-aa67-ff1530092df1/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Johanna Lorenz](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/8994aee7-8c36-4e04-9116-8f21d8acdeb7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John Doe Test 1](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/fcebe3cc-ca26-49c6-9bb1-c9eafb243634/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John Doe Test 1](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/69a2da18-6395-4a90-bde8-72e8aaa6c775/hidePreviewBanner~/true)| Unknown | ❌ |\n|[John1 Doe](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/77d4be98-c05d-4478-be25-3ee710b5247e/hidePreviewBanner~/true)| 2024-11-04 | ❌ |\n|[Joni Sherman](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2da436f2-952a-47de-9dfe-84bd2f0d93e9/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Lee Gu](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0a9e313b-8777-4741-ba14-0f2724179117/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Lidia Holloway](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/9188d3d3-386c-4145-a811-0d777a288e11/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Lynne Robbins](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/8e5f7749-d5e7-46fc-8eb7-3b8ab7e20ae5/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Madura Sonnadara](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5b0ec3ff-cea1-4eb9-8530-f2a66e5bec0a/hidePreviewBanner~/true)| 2025-07-18 | ❌ |\n|[Megan Bowen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/96d29f01-873c-46a3-b542-f7ee192cc675/hidePreviewBanner~/true)| 2025-06-28 | ❌ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a0883b7a-c6a8-440f-84f0-d6e1b79aaf4c/hidePreviewBanner~/true)| 2024-05-10 | ❌ |\n|[Michael Wong](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/63e4e634-15e4-4a85-bc9c-532855574377/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Miriam Graham](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f5745554-1894-4fb0-9560-65d6fc489724/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Nestor Wilke](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/24b9254d-1bc5-435c-ad3d-7dbee86f8b9a/hidePreviewBanner~/true)| Unknown | ❌ |\n|[New User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/6eef8ea0-1263-4973-9b0b-1e7aed0d21cd/hidePreviewBanner~/true)| Unknown | ❌ |\n|[No Location](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/696743fa-055b-42fb-aac4-ab451a4617d6/hidePreviewBanner~/true)| Unknown | ❌ |\n|[NoMail Enabled](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a740d122-ee21-4354-9423-adccf8b6b233/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Olivia Patel](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/03a5c332-4d75-47fd-b211-838e8cd0ee1b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f/hidePreviewBanner~/true)| 2024-06-17 | ❌ |\n|[Patti Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/3bae3a95-7605-4271-8418-e35733991834/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Pradeep Gupta](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ac712f60-0052-4911-8c5d-146cf9d4dc59/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Rhea Stone](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ac49a6e5-09c1-404b-915e-0d28574b3d72/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Richard Wilkings](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c27e2b23-c322-4a79-8c6f-9dba8fd9f4e2/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Roi Fraguela](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e0a814e5-5169-4af2-bb19-63930b42ac41/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Ryan Chen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/9605b9f8-9823-4c33-8018-57ad32d9fcb9/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Sandy](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d5e32d0c-3f3c-43ef-abe1-75890a73f40c/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Sarah Mitchell](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0ca3a9f0-7e3c-44c5-9638-250be0d94621/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Shonali Balakrishna](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/305bbf73-eee4-4e0c-9c7d-627e00ed3665/hidePreviewBanner~/true)| 2025-05-05 | ❌ |\n|[Simon Burn](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/c3aab1a2-0733-438d-bc14-90dc8f6d876d/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Sophia Rodriguez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d5d9f31f-c8d7-4b6c-bfca-b25b1cd4c1f1/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Tegra Núnez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/25e54254-3719-4c07-a880-3aee6bc60876/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Tracy yu](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/80153e0b-dcce-42de-9df6-59a3fc89479b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true)| 2025-02-04 | ❌ |\n|[Unlicensed User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7804b01c-1223-4045-a393-43171298fa6b/hidePreviewBanner~/true)| Unknown | ❌ |\n|[usernonick](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/b531f68f-8d01-467b-9db6-a57438b0e8af/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Wilna Rossouw](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/62cd4528-8e5d-4789-84f6-8b33d0af5ca7/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Yakup Meredow](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/767bcbda-28a0-4e5f-841d-e918c5a1c229/hidePreviewBanner~/true)| Unknown | ❌ |\n|[Alex Wilber](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f10bc459-0bcf-49d0-8f86-4553b8f015b8/hidePreviewBanner~/true)| 2025-06-28 | ✅ |\n|[Diego Siciliani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/cdfa577c-972f-4399-98aa-1ec4be7fa6d1/hidePreviewBanner~/true)| 2025-06-28 | ✅ |\n|[Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true)| 2025-07-15 | ✅ |\n|[Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true)| 2025-07-09 | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| 2025-07-21 | ✅ |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Failed",
      "TestRisk": "Medium",
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they’re legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21770",
      "TestCategory": "Access control",
      "TestTitle": "Inactive applications don’t have highly privileged Microsoft Graph API permissions",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "High",
      "TestResult": "\nInactive Application(s) with high privileges were found\n\n\n## Apps with privileged Graph permissions\n\n| | Name | Risk | Delegate Permission | Application Permission | App owner tenant | Last sign in|\n| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n| ❌ | [Graph Explorer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f8f300a-870a-46ff-bdab-934e1436920d/appId/d3ce4cf8-6810-442d-b42e-375e14710095) | High | User.Read, Directory.AccessAsUser.All |  |  | Unknown | \n| ❌ | [Modern Workplace Concierge](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad1c51e8-f8a8-4bf2-ac09-a3a20cba5fa5/appId/c65c4011-1b90-4ec9-b5e9-1ee17786ad84) | High | openid, profile, RoleManagement.Read.Directory, Application.Read.All, User.ReadBasic.All, Group.ReadWrite.All, DeviceManagementRBAC.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, Policy.Read.All, User.Read, DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All |  |  | Unknown | \n| ❌ | [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bac0ba57-1876-448e-96bf-6f0481c99fda/appId/fef811e1-2354-43b0-961b-248fe15e737d) | High | User.Read, Directory.Read.All |  |  | Unknown | \n| ❌ | [Azure AD Assessment (Test)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d4cf4286-0fbe-424d-b4f2-65aa2c568631/appId/c62a9fcb-53bf-446e-8063-ea6e2bfcc023) | High | AuditLog.Read.All, Directory.AccessAsUser.All, Directory.ReadWrite.All, Group.ReadWrite.All, IdentityProvider.ReadWrite.All, Policy.ReadWrite.TrustFramework, PrivilegedAccess.ReadWrite.AzureAD, PrivilegedAccess.ReadWrite.AzureResources, TrustFrameworkKeySet.ReadWrite.All, User.Invite.All, offline_access, openid, profile |  |  | Unknown | \n| ❌ | [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f79df990-9ad2-4142-b5fd-8945ff334da3/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | High | User.Read | Directory.ReadWrite.All |  | Unknown | \n| ❌ | [Trello](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3d6c91cf-d48f-4272-ac4c-9f989bbec779/appId/d77611ee-5051-4383-9af3-5ba3627306a7) | High |  | Application.Read.All |  | Unknown | \n| ❌ | [test public client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5e80ea33-31fa-49fd-9a94-61894bd1a6c9/appId/79a0c604-f215-4c52-8fbe-641d08aa7937) | High |  | User.Read.All |  | Unknown | \n| ❌ | [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6bf7c616-88e8-4f7c-bdad-452e561fa777/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | High |  | User.ReadWrite.All |  | Unknown | \n| ❌ | [Windows Virtual Desktop AME](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8369f33c-da25-4a8a-866d-b0145e29ef29/appId/5a0aa725-4958-4b0c-80a9-34562e23f3b7) | High |  | Directory.Read.All, User.Read.All |  | Unknown | \n| ❌ | [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6d2e8d37-82b8-41e7-aa95-443a7401e8b8/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | High | User.Read | User.ReadWrite.All, User.Read.All, Sites.FullControl.All, TermStore.Read.All |  | Unknown | \n| ❌ | [Microsoft Sample Data Packs](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/63e1f0d4-bc2c-497a-bfe2-9eb4c8c2600e/appId/a1cffbc6-1cb3-44e4-a1d2-cee9cce700f1) | High | Files.ReadWrite, User.ReadWrite | Calendars.ReadWrite.All, Mail.ReadWrite, User.ReadWrite.All, MailboxSettings.ReadWrite, Sites.ReadWrite.All, Calendars.ReadWrite, Mail.Send, Contacts.ReadWrite, Sites.Manage.All, Directory.ReadWrite.All, Files.ReadWrite.All, Group.ReadWrite.All, Application.ReadWrite.OwnedBy, Sites.FullControl.All |  | Unknown | \n| ❌ | [Reset Viral Users Redemption Status](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3a8785da-9965-473f-a97c-25fefdc39fee/appId/cc7b0696-1956-408b-876a-ad6bf2b9890b) | High | User.Read, User.Invite.All, User.ReadWrite.All, Directory.ReadWrite.All, offline_access, profile, openid |  |  | Unknown | \n| ❌ | [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/35cbeecb-be21-4596-9869-0157d84f2d67/appId/c823a25d-fe94-494c-91f6-c7d51bf2df82) | High | User.Read | Sites.FullControl.All |  | Unknown | \n| ✅ | [Atlassian - Jira](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2425e515-5720-4071-9fae-fd50f153c0aa/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c) | Unranked | User.Read |  |  | 2022-07-13 | \n| ✅ | [AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/77198970-f1eb-4574-9a1a-6af175a283af/appId/2e311a1d-f5c0-41c6-b866-77af3289871e) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-02-06 | \n| ✅ | [Microsoft Assessment React](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0a8b4459-b0c2-4cb8-baeb-c4c5a6a8f14b/appId/c4b110d7-6f1d-473d-aa9e-6e74b8b8bd4b) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-02-25 | \n| ✅ | [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/043dd83b-94ce-4d12-b54b-45d77979f05a/appId/0b75bb7b-d365-4c29-92ea-e2799d2a3fce) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-03-11 | \n| ✅ | [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/30aa6cd2-1aab-42fd-a235-0521713f4532/appId/afe793df-19e0-455a-8403-2e863379bfaa) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-03-11 | \n| ✅ | [My Doc Gen](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a445d652-f72d-4a88-9493-79d3c3c23d1b/appId/e580347d-d0aa-4aa1-9113-5daa0bb1c805) | High | User.Read, openid, profile, offline_access, Directory.Read.All, Policy.Read.All, Agreement.Read.All, CrossTenantInformation.ReadBasic.All |  |  | 2023-03-17 | \n| ✅ | [graph-developer-proxy-samples](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e6570bb8-fdea-4329-82e2-2809d8fb67a7/appId/3658d9e9-dc87-4345-b59b-184febcf6781) | Unranked | User.Read.All, Presence.Read.All |  |  | 2023-04-20 | \n| ✅ | [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/aa64efdb-2d05-4c81-a9e5-80294bf0afac/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) | High | Policy.Read.All, User.Read, Directory.ReadWrite.All, Mail.ReadWrite | Mail.ReadWrite, Directory.ReadWrite.All |  | 2023-04-20 | \n| ✅ | [Canva](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/37ae3acb-5850-49e8-a0f8-cb06f5a77417/appId/2c0bebe0-bdb3-4909-8955-7ef311f0db22) | Unranked | email, openid, profile, User.Read |  |  | 2023-04-27 | \n| ✅ | [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b66231c2-9568-46f1-b61e-c5f8fd9edee4/appId/50827722-4f53-48ba-ae58-db63bb53626b) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  |  | 2023-07-05 | \n| ✅ | [MyTokenTestApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/60923f18-748f-42bb-a0b2-ee60d44e17fc/appId/6a846cb7-35ad-41b2-b10a-0c5decde9855) | Unranked | profile, openid |  |  | 2023-07-05 | \n| ✅ | [Microsoft Graph PowerShell - Used by Team Incredibles](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e67821d9-a20b-43ef-9c34-76a321643b4f/appId/2935f660-810c-41ff-b9ad-168cc649e36f) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-08-15 | \n| ✅ | [MyZt](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/716038b1-2811-40fc-8622-93e093890af0/appId/eee51d92-0bb5-4467-be6a-8f24ef677e4d) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, DeviceManagementServiceConfig.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementApps.Read.All, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, PrivilegedEligibilitySchedule.Read.AzureADGroup, openid, profile, offline_access |  |  | 2023-09-01 | \n| ✅ | [MyZtA\\[\\[](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d2a2a09d-7562-45fc-a950-36fedfb790f8/appId/d159fcf5-a613-435b-8195-8add3cdf4bff) | High | RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, Policy.Read.All, Agreement.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, User.Read, Directory.Read.All, PrivilegedEligibilitySchedule.Read.AzureADGroup, CrossTenantInformation.ReadBasic.All |  |  | 2023-09-05 | \n| ✅ | [idPowerToys - Release](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4654e05d-9f59-4925-807c-8eb2306e1cb1/appId/904e4864-f3c3-4d2f-ace2-c37a4ed55145) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  |  | 2023-10-24 | \n| ✅ | [Azure AD Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6c74be7f-bcc9-4541-bfe1-f113b90b0497/appId/68bc31c0-f891-4f4c-9309-c6104f7be41b) | High | Organization.Read.All, RoleManagement.Read.Directory, Application.Read.All, User.Read.All, Group.Read.All, Policy.Read.All, Directory.Read.All, SecurityEvents.Read.All, UserAuthenticationMethod.Read.All, AuditLog.Read.All, Reports.Read.All, openid, offline_access, profile |  |  | 2023-10-27 | \n| ✅ | [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/666a58ef-c3e5-4efc-828a-2ab3c0120677/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | High | User.Read | Sites.Read.All, Sites.Read.All |  | 2023-11-17 | \n| ✅ | [CachingSampleApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/59187561-8df5-4792-b3a4-f6ca8b54bfc7/appId/3d6835ff-f7f4-4a83-adb5-67ccdd934717) | Unranked | User.Read, openid, profile, offline_access |  |  | 2024-01-23 | \n| ✅ | [EAM Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24b12ae7-4648-4aae-b00c-6349a565d24c/appId/e6e0be31-7040-4084-ac44-600b67661f2c) | Unranked | profile, openid |  |  | 2024-01-30 | \n| ✅ | [elapora-Maester-54d3ea01-5a07-45d0-8d69-e5f5b0b20098](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4faa0456-5ecb-49f3-bb9a-2dbe516e939a/appId/a8c184ae-8ddf-41f3-8881-c090b43c385f) | High |  | Directory.Read.All, Policy.Read.All, Mail.Send, DirectoryRecommendations.Read.All, Reports.Read.All |  | 2024-05-11 | \n| ✅ | [Azure Static Web Apps](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6b1f4a00-db4e-43ae-b62b-2286d4fcc4ea/appId/d414ee2d-73e5-4e5b-bb16-03ef55fea597) | Unranked | openid, profile, email |  |  | 2024-05-27 | \n| ✅ | [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e31cd01e-afaf-4cc3-8d15-d3f9f7eb61e8/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) | High |  | Reports.Read.All, Mail.Send, Directory.Read.All, Policy.Read.All |  | 2024-06-09 | \n| ✅ | [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d54232da-de3b-4874-aef2-5203dbd7342a/appId/d99dd249-6ab3-4e92-be40-81af11658359) | High | User.Read | DirectoryRecommendations.Read.All, PrivilegedAccess.Read.AzureAD, Reports.Read.All, Mail.Send, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All |  | 2024-06-09 | \n| ✅ | [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/89bd9c7a-0c81-4a0a-9153-ff7cd0b81352/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) | High |  | GroupMember.Read.All, User.Read.All |  | 2024-09-10 | \n| ✅ | [FIDO2-passkeys-MFA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1aa7e155-cbf8-4970-8458-05a0c7a2d1a5/appId/4fabcfc0-5c44-45a1-8c80-8537f0625949) | Unranked | profile, openid |  |  | 2024-09-25 | \n| ✅ | [Graph PS - Zero Trust Workshop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f6e8dfdd-4c84-441f-ae6e-f2f51fd20699/appId/a9632ced-c276-4c2b-9288-3a34b755eaa9) | High | AuditLog.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, UserAuthenticationMethod.Read.All, openid, profile, offline_access |  |  | 2024-11-25 | \n| ✅ | [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e9fca357-cccd-4ec4-840f-7482f6f02818/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) | High |  | User.Read.All |  | 2024-12-09 | \n| ✅ | [idpowerelectron](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cb64f850-a076-42d5-8dd8-cfd67d9e67f1/appId/909fff82-5b0a-4ce5-b66d-db58ee1a925d) | Unranked | openid, profile, offline_access |  |  | 2025-02-15 | \n| ✅ | [idPowerToys for Desktop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24cc58d8-2844-4974-b7cd-21c8a470e6bb/appId/520aa3af-bd78-4631-8f87-d48d356940ed) | High | Directory.Read.All, Policy.Read.All, Agreement.Read.All, CrossTenantInformation.ReadBasic.All, openid, profile, offline_access |  |  | 2025-02-16 | \n| ✅ | [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3dde25cc-223f-4a16-8e8f-6695940b9680/appId/e7dfcbb6-fe86-44a2-b512-8d361dcc3d30) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, DeviceManagementServiceConfig.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementApps.Read.All, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, PrivilegedEligibilitySchedule.Read.AzureADGroup, openid, profile, offline_access |  |  | 2025-04-23 | \n| ✅ | [Maester DevOps Account - GitHub](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ce3af345-b0e0-4b15-808c-937d825bcf03/appId/f050a85f-390b-4d43-85a0-2196b706bfd6) | High |  | DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleManagement.Read.All, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, Mail.Send, Policy.Read.ConditionalAccess, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All |  | 2025-05-06 | \n| ✅ | [entraChatAppMultiTenant](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/855a57ff-88a6-4ad0-85d7-4f46d742730e/appId/5e00b345-a805-42a0-9caa-7d6cb761c668) | High | User.Read, openid, profile, offline_access, APIConnectors.Read.All, Application.ReadWrite.All, Policy.ReadWrite.AuthenticationFlows, Policy.Read.All, EventListener.ReadWrite.All, Policy.ReadWrite.AuthenticationMethod, Group.Read.All, AuditLog.Read.All, Policy.ReadWrite.ConditionalAccess, IdentityUserFlow.Read.All, Policy.ReadWrite.TrustFramework, TrustFrameworkKeySet.Read.All, Directory.ReadWrite.All |  |  | 2025-05-08 | \n| ✅ | [Maester DevOps Account - New GitHub Action](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7c1885fd-fdf8-413a-86a6-f8867914272f/appId/143cb1b1-81af-4999-a292-a8c537601119) | High | User.Read | DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All, Policy.Read.ConditionalAccess, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All |  | 2025-05-10 | \n| ✅ | [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad36b6e2-273d-4652-a505-8481f096e513/appId/6ce0484b-2ae6-4458-b2b9-b3369f42fd6f) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  |  | 2025-05-30 | \n| ✅ | [Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/552daa69-8057-4684-8c93-2c41963aff01/appId/f864cc86-0f4f-4861-9583-2580817e4f88) | Unranked | openid, profile |  |  | 2025-06-30 | \n| ✅ | [Maester Automation App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e3972142-1d36-4e7d-a777-ecd64619fcab/appId/55635484-743e-42e2-a78e-6bc15050ebde) | High | User.Read | Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, DeviceManagementManagedDevices.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, Mail.Send, DeviceManagementConfiguration.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All |  | 2025-07-12 | \n| ✅ | [Lokka](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1abc3899-a5df-40ab-8aa7-95d31edd4c01/appId/f581405a-9e57-4e81-91f1-40cd62f7595e) | High |  | Mail.Send, DeviceManagementConfiguration.ReadWrite.All, DirectoryRecommendations.Read.All, Policy.ReadWrite.Authorization, PrivilegedAccess.Read.AzureAD, Reports.Read.All, PrivilegedAccess.Read.AzureADGroup, IdentityRiskEvent.Read.All, Policy.Read.All, User.Read.All, Mail.Read, Directory.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, UserAuthenticationMethod.Read.All |  | 2025-07-18 | \n| ✅ | [Message Center](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/158f6ef9-a65d-45f2-bdf0-b0a1db70ebd4/appId/83f76a08-fa60-48e6-9cb5-fd8ced5ae314) | Medium | User.Read | ServiceMessage.Read.All |  | 2025-07-20 | \n| ✅ | [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7c32eaee-ff26-4435-be3d-b4ced08f9edc/appId/303774c1-3c6f-4dfd-8505-f24e82f9212a) | High | User.Read | Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All |  | 2025-07-21 | \n| ✅ | [entra-docs-email github DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7a94aec7-a5e3-48dd-b20f-3db74d689434/appId/ae06b71a-a0aa-4211-b846-fd74f25ccd45) | High | User.Read | Mail.Send |  | 2025-07-21 | \n| ✅ | [GitHub Actions App for Microsoft Info script](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/852b4218-67d2-4046-a9a6-f8b47430ccdf/appId/38535360-9f3e-4b1e-a41e-b4af46afcb0c) | High |  | Application.Read.All |  | 2025-07-22 | \n| ✅ | [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a15dc834-08ce-4fd8-85de-3729fff8e34f/appId/d36fe320-bc28-40c8-a141-a512d65d112c) | High | User.Read | Application.Read.All |  | 2025-07-22 | \n| ✅ | [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/427b14ca-13b3-4911-b67e-9ff626614781/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) | Medium |  | ServiceMessage.Read.All |  | 2025-07-22 | \n| ✅ | [Lokka-2-interactive](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/794b2542-39aa-433c-90c6-6ab5df851ffc/appId/e6ea9510-0e81-465a-ae7b-efaff41bd719) | Unranked | User.Read, User.Read.All |  |  | Unknown | \n| ✅ | [Entry Kiosk](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/83adcc80-3a35-4fdc-9c5b-1f6b9061508e/appId/b903f17a-87b0-460b-9978-962c812e4f98) | Unranked | User.Read |  |  | Unknown | \n| ✅ | [Calendar Pro](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/36e156e4-4566-44a0-b05c-a112017086b5/appId/fb507a6d-2eaa-4f1f-b43a-140f388c4445) | Unranked | profile, offline_access, email, openid, User.Read, User.ReadBasic.All |  |  | Unknown | \n| ✅ | [WebApplication4](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5bc56e47-7a8a-4e71-b25f-8c4e373f40a6/appId/b2d1f868-27ee-4ecd-ae81-0ee96b028605) | Unranked | User.Read |  |  | Unknown | \n| ✅ | [Contoso Access Verifier](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/41d3b041-9859-4830-8feb-72ffd7afad65/appId/a6af3433-bc44-4d27-9b35-81d10fd51315) | Unranked | openid, profile, User.Read |  |  | Unknown | \n| ✅ | [SharePoint On-Prem App Proxy](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/53c7bdb1-cae2-43b0-9e2e-d8605395ceec/appId/19a70df3-cddf-48c7-be44-97b25b9857f1) | Unranked | User.Read |  |  | Unknown | \n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Failed",
      "TestRisk": "Medium",
      "TestDescription": "Certificates, if not securely stored, can be extracted and exploited by attackers, leading to unauthorized access. Long-lived certificates are more likely to be exposed over time. Credentials, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the privileges of the application.\n\n**Remediation action**\n\n- [Define certificate based application configuration](https://devblogs.microsoft.com/identity/app-management-policy/)\n- [Define trusted certificate authorities for apps and service principals in the tenant](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Define application management policies](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Enforce secret and certificate standards](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/tutorial-enforce-secret-standards?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create a least-privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21773",
      "TestCategory": "Application management",
      "TestTitle": "Applications don't have certificates with expiration longer than 180 days",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Low",
      "TestResult": "\nFound 6 applications and 3 service principals with certificates longer than 180 days\n\n\n## Applications with long-lived credentials\n\n| Application | Certificate expiry |\n| :--- | :--- |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 2125-03-03 |\n\n\n## Service principals with long-lived credentials\n\n| Service principal | App owner tenant | Certificate expiry |\n| :--- | :--- | :--- |\n| [Madura AWS Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/39861745-eda1-4e3c-8358-d0ba931f12bb/appId/d3a04f85-a969-436b-bf4d-eae0a91efb4c/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-07-01 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2027-02-15 |\n| [claimtest](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/f7b07e81-79a0-4e51-b93a-169b8f2f6c4e/appId/f816d68b-aec7-4eab-9ebc-bd23b0d04e35/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 2028-02-26 |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestStatus": "Failed",
      "TestRisk": "Medium",
      "TestDescription": "Microsoft Entra recommendations give organizations opportunities to implement best practices and optimize their security posture. Not acting on these items might result in an increased attack surface area, suboptimal operations, or poor user experience.\n\n**Remediation action**\n\n- [Address all active or postponed recommendations in the Microsoft Entra admin center](https://learn.microsoft.com/entra/identity/monitoring-health/overview-recommendations?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-does-it-work)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21866",
      "TestCategory": "Monitoring",
      "TestTitle": "All Microsoft Entra recommendations are addressed",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nFound 9 unaddressed Entra recommendations.\n\n\n## Unaddressed Entra recommendations\n\n| Display Name | Status | Insights | Priority |\n| :--- | :--- | :--- | :--- |\n| Protect your tenant with Insider Risk condition in Conditional Access policy | active | You have 61 of 61 users that aren’t covered by the Insider Risk condition in a Conditional Access policy. | medium |\n| Protect all users with a user risk policy  | active | You have 2 of 61 users that don’t have a user risk policy enabled.  | high |\n| Protect all users with a sign-in risk policy | active | You have 61 of 61 users that don't have a sign-in risk policy turned on. | high |\n| Enable password hash sync if hybrid | active | You have disabled password hash sync. | medium |\n| Ensure all users can complete multifactor authentication | active | You have 46 of 61 users that aren’t registered with MFA.  | high |\n| Enable policy to block legacy authentication | active | You have 2 of 61 users that don’t have legacy authentication blocked.  | high |\n| Require multifactor authentication for administrative roles | active | You have 5 of 11 users with administrative roles that aren’t registered and protected with MFA. | high |\n| Remove unused credentials from applications | active | Your tenant has applications with credentials which have not been used in more than 30 days. | medium |\n| Remove unused applications | active | This recommendation will surface if your tenant has applications that have not been used for over 90 days. Applications that were created but never used, client applications which have not been issued a token or resource apps that have not been a target of a token request, will show under this recommendation. | medium |\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Accelerate response and remediation",
      "TestStatus": "Failed",
      "TestRisk": "Medium",
      "TestDescription": "Set up risk-based Conditional Access policies for workload identities based on risk policy in Microsoft Entra ID to make sure only trusted and verified workloads use sensitive resources. Without these policies, threat actors can compromise workload identities with minimal detection and perform further attacks. Without conditional controls to detect anomalous activity and other risks, there's no check against malicious operations like token forgery, access to sensitive resources, and disruption of workloads. The lack of automated containment mechanisms increases dwell time and affects the confidentiality, integrity, and availability of critical services.   \n\n**Remediation action**\nCreate a risk-based Conditional Access policy for workload identities.\n- [Create a risk-based Conditional Access policy](https://learn.microsoft.com/en-us/entra/identity/conditional-access/workload-identity?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-a-risk-based-conditional-access-policy)   \n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21883",
      "TestCategory": "Access control",
      "TestTitle": "Workload Identities are configured with risk-based policies",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestResult": "\nWorkload identities based on risk policy is not configured.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Failed",
      "TestRisk": "Medium",
      "TestDescription": "Letting group owners consent to applications in Microsoft Entra ID creates a lateral escalation path that lets threat actors persist and steal data without admin credentials. If an attacker compromises a group owner account, they can register or use a malicious application and consent to high-privilege Graph API permissions scoped to the group. Attackers can potentially read all Teams messages, access SharePoint files, or manage group membership. This consent action creates a long-lived application identity with delegated or application permissions. The attacker maintains persistence with OAuth tokens, steals sensitive data from team channels and files, and impersonates users through messaging or email permissions. Without centralized enforcement of app consent policies, security teams lose visibility, and malicious applications spread under the radar, enabling multi-stage attacks across collaboration platforms.\n\n**Remediation action**\nConfigure preapproval of Resource-Specific Consent (RSC) permissions.\n- [Preapproval of RSC permissions](https://learn.microsoft.com/microsoftteams/platform/graph-api/rsc/preapproval-instruction-docs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Medium",
      "TestId": "21810",
      "TestCategory": "Access control",
      "TestTitle": "Resource-specific consent is restricted",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nResource-Specific Consent is not restricted.\n\nThe current state is ManagedByMicrosoft.\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect networks",
      "TestStatus": "Passed",
      "TestRisk": "Medium",
      "TestDescription": "Without named locations configured in Microsoft Entra ID, threat actors can exploit the absence of location intelligence to conduct attacks without triggering location-based risk detections or security controls. When organizations fail to define named locations for trusted networks, branch offices, and known geographic regions, Microsoft Entra ID Protection can't assess location-based risk signals. Not having these policies in place can lead to increased false positives that create alert fatigue and potentially mask genuine threats. This configuration gap prevents the system from distinguishing between legitimate and illegitimate locations. For example, legitimate sign-ins from corporate networks and suspicious authentication attempts from high-risk locations (anonymous proxy networks, Tor exit nodes, or regions where the organization has no business presence). Threat actors can use this uncertainty to conduct credential stuffing attacks, password spray campaigns, and initial access attempts from malicious infrastructure without triggering location-based detections that would normally flag such activity as suspicious. Organizations can also lose the ability to implement adaptive security policies that could automatically apply stricter authentication requirements or block access entirely from untrusted geographic regions. Threat actors can maintain persistence and conduct lateral movement from any global location without encountering location-based security barriers, which should serve as an extra layer of defense against unauthorized access attempts.\n\n**Remediation action**\n\n- [Configure named locations to define trusted IP ranges and geographic regions for enhanced location-based risk detection and Conditional Access policy enforcement](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-assignment-network?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21865",
      "TestCategory": "Application management",
      "TestTitle": "Named locations are configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\n✅ **Pass**: Trusted named locations are configured in Microsoft Entra ID to support location-based security controls.\n\n\n## All named locations\n\n5 [named locations](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/NamedLocations/menuId//fromNav/) found.\n\n| Name | Location type | Trusted | Creation date | Modified date |\n| :--- | :------------ | :------ | :------------ | :------------ |\n| Melbourne Branch | IP-based | Yes | Unknown | Unknown |\n| Boston Head Office | IP-based | Yes | Unknown | Unknown |\n| Untrusted Locations | Country-based | No | Unknown | Unknown |\n| Corporate IPs | IP-based | Yes | Unknown | Unknown |\n| Merill home | IP-based | Yes | 2025-04-16 | 2025-04-16 |\n\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Passed",
      "TestRisk": "Medium",
      "TestDescription": "If nonprivileged users can create applications and service principals, these accounts might be misconfigured or be granted more permissions than necessary, creating new vectors for attackers to gain initial access. Attackers can exploit these accounts to establish valid credentials in the environment and bypass some security controls.\n\nIf these nonprivileged accounts are mistakenly granted elevated application owner permissions, attackers can use them to move from a lower level of access to a more privileged level of access. Attackers who compromise nonprivileged accounts might add their own credentials or change the permissions associated with the applications created by the nonprivileged users to ensure they can continue to access the environment undetected.\n\nAttackers can use service principals to blend in with legitimate system processes and activities. Because service principals often perform automated tasks, malicious activities carried out under these accounts might not be flagged as suspicious.\n\n**Remediation action**\n\n- [Block nonprivileged users from creating apps](https://learn.microsoft.com/entra/identity/role-based-access-control/delegate-app-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21807",
      "TestCategory": "Application management",
      "TestTitle": "Creating new applications and service principals is restricted to privileged users",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Low",
      "TestResult": "\nTenant is configured to prevent users from registering applications.\n\n**[Users can register applications](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)** → **No** ✅\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Passed",
      "TestRisk": "Medium",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.  \n\nExternal accounts with permissions to read directory object permissions provide attackers with broader initial access if compromised. These accounts allow attackers to gather additional information from the directory for reconnaissance.\n\n**Remediation action**\n\n- [Restrict guest access to their own directory objects](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-user-access)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21792",
      "TestCategory": "External collaboration",
      "TestTitle": "Guests have restricted access to directory objects",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Medium",
      "TestResult": "\n✅ Validated guest user access is restricted.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Passed",
      "TestRisk": "Medium",
      "TestDescription": "Without sign-in context, threat actors can exploit authentication fatigue by flooding users with push notifications, increasing the chance that a user accidentally approves a malicious request. When users get generic push notifications without the application name or geographic location, they don't have the information they need to make informed approval decisions. This lack of context makes users vulnerable to social engineering attacks, especially when threat actors time their requests during periods of legitimate user activity. This vulnerability is especially dangerous when threat actors gain initial access through credential harvesting or password spraying attacks and then try to establish persistence by approving multifactor authentication (MFA) requests from unexpected applications or locations. Without contextual information, users can't detect unusual sign-in attempts, allowing threat actors to maintain access and escalate privileges by moving laterally through systems after bypassing the initial authentication barrier. Without application and location context, security teams also lose valuable telemetry for detecting suspicious authentication patterns that can indicate ongoing compromise or reconnaissance activities.   \n\n**Remediation action**\nGive users the context they need to make informed approval decisions. Configure Microsoft Authenticator notifications by setting the Authentication methods policy to include the application name and geographic location.  \n- [Use additional context in Authenticator notifications - Authentication methods policy](https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-additional-context?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21802",
      "TestCategory": "Access control",
      "TestTitle": "Authenticator app shows sign-in context",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nMicrosoft Authenticator shows application name and geographic location in push notifications.\n\n\n## Microsoft Authenticator settings\n\n\nFeature Settings:\n\n✅ **Application Name**\n- Status: Enabled\n- Include Target: All users\n- Exclude Target: No exclusions\n\n✅ **Geographic Location**\n- Status: Enabled\n- Include Target: All users\n- Exclude Target: No exclusions\n\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": null,
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Passed",
      "TestRisk": "Medium",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.  \n\nAllowing external users to onboard other external users increases the risk of unauthorized access. If an attacker compromises an external user's account, they can use it to create more external accounts, multiplying their access points and making it harder to detect the intrusion.\n\n**Remediation action**\n\n- [Restrict who can invite guests to only users assigned to specific admin roles](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-invite-settings)\n",
      "TestSkipped": "",
      "TestImplementationCost": "Low",
      "TestId": "21791",
      "TestCategory": "External collaboration",
      "TestTitle": "Guests can’t invite other guests",
      "TestTags": [
        "ExternalCollaboration"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nTenant restricts who can invite guests.\n\n**Guest invite settings**\n\n  * Guest invite restrictions → Member users and users assigned to specific admin roles can invite guest users including guests with member permissions\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21899",
      "TestCategory": "Access control",
      "TestTitle": "All privileged role assignments have a recipient that can receive notifications",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21896",
      "TestCategory": "Access control",
      "TestTitle": "Service principals don't have certificates or credentials associated with them",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21878",
      "TestCategory": "Access control",
      "TestTitle": "All entitlement management policies have an expiration date",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21850",
      "TestCategory": "Access control",
      "TestTitle": "Smart lockout threshold isn't greater than 10",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21822",
      "TestCategory": "Access control",
      "TestTitle": "Guest access is limited to approved tenants",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21855",
      "TestCategory": "Access control",
      "TestTitle": "Privileged roles have access reviews",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "When guest identities remain active but unused for extended periods, threat actors can exploit these dormant accounts as entry vectors into the organization. Inactive guest accounts represent a significant attack surface because they often maintain persistent access permissions to resources, applications, and data while remaining unmonitored by security teams. Threat actors frequently target these accounts through credential stuffing, password spraying, or by compromising the guest's home organization to gain lateral access. Once an inactive guest account is compromised, attackers can utilize existing access grants to:\n- Move laterally within the tenant\n- Escalate privileges through group memberships or application permissions\n- Establish persistence through techniques like creating more service principals or modifying existing permissions\n\nThe prolonged dormancy of these accounts provides attackers with extended dwell time to conduct reconnaissance, exfiltrate sensitive data, and establish backdoors without detection, as organizations typically focus monitoring efforts on active internal users rather than external guest accounts.\n\n**Remediation action**\n- [Monitor and clean up stale guest accounts](https://learn.microsoft.com/en-us/entra/identity/users/clean-up-stale-guest-accounts?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21858",
      "TestCategory": "External collaboration",
      "TestTitle": "Inactive guest identities are disabled or removed from the tenant",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your organization. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.\n\nAttackers might gain access with external user accounts, if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. They might also gain access by exploiting the vulnerabilities of weaker MFA methods like SMS and phone calls using social engineering techniques, such as SIM swapping or phishing, to intercept the authentication codes.\n\nOnce an attacker gains access to an account without MFA or a session with weak MFA methods, they might attempt to manipulate MFA settings (for example, registering attacker controlled methods) to establish persistence to plan and execute further attacks based on the privileges of the compromised accounts.\n\n**Remediation action**\n\n- [Deploy Conditional Access policies to enforce authentication strength for guests](https://learn.microsoft.com/entra/identity/conditional-access/policy-guests-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- For organizations with a closer business relationship and vetting on their MFA practices, consider deploying cross-tenant access settings to accept the MFA claim.\n   - [Configure B2B collaboration cross-tenant access settings](https://learn.microsoft.com/entra/external-id/cross-tenant-access-settings-b2b-collaboration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-change-inbound-trust-settings-for-mfa-and-device-claims)\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21851",
      "TestCategory": "External collaboration",
      "TestTitle": "Guest access is protected by strong authentication methods",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21849",
      "TestCategory": "Access control",
      "TestTitle": "Smart lockout duration is set to a minimum of 60",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21941",
      "TestCategory": "Access control",
      "TestTitle": "Token protection policies are configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21778",
      "TestCategory": "Application management",
      "TestTitle": "Line-of-business and partner apps use MSAL",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21898",
      "TestCategory": "Access control",
      "TestTitle": "All supported access lifecycle resources are managed with entitlement management packages",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21859",
      "TestCategory": "Access control",
      "TestTitle": "GDAP admin least privilege",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21879",
      "TestCategory": "Access control",
      "TestTitle": "All entitlement management policies that apply to External users require approval",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "22072",
      "TestCategory": "Access control",
      "TestTitle": "Self-Service Password Reset does not use Q & A",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "Without configured domain allow/deny lists for external collaboration, organizations lack essential domain-level access controls that act as the frontline defense in their security model. Domain allow/deny lists operate at the tenant level and take precedence over Cross-Tenant Access Policies (XTAP), blocking invitations from domains on the deny list regardless of cross-tenant access settings. While XTAP enables granular controls for specific trusted tenants, domain restrictions are critical for preventing invitations from unknown or unverified domains that haven't been explicitly allowed.\n\nWithout these restrictions, internal users can invite external accounts from any domain—including potentially compromised or attacker-controlled domains. Threat actors can register domains that appear legitimate to conduct social engineering attacks, tricking users into sending collaboration invitations that circumvent XTAP's targeted protections. Once granted access, these external guest accounts can be used for reconnaissance, mapping internal resources, user relationships, and collaboration patterns.\n\nThese invited accounts provide persistent access that appears legitimate in audit logs and security monitoring systems. Attackers can maintain a long-term presence to collect data, access shared resources, documents, and applications configured for external collaboration, and potentially exfiltrate data through authorized channels without triggering alerts.\n\n**Remediation action**\n- [Configure domain-based allow or deny lists](https://learn.microsoft.com/en-us/entra/external-id/allow-deny-list?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#set-the-allow-or-blocklist-policy-in-the-portal)",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21874",
      "TestCategory": "External collaboration",
      "TestTitle": "Allow/Deny lists of domains to restrict external collaboration are configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21929",
      "TestCategory": "Access control",
      "TestTitle": "All entitlement management packages that apply to guests have expirations or access reviews configured in their assignment policies",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21892",
      "TestCategory": "Access control",
      "TestTitle": "All sign-in activity comes from managed devices",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21819",
      "TestCategory": "Privileged access",
      "TestTitle": "Activation alert for Global Administrator role assignments",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "Microsoft Entra seamless single sign-on (Seamless SSO) is a legacy authentication feature designed to provide passwordless access for domain-joined devices that are not hybrid Microsoft Entra ID joined. Seamless SSO relies on Kerberos authentication and is primarily beneficial for older operating systems like Windows 7 and Windows 8.1, which do not support Primary Refresh Tokens (PRT). If these legacy systems are no longer present in the environment, continuing to use Seamless SSO introduces unnecessary complexity and potential security exposure. Threat actors could exploit misconfigured or stale Kerberos tickets, or compromise the `AZUREADSSOACC` computer account in Active Directory, which holds the Kerberos decryption key used by Microsoft Entra ID. Once compromised, attackers could impersonate users, bypass modern authentication controls, and gain unauthorized access to cloud resources. Disabling Seamless SSO in environments where it is no longer needed reduces the attack surface and enforces the use of modern, token-based authentication mechanisms that offer stronger protections. \n\n**Remediation action**\n\n- [Review how Seamless SSO works](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sso-how-it-works?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Disable Seamless SSO](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sso-faq?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#how-can-i-disable-seamless-sso-)\n- [Clean up stale devices in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/devices/manage-stale-devices?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21985",
      "TestCategory": "Credential management",
      "TestTitle": "Turn off Seamless SSO if there is no usage",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21886",
      "TestCategory": "Access control",
      "TestTitle": "Applications that use Microsoft Entra for authentication and support provisioning are configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "When guest self-service sign-up is enabled, threat actors can exploit it to establish unauthorized access by creating legitimate guest accounts without requiring approval from authorized personnel. These accounts can be scoped to specific services to reduce detection and effectively bypass invitation-based controls that validate external user legitimacy.\n\nOnce created, self-provisioned guest accounts provide persistent access to organizational resources and applications. Threat actors can use them to conduct reconnaissance activities to map internal systems, identify sensitive data repositories, and plan further attack vectors. This persistence allows adversaries to maintain access across restarts, credential changes, and other interruptions, while the guest account itself offers a seemingly legitimate identity that might evade security monitoring focused on external threats.\n\nAdditionally, compromised guest identities can be used to establish credential persistence and potentially escalate privileges. Attackers can exploit trust relationships between guest accounts and internal resources, or use the guest account as a staging ground for lateral movement toward more privileged organizational assets.\n\n**Remediation action**\n- [Configure guest self-service sign-up With Microsoft Entra External ID](https://learn.microsoft.com/en-us/entra/external-id/external-collaboration-settings-configure?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#to-configure-guest-self-service-sign-up)",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21823",
      "TestCategory": "External collaboration",
      "TestTitle": "Guest self-service sign-up via user flow is disabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21779",
      "TestCategory": "Application management",
      "TestTitle": "Use recent versions of Microsoft Applications",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "Without restrictions preventing guest users from registering and owning applications, threat actors can exploit external user accounts to establish persistent backdoor access to organizational resources through application registrations that might evade traditional security monitoring. When guest users own applications, compromised guest accounts can be used to exploit guest-owned applications that might have broad permissions. This vulnerability enables threat actors to request access to sensitive organizational data such as emails, files, and user information without the same level of scrutiny for internal user-owned applications.\n\nThis attack vector is dangerous because guest-owned applications can be configured to request high-privilege permissions and, once granted consent, provide threat actors with legitimate OAuth tokens. Furthermore, guest-owned applications can serve as command and control infrastructure, so threat actors can maintain access even after the compromised guest account is detected and remediated. Application credentials and permissions might persist independently of the original guest user account, so threat actors can retain access. Guest-owned applications also complicate security auditing and governance efforts, as organizations might have limited visibility into the purpose and security posture of applications registered by external users. These hidden weaknesses in the application lifecycle management make it difficult to assess the true scope of data access granted to non-Microsoft entities through seemingly legitimate application registrations.\n\n**Remediation action**\n- Remove guest users as owners from applications and service principals, and implement controls to prevent future guest user application ownership.\n- [Restrict guest user access permissions](https://learn.microsoft.com/en-us/entra/identity/users/users-restrict-guest-permissions?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21868",
      "TestCategory": "External collaboration",
      "TestTitle": "Guests do not own apps in the tenant",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21876",
      "TestCategory": "Access control",
      "TestTitle": "Use PIM for Microsoft Entra privileged roles",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21983",
      "TestCategory": "Access control",
      "TestTitle": "No Active Medium priority Entra recommendations found",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21897",
      "TestCategory": "Access control",
      "TestTitle": "All app assignment and group membership is governed",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21821",
      "TestCategory": "Access control",
      "TestTitle": "Guest access is restricted",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21862",
      "TestCategory": "Access control",
      "TestTitle": "All risky workload identities are triaged",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21875",
      "TestCategory": "Access control",
      "TestTitle": "Tenant has all External organizations allowed to collaborate as Connected Organization",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "Guest accounts with extended sign-in sessions increase the risk surface area that threat actors can exploit. When guest sessions persist beyond necessary timeframes, threat actors often attempt to gain initial access through credential stuffing, password spraying, or social engineering attacks. Once they gain access, they can maintain unauthorized access for extended periods without reauthentication challenges. These compromised and extended sessions:\n\n- Allow unauthorized access to Microsoft Entra artifacts, enabling threat actors to identify sensitive resources and map organizational structures.\n- Allow threat actors to persist within the network by using legitimate authentication tokens, making detection more challenging as the activity appears as typical user behavior.\n- Provides threat actors with a longer window of time to escalate privileges through techniques like accessing shared resources, discovering more credentials, or exploiting trust relationships between systems.\n\nWithout proper session controls, threat actors can achieve lateral movement across the organization's infrastructure, accessing critical data and systems that extend far beyond the original guest account's intended scope of access. \n\n**Remediation action**\n- [Configure adaptive session lifetime policies](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-session-lifetime?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci) so sign-in frequency policies have shorter live sign-in sessions.",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21824",
      "TestCategory": "External collaboration",
      "TestTitle": "Guests don't have long lived sign-in sessions",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21854",
      "TestCategory": "Access control",
      "TestTitle": "Privileged roles aren't assigned to stale identities",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21789",
      "TestCategory": "Monitoring",
      "TestTitle": "Tenant creation events are triaged",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21857",
      "TestCategory": "Access control",
      "TestTitle": "Guest identities are lifecycle managed with access reviews",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21884",
      "TestCategory": "Access control",
      "TestTitle": "Workload identities based on known networks are configured",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "Legacy authentication protocols such as basic authentication for SMTP and IMAP don't support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This lack of protection makes accounts using these protocols vulnerable to password-based attacks, and provides attackers with a means to gain initial access using stolen or guessed credentials.\n\nWhen an attacker successfully gains unauthorized access to credentials, they can use them to access linked services, using the weak authentication method as an entry point. Attackers who gain access through legacy authentication might make changes to Microsoft Exchange, such as configuring mail forwarding rules or changing other settings, allowing them to maintain continued access to sensitive communications.\n\nLegacy authentication also provides attackers with a consistent method to reenter a system using compromised credentials without triggering security alerts or requiring reauthentication.\n\nFrom there, attackers can use legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement. Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.\n\n**Remediation action**\n\n- [Exchange protocols can be deactivated in Exchange](https://learn.microsoft.com/exchange/clients-and-mobile-in-exchange-online/disable-basic-authentication-in-exchange-online?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Legacy authentication protocols can be blocked with Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Sign-ins using legacy authentication workbook to help determine whether it's safe to turn off legacy authentication](https://learn.microsoft.com/entra/identity/monitoring-health/workbook-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21795",
      "TestCategory": "Monitoring",
      "TestTitle": "No legacy authentication sign-in activity",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Monitor and detect cyberthreats",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.\n\nAttackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.\n\n**Remediation action**\n\n- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policies to enforce authentication strength](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#authentication-methods-activity)\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21800",
      "TestCategory": "Monitoring",
      "TestTitle": "All user sign-in activity uses strong authentication methods",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21784",
      "TestCategory": "Access control",
      "TestTitle": "All user sign in activity uses phishing-resistant authentication methods",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect identities and secrets",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "When password expiration policies remain enabled, threat actors can exploit the predictable password rotation patterns that users typically follow when forced to change passwords regularly. Users frequently create weaker passwords by making minimal modifications to existing ones, such as incrementing numbers or adding sequential characters. Threat actors can easily anticipate and exploit these types of changes through credential stuffing attacks or targeted password spraying campaigns. These predictable patterns enable threat actors to establish persistence through:\n\n- Compromised credentials\n- Escalated privileges by targeting administrative accounts with weak rotated passwords\n- Maintaining long-term access by predicting future password variations\n\nResearch shows that users create weaker, more predictable passwords when they are forced to expire. These predictable passwords are easier for experienced attackers to crack, as they often make simple modifications to existing passwords rather than creating entirely new, strong passwords. Additionally, when users are required to frequently change passwords, they might resort to insecure practices such as writing down passwords or storing them in easily accessible locations, creating more attack vectors for threat actors to exploit during physical reconnaissance or social engineering campaigns. \n\n**Remediation action**\n\n- [Set the password expiration policy for your organization](https://learn.microsoft.com/microsoft-365/admin/manage/set-password-expiration-policy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n    - Sign in to the [Microsoft 365 admin center](https://admin.microsoft.com/). Go to **Settings** > **Org Settings** >** Security & Privacy** > **Password expiration policy**. Ensure the **Set passwords to never expire** setting is checked.\n- [Disable password expiration using Microsoft Graph](https://learn.microsoft.com/graph/api/domain-update?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- [Set individual user passwords to never expire using Microsoft Graph PowerShell](https://learn.microsoft.com/microsoft-365/admin/add-users/set-password-to-never-expire?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - `Update-MgUser -UserId <UserID> -PasswordPolicies DisablePasswordExpiration`",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21811",
      "TestCategory": "Credential management",
      "TestTitle": "Password expiration is disabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect tenants and isolate production systems",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "Inviting external guests is beneficial for organizational collaboration. However, in the absence of an assigned internal sponsor for each guest, these accounts might persist within the directory without clear accountability. This oversight creates a risk: threat actors could potentially compromise an unused or unmonitored guest account, and then establish an initial foothold within the tenant. Once granted access as an apparent \"legitimate\" user, an attacker might explore accessible resources and attempt privilege escalation, which could ultimately expose sensitive information or critical systems. An unmonitored guest account might therefore become the vector for unauthorized data access or a significant security breach. A typical attack sequence might use the following pattern, all achieved under the guise of a standard external collaborator:\n\n1. Initial access gained through compromised guest credentials\n1. Persistence due to a lack of oversight.\n1. Further escalation or lateral movement if the guest account possesses group memberships or elevated permissions.\n1. Execution of malicious objectives. \n\nMandating that every guest account is assigned to a sponsor directly mitigates this risk. Such a requirement ensures that each external user is linked to a responsible internal party who is expected to regularly monitor and attest to the guest's ongoing need for access. The sponsor feature within Microsoft Entra ID supports accountability by tracking the inviter and preventing the proliferation of \"orphaned\" guest accounts. When a sponsor manages the guest account lifecycle, such as removing access when collaboration concludes, the opportunity for threat actors to exploit neglected accounts is substantially reduced. This best practice is consistent with Microsoft’s guidance to require sponsorship for business guests as part of an effective guest access governance strategy. It strikes a balance between enabling collaboration and enforcing security, as it guarantees that each guest user's presence and permissions remain under ongoing internal oversight.\n\n**Remediation action**\n- For each guest user that has no sponsor, assign a sponsor in Microsoft Entra ID.\n    - [Add a sponsor to a guest user in the Microsoft Entra admin center](https://learn.microsoft.com/en-us/entra/external-id/b2b-sponsors?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n    - [Add a sponsor to a guest user using Microsoft Graph](https://learn.microsoft.com/graph/api/user-post-sponsors?view=graph-rest-1.0&preserve-view=true&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21877",
      "TestCategory": "Application management",
      "TestTitle": "All guests have a sponsor",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21882",
      "TestCategory": "Access control",
      "TestTitle": "No nested groups in PIM for groups",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21825",
      "TestCategory": "Access control",
      "TestTitle": "Privileged user sessions don't have long lived sign-in sessions",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21890",
      "TestCategory": "Access control",
      "TestTitle": "Require password reset notifications for user roles",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21831",
      "TestCategory": "Access control",
      "TestTitle": "Conditional Access protected actions are enabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestId": "21780",
      "TestCategory": "Application management",
      "TestTitle": "No usage of ADAL in the tenant",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": "Protect engineering systems",
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "When enterprise applications lack both explicit assignment requirements AND scoped provisioning controls, threat actors can exploit this dual weakness to gain unauthorized access to sensitive applications and data. The highest risk occurs when applications are configured with the default setting: \"Assignment required\" is set to \"No\" *and* provisioning isn't required or scoped. This dangerous combination allows threat actors who compromise any user account within the tenant to immediately access applications with broad user bases, expanding their attack surface and potential for lateral movement within the organization.\n\nWhile an application with open assignment but proper provisioning scoping (such as department-based filters or group membership requirements) maintains security controls through the provisioning layer, applications lacking both controls create unrestricted access pathways that threat actors can exploit. When applications provision accounts for all users without assignment restrictions, threat actors can abuse compromised accounts to conduct reconnaissance activities, enumerate sensitive data across multiple systems, or use the applications as staging points for further attacks against connected resources. This unrestricted access model is dangerous for applications that have elevated permissions or are connected to critical business systems. Threat actors can use any compromised user account to access sensitive information, modify data, or perform unauthorized actions that the application's permissions allow. The absence of both assignment controls and provisioning scoping also prevents organizations from implementing proper access governance. Without proper governance, it's difficult to track who has access to which applications, when access was granted, and whether access should be revoked based on role changes or employment status. Furthermore, applications with broad provisioning scopes can create cascading security risks where a single compromised account provides access to an entire ecosystem of connected applications and services.\n\n**Remediation action**\n- Evaluate business requirements to determine appropriate access control method. [Restrict a Microsoft Entra app to a set of users](https://learn.microsoft.com/en-us/entra/identity-platform/howto-restrict-your-app-to-a-set-of-users?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n- Configure enterprise applications to require assignment for sensitive applications. [Learn about the \"Assignment required\" enterprise application property](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/application-properties?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#assignment-required).\n- Implement scoped provisioning based on groups, departments, or attributes. [Create scoping filters](https://learn.microsoft.com/en-us/entra/identity/app-provisioning/define-conditional-rules-for-provisioning-user-accounts?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci#create-scoping-filters).",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21869",
      "TestCategory": "Application management",
      "TestTitle": "Enterprise applications must require explicit assignment or scoped provisioning",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestResult": "\nPlanned for future release.\n\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestId": "21887",
      "TestCategory": "Access control",
      "TestTitle": "All registered redirect URIs must have proper DNS records and ownerships",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21847",
      "TestCategory": "Access control",
      "TestTitle": "Password protection for on-premises is enabled",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    },
    {
      "SkippedReason": "UnderConstruction",
      "TestSfiPillar": null,
      "TestStatus": "Planned",
      "TestRisk": "Medium",
      "TestDescription": "...\n\n**Remediation action**\n\n",
      "TestSkipped": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestId": "21832",
      "TestCategory": "Access control",
      "TestTitle": "All groups in Conditional Access policies belong to a restricted management administrative unit",
      "TestTags": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestResult": "\nPlanned for future release.\n",
      "TestAppliesTo": [
        "Identity"
      ]
    }
  ],
  "TenantInfo": {
    "OverviewCaDevicesAllUsers": {
      "description": "Over the past 29 days, 0% of sign-ins were from compliant devices.",
      "nodes": [
        {
          "source": "User sign in",
          "value": 394,
          "target": "Unmanaged"
        },
        {
          "source": "User sign in",
          "value": 0,
          "target": "Managed"
        },
        {
          "source": "Managed",
          "value": 0,
          "target": "Non-compliant"
        },
        {
          "source": "Managed",
          "value": 0,
          "target": "Compliant"
        }
      ]
    },
    "OverviewAuthMethodsPrivilegedUsers": {
      "description": "Strongest authentication method registered by privileged users.",
      "nodes": [
        {
          "source": "Users",
          "value": 4,
          "target": "Single factor"
        },
        {
          "source": "Users",
          "value": 9,
          "target": "Phishable"
        },
        {
          "source": "Phishable",
          "value": 2,
          "target": "Phone"
        },
        {
          "source": "Phishable",
          "value": 7,
          "target": "Authenticator"
        },
        {
          "source": "Users",
          "value": 4,
          "target": "Phish resistant"
        },
        {
          "source": "Phish resistant",
          "value": 3,
          "target": "Passkey"
        },
        {
          "source": "Phish resistant",
          "value": 1,
          "target": "WHfB"
        }
      ]
    },
    "OverviewAuthMethodsAllUsers": {
      "description": "Strongest authentication method registered by all users.",
      "nodes": [
        {
          "source": "Users",
          "value": 43,
          "target": "Single factor"
        },
        {
          "source": "Users",
          "value": 23,
          "target": "Phishable"
        },
        {
          "source": "Phishable",
          "value": 7,
          "target": "Phone"
        },
        {
          "source": "Phishable",
          "value": 16,
          "target": "Authenticator"
        },
        {
          "source": "Users",
          "value": 6,
          "target": "Phish resistant"
        },
        {
          "source": "Phish resistant",
          "value": 4,
          "target": "Passkey"
        },
        {
          "source": "Phish resistant",
          "value": 2,
          "target": "WHfB"
        }
      ]
    },
    "OverviewCaMfaAllUsers": {
      "description": "Over the past 29 days, 39.6% of sign-ins were protected by conditional access policies enforcing multifactor.",
      "nodes": [
        {
          "source": "User sign in",
          "value": 238,
          "target": "No CA applied"
        },
        {
          "source": "User sign in",
          "value": 156,
          "target": "CA applied"
        },
        {
          "source": "CA applied",
          "value": 0,
          "target": "No MFA"
        },
        {
          "source": "CA applied",
          "value": 156,
          "target": "MFA"
        }
      ]
    }
  },
  "EndOfJson": "EndOfJson"
}
