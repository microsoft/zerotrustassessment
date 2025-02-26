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
  TestImplementationCost: string;
  SkippedReason: null;
  TestResult: string;
  TestSkipped: string;
  TestStatus: string;
  TestTags: string[];
  TestId: string;
  TestDescription: string;
}

export const reportData: ZeroTrustAssessmentReport = {
  "ExecutedAt": "2025-02-26T18:46:25.982408+11:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Entra.Chat",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "0.2.0",
  "LatestVersion": "0.2.0",
  "TestResultSummary": {
    "IdentityPassed": 4,
    "IdentityTotal": 13,
    "DevicesPassed": 0,
    "DevicesTotal": 0,
    "DataPassed": 0,
    "DataTotal": 0
  },
  "Tests": [
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21843",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Block legacy Microsoft Online PowerShell module"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21775",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Tenant app management policy is configured"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n\n",
      "TestDescription": "Legacy authentication protocols such as basic authentication for SMTP and IMAP don't support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This lack of protection makes accounts using these protocols vulnerable to password-based attacks, and provides attackers with a means to gain initial access using stolen or guessed credentials.\n\nWhen an attacker successfully gains unauthorized access to credentials, they can use them to access linked services, using the weak authentication method as an entry point. Attackers who gain access through legacy authentication might make changes to Microsoft Exchange, such as configuring mail forwarding rules or changing other settings, allowing them to maintain continued access to sensitive communications.\n\nLegacy authentication also provides attackers with a consistent method to reenter a system using compromised credentials without triggering security alerts or requiring reauthentication.\n\nFrom there, attackers can use legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement. Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.\n\n**Remediation action**\n\n- [Exchange protocols can be deactivated in Exchange](https://learn.microsoft.com/exchange/clients-and-mobile-in-exchange-online/disable-basic-authentication-in-exchange-online?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Legacy authentication protocols can be blocked with Conditional Access](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Sign-ins using legacy authentication workbook to help determine whether it's safe to turn off legacy authentication](https://learn.microsoft.com/entra/identity/monitoring-health/workbook-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21795",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestTitle": "No legacy authentication sign-in activity"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21797",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestTitle": "Restrict access to high risk users"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nFound 27 applications and 9 service principals with client secrets configured.\n\n\n## Applications with client secrets\n\n| Application | Secret expiry |\n| :--- | :--- |\n| [AppProxy Header Test](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/19a70df3-cddf-48c7-be44-97b25b9857f1) | 12/12/2025 |\n| [AppProxyDemoLocalhost](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c) | 02/17/2026 |\n| [AppRolePimAutomationTestParentAcc19Feb22](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | 08/19/2022 |\n| [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | 10/22/2021 |\n| [BlazorMultiDemo](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2e311a1d-f5c0-41c6-b866-77af3289871e) | 11/02/2024 |\n| [Cool New for Telstra](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d77611ee-5051-4383-9af3-5ba3627306a7) | 08/16/2022 |\n| [Entra.News Automation Script - Message Center](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/83f76a08-fa60-48e6-9cb5-fd8ced5ae314) | 02/17/2026 |\n| [Entry Kiosk](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b903f17a-87b0-460b-9978-962c812e4f98) | 11/25/2021 |\n| [Graph Filter](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/c94b2f6c-f4c2-4ab3-8d1a-6971b2c7e975) | 09/16/2024 |\n| [Graph PowerShell - Privileged Perms](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/c5338ce0-3e9e-4895-8f49-5e176836a348) | 05/15/2024 |\n| [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d36fe320-bc28-40c8-a141-a512d65d112c) | 02/09/2026 |\n| [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/fef811e1-2354-43b0-961b-248fe15e737d) | 02/11/2022 |\n| [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | 03/29/2022 |\n| [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) | 09/23/2024 |\n| [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) | 02/21/2124 |\n| [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) | 06/07/2025 |\n| [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | 03/29/2022 |\n| [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) | 10/16/2023 |\n| [RemixTest](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/d4588485-154e-4b32-935f-31ceaf993cdc) | 06/24/2024 |\n| [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | 05/15/2024 |\n| [WebApplication3](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/bcdb1ed5-9470-41e6-821b-1fc42ae94cfb) | 02/11/2022 |\n| [WebApplication3_20210211261232](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/ac49e193-bd5f-40fe-b4ff-e62136419388) | 02/11/2022 |\n| [WebApplication4](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/b2d1f868-27ee-4ecd-ae81-0ee96b028605) | 03/04/2022 |\n| [WingtipToys App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/56a89db1-6ed2-4171-88f6-b4f7597dbce3) | 11/27/2025 |\n| [aadgraphmggraph](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/24b66505-1142-452f-9472-2ecbb37deac1) | 11/26/2022 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/4f50c653-dae4-44e7-ae2e-a081cce1f830) | 02/25/2023 |\n| [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) | 03/09/2025 |\n\n\n## Service Principals with client secrets\n\n| Service principal | App owner tenant | Secret expiry |\n| :--- | :--- | :--- |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 10/26/2025 |\n| [Dropbox Business](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/f76d7d98-02ee-4e62-9345-36016a72e664/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/17/2024 |\n| [P2P Server](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/2af9f5c5-0ffc-4d1c-ba2e-72cf6382df06/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 11/06/2024 |\n| [SPO Version](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/2d6d9bf1-1f6e-48cf-bb02-31beec2f442e/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 11/17/2024 |\n| [Salesforce](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/1a2a1d4c-1d76-44ec-95f4-3ed5345423a9/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/10/2025 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 11/17/2025 |\n| [ServiceNow](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/ecbbb1c8-ef06-48c4-9211-9ffbfbc24b94/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/15/2024 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/15/2027 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId//appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 10/10/2025 |\n\n\n\n\n\n\n\n\n\n",
      "TestDescription": "Applications that use client secrets might store them in configuration files, hardcode them in scripts, or risk their exposure in other ways. The complexities of secret management make client secrets susceptible to leaks and attractive to attackers. Client secrets, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's client secret, they can escalate their privileges within the system, leading to broader access and control, depending on the permissions of the application.\n\nApplications and service principals that have permissions for Microsoft Graph APIs or other APIs have a higher risk because an attacker can potentially exploit these additional permissions.\n\n**Remediation action**\n\n- [Move applications away from shared secrets to managed identities and adopt more secure practices](https://learn.microsoft.com/entra/identity/enterprise-apps/migrate-applications-from-secrets?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci).\n   - Use managed identities for Azure resources\n   - Deploy Conditional Access policies for workload identities\n   - Implement secret scanning\n   - Deploy application authentication policies to enforce secure authentication practices\n   - Create a least-privileged custom role to rotate application credentials\n   - Ensure you have a process to triage and monitor applications\n",
      "TestTags": [
        "Application"
      ],
      "TestStatus": "Failed",
      "TestId": "21772",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Applications don't have secrets configured"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21779",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Use recent versions of Microsoft Applications"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21835",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Emergency account exists"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21895",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Application Certificate Credentials are managed using HSM"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21893",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Enable Microsoft Entra ID Protection policy to enforce multifactor authentication registration"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21891",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Require password reset notifications for administrator roles"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21983",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "No Active Medium priority Entra recommendations found"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21829",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestTitle": "Use cloud authentication"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21816",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All privileged role assignments are managed with PIM"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21806",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Secure the MFA registration (My Security Info) page"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21866",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All Microsoft Entra recommendations are addressed"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21777",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "App Instance Property Lock is configured for all multitenant applications"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21890",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Require password reset notifications for user roles"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21894",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All certificates Microsoft Entra Application Registrations and Service Principals must be issued by an approved certification authority"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21788",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Global Administrators don't have standing elevated access to all Azure subscriptions in the tenant"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21821",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Guest access is restricted"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nConditional Access to block legacy Authentication are configured and enabled.\n\n  - [Block legacy authentication](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/4086128c-3850-48ac-8962-e19a956828bd)\n  - [Block legacy authentication - Testing](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/bedecc1e-85c9-4d54-b885-cefe6bcc8763) (Report-only)\n\n\n\n\n\n\n\n\n",
      "TestDescription": "Legacy authentication protocols such as basic authentication for SMTP and IMAP don't support modern security features like multifactor authentication (MFA), which is crucial for protecting against unauthorized access. This lack of protection makes accounts using these protocols vulnerable to password-based attacks, and provides attackers with a means to gain initial access using stolen or guessed credentials.\n\nWhen an attacker successfully gains unauthorized access to credentials, they can use them to access linked services, using the weak authentication method as an entry point. Attackers who gain access through legacy authentication might make changes to Microsoft Exchange, such as configuring mail forwarding rules or changing other settings, allowing them to maintain continued access to sensitive communications.\n\nLegacy authentication also provides attackers with a consistent method to reenter a system using compromised credentials without triggering security alerts or requiring reauthentication.\n\nFrom there, attackers can use legacy protocols to access other systems that are accessible via the compromised account, facilitating lateral movement. Attackers using legacy protocols can blend in with legitimate user activities, making it difficult for security teams to distinguish between normal usage and malicious behavior.\n\n**Remediation action**\n\nDeploy the following Conditional Access policy:\n\n- [Block legacy authentication](https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "User",
        "Credential"
      ],
      "TestStatus": "Passed",
      "TestId": "21796",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Block legacy authentication policy is configured"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21840",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Security key attestation is enforced"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21833",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Directory Sync account credentials haven't been rotated recently"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21841",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Authenticator app report suspicious activity is enabled"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21854",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Privileged roles aren't assigned to stale identities"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21839",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Passkey authentication method enabled"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21778",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Line-of-business and partner apps use MSAL"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21842",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Block administrators from using SSPR"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21867",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All enterprise applications have owners"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21863",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All risky user sign ins are triaged"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "22072",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Self-Service Password Reset does not use Q & A"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21824",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Guests don't have long lived sign-in sessions"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21883",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Workload identities based on risk policies are configured"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21802",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Authenticator app shows sign-in context"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "22101",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "[CIAM] Disable ciamlogin endpoints when custom domain enabled"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21846",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Temporary access pass restricted to one-time use"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "22102",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "[CIAM] Enable custom domain"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21898",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "All supported access lifecycle resources are managed with entitlement management packages"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21804",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Weak authentication methods are disabled"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21830",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Highly privileged roles are only activated in a PAW/SAW device"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nFound 0 applications and 4 service principals with certificates longer than 180 days\n\n\n\n## Service principals with long-lived credentials\n\n| Service principal | App owner tenant | Certificate expiry |\n| :--- | :--- | :--- |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 10/26/2025 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 11/17/2025 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 02/15/2027 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) |  | 10/10/2025 |\n\n\n\n\n\n\n\n\n",
      "TestDescription": "Certificates, if not securely stored, can be extracted and exploited by attackers, leading to unauthorized access. Long-lived certificates are more likely to be exposed over time. Credentials, when exposed, provide attackers with the ability to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application's certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the privileges of the application.\n\n**Remediation action**\n\n- [Define certificate based application configuration](https://devblogs.microsoft.com/identity/app-management-policy/)\n- [Define trusted certificate authorities for apps and service principals in the teantnt](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Define application management policies](https://learn.microsoft.com/graph/api/resources/applicationauthenticationmethodpolicy?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Create a least-privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Application"
      ],
      "TestStatus": "Failed",
      "TestId": "21773",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Applications don't have certificates with expiration longer than 180 days"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21817",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Global Administrator role activation triggers an approval workflow"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21872",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Require multifactor authentication for device join and device registration using user action"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21879",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "All entitlement management policies that apply to external users require approval"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21837",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Limit the maximum number of devices per user to 10"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21825",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Privileged user sessions don't have long lived sign-in sessions"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21787",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Permissions to create new tenants is limited to the Tenant Creator role"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21869",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Enterprise applications must require explicit assignment or scoped provisioning"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21780",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "No usage of ADAL in the tenant"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21985",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Turn off Seamless SSO if there are is no usage"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21984",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "No Active low priority Entra recommendations found"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nTenant is configured to prevent users from registering applications.\n\n**[Users can register applications](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)** → **No** ✅\n\n\n\n\n\n\n\n",
      "TestDescription": "If nonprivileged users can create applications and service principals, these accounts might be misconfigured or be granted more permissions than necessary, creating new vectors for attackers to gain initial access. Attackers can exploit these accounts to establish valid credentials in the environment and bypass some security controls.\n\nIf these nonprivileged accounts are mistakenly granted elevated application owner permissions, attackers can use them to move from a lower level of access to a more privileged level of access. Attackers who compromise nonprivileged accounts might add their own credentials or change the permissions associated with the applications created by the nonprivileged users to ensure they can continue to access the environment undetected.\n\nAttackers can use service principals to blend in with legitimate system processes and activities. Because service principals often perform automated tasks, malicious activities carried out under these accounts might not be flagged as suspicious.\n\n**Remediation action**\n\n- [Block nonprivileged users from creating apps](https://learn.microsoft.com/entra/identity/role-based-access-control/delegate-app-roles?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Application"
      ],
      "TestStatus": "Passed",
      "TestId": "21807",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Creating new applications and service principles is restricted to privileged users"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21896",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Service principals don't have certificates or credentials associated with them"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nInactive Application(s) with high privileges were found\n\n\n## Apps with privileged Graph permissions\n\n| | Name | Risk | Delegate Permission | Application Permission | App owner tenant | Last sign in|\n| :--- | :--- | :--- | :--- | :--- | :--- | :--- |\n| ❌ | [Reset Viral Users Redemption Status](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3a8785da-9965-473f-a97c-25fefdc39fee/appId/cc7b0696-1956-408b-876a-ad6bf2b9890b) | High | User.Read, User.Invite.All, User.ReadWrite.All, Directory.ReadWrite.All, offline_access, profile, openid |  |  |  | \n| ❌ | [Microsoft Sample Data Packs](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/63e1f0d4-bc2c-497a-bfe2-9eb4c8c2600e/appId/a1cffbc6-1cb3-44e4-a1d2-cee9cce700f1) | High | Files.ReadWrite, User.ReadWrite | MailboxSettings.ReadWrite, Sites.ReadWrite.All, Mail.Send, Contacts.ReadWrite, Sites.Manage.All, Application.ReadWrite.OwnedBy, Calendars.ReadWrite, Calendars.ReadWrite.All, Mail.ReadWrite, User.ReadWrite.All, Sites.FullControl.All, Directory.ReadWrite.All, Files.ReadWrite.All, Group.ReadWrite.All |  |  | \n| ❌ | [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6d2e8d37-82b8-41e7-aa95-443a7401e8b8/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | High | User.Read | TermStore.Read.All, User.ReadWrite.All, User.Read.All, Sites.FullControl.All |  |  | \n| ❌ | [Graph Explorer](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8f8f300a-870a-46ff-bdab-934e1436920d/appId/d3ce4cf8-6810-442d-b42e-375e14710095) | High | User.Read, Directory.AccessAsUser.All |  |  |  | \n| ❌ | [Modern Workplace Concierge](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad1c51e8-f8a8-4bf2-ac09-a3a20cba5fa5/appId/c65c4011-1b90-4ec9-b5e9-1ee17786ad84) | High | openid, profile, RoleManagement.Read.Directory, Application.Read.All, User.ReadBasic.All, Group.ReadWrite.All, DeviceManagementRBAC.ReadWrite.All, Policy.ReadWrite.ConditionalAccess, Policy.Read.All, User.Read, DeviceManagementApps.ReadWrite.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementServiceConfig.ReadWrite.All |  |  |  | \n| ❌ | [InfinityDemo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/bac0ba57-1876-448e-96bf-6f0481c99fda/appId/fef811e1-2354-43b0-961b-248fe15e737d) | High | User.Read, Directory.Read.All |  |  |  | \n| ❌ | [Azure AD Assessment (Test)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d4cf4286-0fbe-424d-b4f2-65aa2c568631/appId/c62a9fcb-53bf-446e-8063-ea6e2bfcc023) | High | AuditLog.Read.All, Directory.AccessAsUser.All, Directory.ReadWrite.All, Group.ReadWrite.All, IdentityProvider.ReadWrite.All, Policy.ReadWrite.TrustFramework, PrivilegedAccess.ReadWrite.AzureAD, PrivilegedAccess.ReadWrite.AzureResources, TrustFrameworkKeySet.ReadWrite.All, User.Invite.All, offline_access, openid, profile |  |  |  | \n| ❌ | [Automation](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f79df990-9ad2-4142-b5fd-8945ff334da3/appId/dc7d83b5-d38b-4488-8952-7abf02e71590) | High | User.Read | Directory.ReadWrite.All |  |  | \n| ❌ | [Cool New for Telstra](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3d6c91cf-d48f-4272-ac4c-9f989bbec779/appId/d77611ee-5051-4383-9af3-5ba3627306a7) | High |  | Application.Read.All |  |  | \n| ❌ | [test public client](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5e80ea33-31fa-49fd-9a94-61894bd1a6c9/appId/79a0c604-f215-4c52-8fbe-641d08aa7937) | High |  | User.Read.All |  |  | \n| ❌ | [M365PronounKit](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6bf7c616-88e8-4f7c-bdad-452e561fa777/appId/eea28244-3eec-4820-beae-d4a2c0bcc235) | High |  | User.ReadWrite.All |  |  | \n| ❌ | [Windows Virtual Desktop AME](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/8369f33c-da25-4a8a-866d-b0145e29ef29/appId/5a0aa725-4958-4b0c-80a9-34562e23f3b7) | High |  | User.Read.All, Directory.Read.All |  |  | \n| ❌ | [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/35cbeecb-be21-4596-9869-0157d84f2d67/appId/c823a25d-fe94-494c-91f6-c7d51bf2df82) | High | User.Read | Sites.FullControl.All |  |  | \n| ✅ | [AppProxyDemoLocalhost](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/2425e515-5720-4071-9fae-fd50f153c0aa/appId/b0e53e94-b4b0-4632-98ae-e230af1f511c) | Unranked | User.Read |  |  | 2022-07-13 | \n| ✅ | [guestapprove](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/680210cc-fa88-4b4f-89f9-d3d7aab98cb4/appId/608b62f5-cf92-4a52-a789-23f66ed5025f) | High |  | User.ReadWrite.All, EntitlementManagement.Read.All, AuditLog.Read.All |  | 2022-11-11 | \n| ✅ | [BlazorMultiDemo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/77198970-f1eb-4574-9a1a-6af175a283af/appId/2e311a1d-f5c0-41c6-b866-77af3289871e) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-02-06 | \n| ✅ | [Microsoft Assessment React](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/0a8b4459-b0c2-4cb8-baeb-c4c5a6a8f14b/appId/c4b110d7-6f1d-473d-aa9e-6e74b8b8bd4b) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-02-25 | \n| ✅ | [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/043dd83b-94ce-4d12-b54b-45d77979f05a/appId/0b75bb7b-d365-4c29-92ea-e2799d2a3fce) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-03-11 | \n| ✅ | [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/30aa6cd2-1aab-42fd-a235-0521713f4532/appId/afe793df-19e0-455a-8403-2e863379bfaa) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-03-11 | \n| ✅ | [My Doc Gen](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a445d652-f72d-4a88-9493-79d3c3c23d1b/appId/e580347d-d0aa-4aa1-9113-5daa0bb1c805) | High | User.Read, openid, profile, offline_access, Directory.Read.All, Policy.Read.All, Agreement.Read.All, CrossTenantInformation.ReadBasic.All |  |  | 2023-03-17 | \n| ✅ | [graph-developer-proxy-samples](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e6570bb8-fdea-4329-82e2-2809d8fb67a7/appId/3658d9e9-dc87-4345-b59b-184febcf6781) | Unranked | User.Read.All, Presence.Read.All |  |  | 2023-04-20 | \n| ✅ | [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/aa64efdb-2d05-4c81-a9e5-80294bf0afac/appId/7fb37b38-ce4f-4675-9263-0cd3404b4925) | High | Policy.Read.All, User.Read, Directory.ReadWrite.All, Mail.ReadWrite | Directory.ReadWrite.All, Mail.ReadWrite |  | 2023-04-20 | \n| ✅ | [Canva](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/37ae3acb-5850-49e8-a0f8-cb06f5a77417/appId/2c0bebe0-bdb3-4909-8955-7ef311f0db22) | Unranked | email, openid, profile, User.Read |  |  | 2023-04-27 | \n| ✅ | [idPowerToys - CI](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/b66231c2-9568-46f1-b61e-c5f8fd9edee4/appId/50827722-4f53-48ba-ae58-db63bb53626b) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  |  | 2023-07-05 | \n| ✅ | [MyTokenTestApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/60923f18-748f-42bb-a0b2-ee60d44e17fc/appId/6a846cb7-35ad-41b2-b10a-0c5decde9855) | Unranked | profile, openid |  |  | 2023-07-05 | \n| ✅ | [Microsoft Graph PowerShell - Used by Team Incredibles](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e67821d9-a20b-43ef-9c34-76a321643b4f/appId/2935f660-810c-41ff-b9ad-168cc649e36f) | Unranked | User.Read, openid, profile, offline_access |  |  | 2023-08-15 | \n| ✅ | [MyZt](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/716038b1-2811-40fc-8622-93e093890af0/appId/eee51d92-0bb5-4467-be6a-8f24ef677e4d) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, DeviceManagementServiceConfig.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementApps.Read.All, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, PrivilegedEligibilitySchedule.Read.AzureADGroup, openid, profile, offline_access |  |  | 2023-09-01 | \n| ✅ | [MyZtA\\[\\[](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d2a2a09d-7562-45fc-a950-36fedfb790f8/appId/d159fcf5-a613-435b-8195-8add3cdf4bff) | High | RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, Policy.Read.All, Agreement.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementServiceConfig.Read.All, User.Read, Directory.Read.All, PrivilegedEligibilitySchedule.Read.AzureADGroup, CrossTenantInformation.ReadBasic.All |  |  | 2023-09-05 | \n| ✅ | [idPowerToys - Release](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4654e05d-9f59-4925-807c-8eb2306e1cb1/appId/904e4864-f3c3-4d2f-ace2-c37a4ed55145) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  |  | 2023-10-24 | \n| ✅ | [Azure AD Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6c74be7f-bcc9-4541-bfe1-f113b90b0497/appId/68bc31c0-f891-4f4c-9309-c6104f7be41b) | High | Organization.Read.All, RoleManagement.Read.Directory, Application.Read.All, User.Read.All, Group.Read.All, Policy.Read.All, Directory.Read.All, SecurityEvents.Read.All, UserAuthenticationMethod.Read.All, AuditLog.Read.All, Reports.Read.All, openid, offline_access, profile |  |  | 2023-10-27 | \n| ✅ | [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/666a58ef-c3e5-4efc-828a-2ab3c0120677/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | High | User.Read | Sites.Read.All, Sites.Read.All |  | 2023-11-17 | \n| ✅ | [CachingSampleApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/59187561-8df5-4792-b3a4-f6ca8b54bfc7/appId/3d6835ff-f7f4-4a83-adb5-67ccdd934717) | Unranked | User.Read, openid, profile, offline_access |  |  | 2024-01-23 | \n| ✅ | [EAM Demo](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24b12ae7-4648-4aae-b00c-6349a565d24c/appId/e6e0be31-7040-4084-ac44-600b67661f2c) | Unranked | profile, openid |  |  | 2024-01-30 | \n| ✅ | [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/3dde25cc-223f-4a16-8e8f-6695940b9680/appId/e7dfcbb6-fe86-44a2-b512-8d361dcc3d30) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, DeviceManagementServiceConfig.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All, DeviceManagementApps.Read.All, RoleAssignmentSchedule.Read.Directory, RoleEligibilitySchedule.Read.Directory, PrivilegedEligibilitySchedule.Read.AzureADGroup, openid, profile, offline_access |  |  | 2024-04-10 | \n| ✅ | [elapora-Maester-54d3ea01-5a07-45d0-8d69-e5f5b0b20098](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/4faa0456-5ecb-49f3-bb9a-2dbe516e939a/appId/a8c184ae-8ddf-41f3-8881-c090b43c385f) | High |  | DirectoryRecommendations.Read.All, Reports.Read.All, Mail.Send, Directory.Read.All, Policy.Read.All |  | 2024-05-11 | \n| ✅ | [Azure Static Web Apps](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/6b1f4a00-db4e-43ae-b62b-2286d4fcc4ea/appId/d414ee2d-73e5-4e5b-bb16-03ef55fea597) | Unranked | openid, profile, email |  |  | 2024-05-27 | \n| ✅ | [Maester DevOps Account - GitHub - Secret (demo)](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e31cd01e-afaf-4cc3-8d15-d3f9f7eb61e8/appId/d0dc5f0a-bf75-41a4-9272-d5ec2345c963) | High |  | Reports.Read.All, Mail.Send, Directory.Read.All, Policy.Read.All |  | 2024-06-09 | \n| ✅ | [Maester DevOps Account - GitHub](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ce3af345-b0e0-4b15-808c-937d825bcf03/appId/f050a85f-390b-4d43-85a0-2196b706bfd6) | High |  | PrivilegedAccess.Read.AzureAD, Reports.Read.All, Mail.Send, Directory.Read.All, Policy.Read.All |  | 2024-06-09 | \n| ✅ | [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d54232da-de3b-4874-aef2-5203dbd7342a/appId/d99dd249-6ab3-4e92-be40-81af11658359) | High | User.Read | Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, DirectoryRecommendations.Read.All, PrivilegedAccess.Read.AzureAD, Reports.Read.All, Mail.Send |  | 2024-06-09 | \n| ✅ | [testuserread](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/89bd9c7a-0c81-4a0a-9153-ff7cd0b81352/appId/9fe2675c-7fc5-4895-8470-eed989ea0d63) | High |  | GroupMember.Read.All, User.Read.All |  | 2024-09-10 | \n| ✅ | [FIDO2-passkeys-MFA](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/1aa7e155-cbf8-4970-8458-05a0c7a2d1a5/appId/4fabcfc0-5c44-45a1-8c80-8537f0625949) | Unranked | profile, openid |  |  | 2024-09-25 | \n| ✅ | [Graph PS - Zero Trust Workshop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/f6e8dfdd-4c84-441f-ae6e-f2f51fd20699/appId/a9632ced-c276-4c2b-9288-3a34b755eaa9) | High | AuditLog.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, DirectoryRecommendations.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, Policy.Read.ConditionalAccess, PrivilegedAccess.Read.AzureAD, Reports.Read.All, RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, UserAuthenticationMethod.Read.All, openid, profile, offline_access |  |  | 2024-11-25 | \n| ✅ | [idPowerToys](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/ad36b6e2-273d-4652-a505-8481f096e513/appId/6ce0484b-2ae6-4458-b2b9-b3369f42fd6f) | High | Agreement.Read.All, CrossTenantInformation.ReadBasic.All, Directory.Read.All, Policy.Read.All, User.Read, openid, profile, offline_access |  |  | 2024-12-06 | \n| ✅ | [MyTestForBlock](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/e9fca357-cccd-4ec4-840f-7482f6f02818/appId/14a3ba45-3246-4fbe-8c3b-c3922e68232b) | High |  | User.Read.All |  | 2024-12-09 | \n| ✅ | [idpowerelectron](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/cb64f850-a076-42d5-8dd8-cfd67d9e67f1/appId/909fff82-5b0a-4ce5-b66d-db58ee1a925d) | Unranked | openid, profile, offline_access |  |  | 2025-02-15 | \n| ✅ | [idPowerToys for Desktop](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/24cc58d8-2844-4974-b7cd-21c8a470e6bb/appId/520aa3af-bd78-4631-8f87-d48d356940ed) | High | Directory.Read.All, Policy.Read.All, Agreement.Read.All, CrossTenantInformation.ReadBasic.All, openid, profile, offline_access |  |  | 2025-02-16 | \n| ✅ | [Entra.News Automation Script - Message Center](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/158f6ef9-a65d-45f2-bdf0-b0a1db70ebd4/appId/83f76a08-fa60-48e6-9cb5-fd8ced5ae314) | Medium | User.Read | ServiceMessage.Read.All |  | 2025-02-23 | \n| ✅ | [Maester DevOps Account](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/7c32eaee-ff26-4435-be3d-b4ced08f9edc/appId/303774c1-3c6f-4dfd-8505-f24e82f9212a) | High | User.Read | RoleEligibilitySchedule.Read.Directory, RoleEligibilitySchedule.ReadWrite.Directory, RoleManagement.Read.All, Policy.Read.ConditionalAccess, DirectoryRecommendations.Read.All, Reports.Read.All, PrivilegedAccess.Read.AzureAD, Directory.Read.All, IdentityRiskEvent.Read.All, Policy.Read.All, SharePointTenantSettings.Read.All, UserAuthenticationMethod.Read.All |  | 2025-02-23 | \n| ✅ | [GitHub Actions App for Microsoft Info script](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/852b4218-67d2-4046-a9a6-f8b47430ccdf/appId/38535360-9f3e-4b1e-a41e-b4af46afcb0c) | High |  | Application.Read.All |  | 2025-02-24 | \n| ✅ | [GraphPermissionApp](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/a15dc834-08ce-4fd8-85de-3729fff8e34f/appId/d36fe320-bc28-40c8-a141-a512d65d112c) | High | User.Read | Application.Read.All |  | 2025-02-24 | \n| ✅ | [MessageCenterAccount github.com/merill/mc DO NOT DELETE](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/427b14ca-13b3-4911-b67e-9ff626614781/appId/778fad36-e4c1-4d40-a58e-9b5b64179d41) | Medium |  | ServiceMessage.Read.All |  | 2025-02-24 | \n| ✅ | [Calendar Pro](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/36e156e4-4566-44a0-b05c-a112017086b5/appId/fb507a6d-2eaa-4f1f-b43a-140f388c4445) | Unranked | profile, offline_access, email, openid, User.Read, User.ReadBasic.All |  |  |  | \n| ✅ | [Contoso Access Verifier](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/41d3b041-9859-4830-8feb-72ffd7afad65/appId/a6af3433-bc44-4d27-9b35-81d10fd51315) | Unranked | openid, profile, User.Read |  |  |  | \n| ✅ | [WebApplication4](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/5bc56e47-7a8a-4e71-b25f-8c4e373f40a6/appId/b2d1f868-27ee-4ecd-ae81-0ee96b028605) | Unranked | User.Read |  |  |  | \n| ✅ | [Entry Kiosk](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/83adcc80-3a35-4fdc-9c5b-1f6b9061508e/appId/b903f17a-87b0-460b-9978-962c812e4f98) | Unranked | User.Read |  |  |  | \n| ✅ | [AppProxy Header Test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/53c7bdb1-cae2-43b0-9e2e-d8605395ceec/appId/19a70df3-cddf-48c7-be44-97b25b9857f1) | Unranked | User.Read |  |  |  | \n\n\n\n\n\n\n\n\n",
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they’re legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Application"
      ],
      "TestStatus": "Failed",
      "TestId": "21770",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Inactive applications don’t have highly privileged Microsoft Graph API permissions"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21809",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Admin consent workflow is enabled"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21838",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Security key authentication method enabled"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nFound Roles don’t have policies to enforce phishing resistant Credentials\n\n\n\n## Conditional Access Policies with phishing resistant authentication policies \n\nFound 4 phishing resistant conditional access policies.\n\n  - [AuthContext: Require FIDO2 ](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/854ff675-1eef-448d-8382-533788fae7e5) (Disabled)\n  - [MFA CA Policy](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/e589544c-0c92-432e-86ae-4e4ef103eac8)\n  - [Guest-Meferna-Woodgrove-PhishingResistantAuthStrength](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/0f0a0c1c-41b0-4c18-ae20-d02492d03737)\n  - [NewphishingCA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/3fe49849-5ab6-4717-a22d-aa42536eb560) (Disabled)\n\n\n## Privileged Roles\n\nFound 2 of 29 privileged roles protected by phishing resistant authentication.\n\n| Role Name | Phishing resistance enforced |\n| :--- | :---: |\n| Hybrid Identity Administrator | ✅ |\n| Security Administrator | ✅ |\n| Application Administrator | ❌ |\n| Application Developer | ❌ |\n| Attribute Provisioning Administrator | ❌ |\n| Attribute Provisioning Reader | ❌ |\n| Authentication Administrator | ❌ |\n| Authentication Extensibility Administrator | ❌ |\n| B2C IEF Keyset Administrator | ❌ |\n| Cloud Application Administrator | ❌ |\n| Cloud Device Administrator | ❌ |\n| Conditional Access Administrator | ❌ |\n| Directory Writers | ❌ |\n| Domain Name Administrator | ❌ |\n| ExamStudyTest | ❌ |\n| External Identity Provider Administrator | ❌ |\n| Global Administrator | ❌ |\n| Global Reader | ❌ |\n| Helpdesk Administrator | ❌ |\n| Intune Administrator | ❌ |\n| Lifecycle Workflows Administrator | ❌ |\n| Partner Tier1 Support | ❌ |\n| Partner Tier2 Support | ❌ |\n| Password Administrator | ❌ |\n| Privileged Authentication Administrator | ❌ |\n| Privileged Role Administrator | ❌ |\n| Security Operator | ❌ |\n| Security Reader | ❌ |\n| User Administrator | ❌ |\n## Authentication Strength Policies\n\nFound 2 custom phishing resistant authentication strength policies.\n\n  - [ACSC Maturity Level 3](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n  - [Phishing-resistant MFA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n\n\n\n\n\n\n\n\n",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths#authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report#authentication-methods-activity?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "AccessControl",
        "Authentication"
      ],
      "TestStatus": "Failed",
      "TestId": "21783",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Privileged Microsoft Entra built-in roles are targeted with Conditional Access policies to enforce phishing-resistant methods"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21831",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Conditional Access protected actions are enabled"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21818",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Activation alert for highly privileged  role assignments"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21834",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Directory sync account is locked down to specific named location"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21897",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestTitle": "All app assignment and group membership is governed"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21885",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "App registrations must not have reply URLs containing *.azurewebsites.net, URL shorteners, or localhost, wildcard domains"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21888",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "App registrations must not have dangling or abandoned domain redirect URIs"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21793",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Tenant restrictions v2 are configured"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21813",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "High Global Administrator to privileged user ratio"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21870",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Enable SSPR"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21877",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestTitle": "All guests have a sponsor"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21878",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "All entitlement management policies have an expiration date"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "22100",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "[CIAM] Enable WAF for ciamlogin endpoints"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21884",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Workload identities based on known networks are configured"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21774",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Microsoft services applications don't have credentials configured"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21954",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Restrict nonadministrator users from recovering the BitLocker keys for their owned devices"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21810",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Group owner consent to application is disabled"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnaddressed high priority entra recommendations are found.\n\n  ❌\n",
      "TestDescription": "Leaving high-priority Microsoft Entra recommendations unaddressed creates a gap in an organization’s security posture, offering threat actors opportunities to exploit known weaknesses. Not acting will result in severe security implications or potential downtime.\n\n**Remediation action**\n\nAddress each of the high impact recommendations. Each recommendation will have its own set of remediation steps: \n\n- [What are Microsoft Entra recommendations?](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/overview-recommendations#recommendations-overview-table)\n",
      "TestTags": [
        "Application"
      ],
      "TestStatus": "Failed",
      "TestId": "22124",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "High priority Entra recommendations are addressed"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21811",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Password expiration is disabled"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21964",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Enable protected actions to secure Conditional Access policy creation and changes"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21789",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Tenant creation events are triaged"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nFound privileged users that have not yet registered phishing resistant authentication methods\n\n## Privileged users\n\nFound privileged users that have not registered phishing resistant authentication methods.\n\nUser | Role Name | Phishing resistant method registered |\n| :--- | :--- | :---: |\n|[Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true)| User Administrator | ❌ |\n|[On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f/hidePreviewBanner~/true)| Directory Synchronization Accounts | ❌ |\n|[Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true)| Global Administrator | ❌ |\n|[Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true)| Global Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Attribute Assignment Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Attribute Definition Administrator | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| Global Administrator | ✅ |\n\n\n\n\n\n\n\n\n",
      "TestDescription": "Without phishing-resistant authentication methods, privileged users are more vulnerable to phishing attacks. These types of attacks trick users into revealing their credentials to grant unauthorized access to attackers. If non-phishing-resistant authentication methods are used, attackers might intercept credentials and tokens, through methods like adversary-in-the-middle attacks, undermining the security of the privileged account.\n\nOnce a privileged account or session is compromised due to weak authentication methods, attackers might manipulate the account to maintain long-term access, create other backdoors, or modify user permissions. Attackers can also use the compromised privileged account to escalate their access even further, potentially gaining control over more sensitive systems.\n\n**Remediation action**\n\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Ensure that privileged accounts register and use phishing resistant methods](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths#authentication-strengths?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policy to target privileged accounts and require phishing resistant credentials using authentication strengths](https://learn.microsoft.com/entra/identity/conditional-access/policy-admin-phish-resistant-mfa?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Monitor authentication method activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report#authentication-methods-activity?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Credential"
      ],
      "TestStatus": "Failed",
      "TestId": "21781",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Privileged users sign in with phishing-resistant methods"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nFound users that have not yet registered phishing resistant authentication methods\n\n## Users strong authentication methods\n\nFound users that have not registered phishing resistant authentication methods.\n\nUser | Last sign in | Phishing resistant method registered |\n| :--- | :--- | :---: |\n|[Adele Vance](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e436ca15-3a39-4dcc-819e-7dbb246cd46b/hidePreviewBanner~/true)|  | ❌ |\n|[Anna Jorayew](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/58d9ed99-93ca-4674-8c5f-ec770f5ba17d/hidePreviewBanner~/true)|  | ❌ |\n|[Bagul Atayewa](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/5655cf54-34bc-4f36-bb74-44da35547975/hidePreviewBanner~/true)|  | ❌ |\n|[Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7/hidePreviewBanner~/true)|  | ❌ |\n|[Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6/hidePreviewBanner~/true)| 01/20/2024 08:00:27 | ❌ |\n|[Faiza Malkia](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/36bf7e02-3abc-46aa-895f-cf95227377fd/hidePreviewBanner~/true)|  | ❌ |\n|[Grady Archie](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e4bc6f4a-124f-469b-8951-3d5c34fb9741/hidePreviewBanner~/true)| 11/15/2023 18:36:22 | ❌ |\n|[Hamisi Khari](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/494995bf-5510-450c-a317-6d24f63cd15b/hidePreviewBanner~/true)|  | ❌ |\n|[Henrietta Mueller](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/eb6a4040-3ff6-4911-a80d-68c701384c38/hidePreviewBanner~/true)|  | ❌ |\n|[Isaiah Langer](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2a054082-8f05-4e05-8fce-4e35c3bb40cc/hidePreviewBanner~/true)| 2023-12-12 | ❌ |\n|[Jackie Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0145d508-50fd-4f86-a47a-bf1c043c8358/hidePreviewBanner~/true)|  | ❌ |\n|[Jane Doe](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/57c41b80-a96a-4c06-8ab9-9539818a637f/hidePreviewBanner~/true)|  | ❌ |\n|[Johanna Lorenz](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/8994aee7-8c36-4e04-9116-8f21d8acdeb7/hidePreviewBanner~/true)|  | ❌ |\n|[John1 Doe](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/77d4be98-c05d-4478-be25-3ee710b5247e/hidePreviewBanner~/true)| 2024-04-11 | ❌ |\n|[Joni Sherman](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/2da436f2-952a-47de-9dfe-84bd2f0d93e9/hidePreviewBanner~/true)|  | ❌ |\n|[Lee Gu](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/0a9e313b-8777-4741-ba14-0f2724179117/hidePreviewBanner~/true)|  | ❌ |\n|[Lidia Holloway](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/9188d3d3-386c-4145-a811-0d777a288e11/hidePreviewBanner~/true)|  | ❌ |\n|[Lynne Robbins](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/8e5f7749-d5e7-46fc-8eb7-3b8ab7e20ae5/hidePreviewBanner~/true)|  | ❌ |\n|[Megan Bowen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/96d29f01-873c-46a3-b542-f7ee192cc675/hidePreviewBanner~/true)| 10/27/2024 23:33:31 | ❌ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a0883b7a-c6a8-440f-84f0-d6e1b79aaf4c/hidePreviewBanner~/true)| 2024-10-05 | ❌ |\n|[Miriam Graham](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f5745554-1894-4fb0-9560-65d6fc489724/hidePreviewBanner~/true)|  | ❌ |\n|[Nestor Wilke](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/24b9254d-1bc5-435c-ad3d-7dbee86f8b9a/hidePreviewBanner~/true)|  | ❌ |\n|[New User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/6eef8ea0-1263-4973-9b0b-1e7aed0d21cd/hidePreviewBanner~/true)|  | ❌ |\n|[No Location](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/696743fa-055b-42fb-aac4-ab451a4617d6/hidePreviewBanner~/true)|  | ❌ |\n|[NoMail Enabled](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/a740d122-ee21-4354-9423-adccf8b6b233/hidePreviewBanner~/true)|  | ❌ |\n|[On-Premises Directory Synchronization Service Account](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/33956e9a-cb54-42e9-94e8-d8f6ba05a55f/hidePreviewBanner~/true)| 06/17/2024 04:12:01 | ❌ |\n|[Patti Fernandez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/3bae3a95-7605-4271-8418-e35733991834/hidePreviewBanner~/true)|  | ❌ |\n|[Pradeep Gupta](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ac712f60-0052-4911-8c5d-146cf9d4dc59/hidePreviewBanner~/true)|  | ❌ |\n|[Rhea Stone](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ac49a6e5-09c1-404b-915e-0d28574b3d72/hidePreviewBanner~/true)|  | ❌ |\n|[Roi Fraguela](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/e0a814e5-5169-4af2-bb19-63930b42ac41/hidePreviewBanner~/true)|  | ❌ |\n|[Sandy](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/d5e32d0c-3f3c-43ef-abe1-75890a73f40c/hidePreviewBanner~/true)|  | ❌ |\n|[Tegra Núnez](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/25e54254-3719-4c07-a880-3aee6bc60876/hidePreviewBanner~/true)|  | ❌ |\n|[Tracy yu](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/80153e0b-dcce-42de-9df6-59a3fc89479b/hidePreviewBanner~/true)|  | ❌ |\n|[Tyler Chan](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7094fb23-003a-4f81-9796-5daeaa603003/hidePreviewBanner~/true)| 2025-04-02 | ❌ |\n|[Unlicensed User](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/7804b01c-1223-4045-a393-43171298fa6b/hidePreviewBanner~/true)|  | ❌ |\n|[usernonick](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/b531f68f-8d01-467b-9db6-a57438b0e8af/hidePreviewBanner~/true)|  | ❌ |\n|[Wilna Rossouw](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/62cd4528-8e5d-4789-84f6-8b33d0af5ca7/hidePreviewBanner~/true)|  | ❌ |\n|[Yakup Meredow](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/767bcbda-28a0-4e5f-841d-e918c5a1c229/hidePreviewBanner~/true)|  | ❌ |\n|[Alex Wilber](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/f10bc459-0bcf-49d0-8f86-4553b8f015b8/hidePreviewBanner~/true)| 01/25/2025 03:23:09 | ✅ |\n|[Diego Siciliani](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/cdfa577c-972f-4399-98aa-1ec4be7fa6d1/hidePreviewBanner~/true)| 2024-04-01 | ✅ |\n|[Emergency Access](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/ceef37b7-c865-48fb-80c9-4def11201854/hidePreviewBanner~/true)| 2024-09-11 | ✅ |\n|[Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a/hidePreviewBanner~/true)| 2024-09-12 | ✅ |\n|[Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/513f3db2-044c-41be-af14-431bf88a2b3e/hidePreviewBanner~/true)| 02/24/2025 00:21:51 | ✅ |\n\n\n\n\n\n\n\n",
      "TestDescription": "Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.\n\nAttackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.\n\n**Remediation action**\n\n- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policies to enforce authentication strength](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center#authentication-methods-activity&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Credential"
      ],
      "TestStatus": "Failed",
      "TestId": "21801",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Users have strong authentication methods configured"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21803",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Migrate from legacy MFA and SSPR policies"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\n✅ Validated guest user access is restricted.\n\n\n\n\n\n\n\n",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.  \n\nExternal accounts with permissions to read directory object permissions provide attackers with broader initial access if compromised. These accounts allow attackers to gather additional information from the directory for reconnaissance.\n\n**Remediation action**\n\n- [Restrict guest access to their own directory objects](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure#to-configure-guest-user-access?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Application"
      ],
      "TestStatus": "Passed",
      "TestId": "21792",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Guests have restricted access to directory objects"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21882",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "No nested groups in PIM for groups"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21819",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Activation alert for Global Administrator role assignments"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "22099",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "[CIAM] Integrate Entra Sign-In logs with Azure Monitor"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21784",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All user sign in activity uses phishing-resistant authentication methods"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "22128",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Guests are not assigned high privileged directory roles"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21786",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "User sign-in activity uses token protection"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21859",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "GDAP admin least privilege"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21849",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Smart lockout duration is set to a minimum of 60"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21857",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Guest identities are lifecycle managed with access reviews"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21865",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Trusted network locations are configured to increase quality of risk detections"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21861",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All risky users are triaged"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "22098",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "[CIAM] Integrate Entra Audit logs with Azure Monitor"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nSome Entra Logs are not configured with Diagnostic settings.\n\n## Log archiving\n\nLog | Archiving enabled |\n| :--- | :---: |\n|ADFSSignInLogs | ❌ |\n|AuditLogs | ❌ |\n|EnrichedOffice365AuditLogs | ❌ |\n|ManagedIdentitySignInLogs | ❌ |\n|MicrosoftGraphActivityLogs | ❌ |\n|NetworkAccessTrafficLogs | ❌ |\n|NonInteractiveUserSignInLogs | ❌ |\n|ProvisioningLogs | ❌ |\n|RemoteNetworkHealthLogs | ❌ |\n|RiskyServicePrincipals | ❌ |\n|RiskyUsers | ❌ |\n|ServicePrincipalRiskEvents | ❌ |\n|ServicePrincipalSignInLogs | ❌ |\n|SignInLogs | ❌ |\n|UserRiskEvents | ❌ |\n\n\n\n\n\n\n\n\n",
      "TestDescription": "The activity logs and reports in Microsoft Entra can help detect unauthorized access attempts or identify when tenant configuration changes. When logs are archived or integrated with Security Information and Event Management (SIEM) tools, security teams can implement powerful monitoring and detection security controls, proactive threat hunting, and incident response processes. The logs and monitoring features can be used to assess tenant health and provide evidence for compliance and audits.\n\nIf logs aren't regularly archived or sent to a SIEM tool for querying, it's challenging to investigate sign-in issues. The absence of historical logs means that security teams might miss patterns of failed sign-in attempts, unusual activity, and other indicators of compromise. This lack of visibility can prevent the timely detection of breaches, allowing attackers to maintain undetected access for extended periods.\n\n**Remediation action**\n\n- [Configure Microsoft Entra diagnostic settings](https://learn.microsoft.com/entra/identity/monitoring-health/howto-configure-diagnostic-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Integrate Microsoft Entra logs with Azure Monitor logs](https://learn.microsoft.com/entra/identity/monitoring-health/howto-integrate-activity-logs-with-azure-monitor-logs?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Stream Microsoft Entra logs to an event hub](https://learn.microsoft.com/entra/identity/monitoring-health/howto-stream-logs-to-event-hub?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Application"
      ],
      "TestStatus": "Failed",
      "TestId": "21860",
      "SkippedReason": null,
      "TestImplementationCost": "Medium",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Diagnostic settings are configured for all Microsoft Entra logs"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "22659",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All risky workload identity sign ins are triaged"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21876",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Use PIM for Microsoft Entra privileged roles"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21798",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "ID Protection notifications enabled"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21892",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "High",
      "TestTitle": "All sign-in activity comes from managed devices"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21820",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Activation alert for all privileged role assignments"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21822",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Guest access is limited to approved tenants"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21776",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "User consent settings are restricted"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21929",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "All entitlement management packages that apply to guests have expirations or access reviews configured in their assignment policies"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21941",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Token protection policies are configured"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21812",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Maximum number of Global Administrators doesn't exceed eight users"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21953",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Local Admin Password Solution is deployed"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nTenant restricts who can invite guests.\n\n**Guest invite settings**\n\n  * Guest invite restrictions → No one in the organization can invite guest users including admins (most restrictive)\n\n\n\n\n\n\n\n",
      "TestDescription": "External user accounts are often used to provide access to business partners who belong to organizations that have a business relationship with your enterprise. If these accounts are compromised in their organization, attackers can use the valid credentials to gain initial access to your environment, often bypassing traditional defenses due to their legitimacy.  \n\nAllowing external users to onboard other external users increases the risk of unauthorized access. If an attacker compromises an external user's account, they can use it to create more external accounts, multiplying their access points and making it harder to detect the intrusion.\n\n**Remediation action**\n\n- [Restrict who can invite guests to only users assigned to specific admin roles](https://learn.microsoft.com/entra/external-id/external-collaboration-settings-configure#to-configure-guest-invite-settings?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "ExternalCollaboration"
      ],
      "TestStatus": "Passed",
      "TestId": "21791",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Guests can’t invite other guests"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21823",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Guest self-service sign up via user flow is disabled"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21992",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Application Certificates need to be rotated on a regular basis"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21862",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All risky workload identities are triaged"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21828",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Authentication transfer is blocked"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21912",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Azure resources used by Microsoft Entra only allow access from privileged roles"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nFound 1 inactive applications with privileged Entra built-in roles\n\n\n## Apps with privileged Entra built-in roles\n\n| | Name | Role | Assignment | App owner tenant | Last sign in|\n| :--- | :--- | :--- | :--- | :--- | :--- |\n| ❌ | [AppRolePimAutomationTestParentAcc19Feb22](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/d22f071d-e8d3-41fc-a516-b29753cdd1f6/appId/b650c3c1-3395-40bb-8471-2a6a8b76d8a9) | Application Administrator | Permanent |  |  | \n\n\n\n\n\n\n\n\n",
      "TestDescription": "Attackers might exploit valid but inactive applications that still have elevated privileges. These applications can be used to gain initial access without raising alarm because they're legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the inactive application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n**Remediation action**\n\n- [Disable inactive privileged service principals](https://learn.microsoft.com/graph/api/serviceprincipal-update?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- Investigate if the application has legitimate use cases. If so, [analyze if a OAuth2 permission is a better fit](https://learn.microsoft.com/entra/identity-platform/v2-app-types?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [If service principal doesn't have legitimate use cases, delete it](https://learn.microsoft.com/graph/api/serviceprincipal-delete?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Application"
      ],
      "TestStatus": "Failed",
      "TestId": "21771",
      "SkippedReason": null,
      "TestImplementationCost": "Low",
      "TestSkipped": "",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Inactive applications don’t have highly privileged built-in roles"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21899",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All privileged role assignments have a recipient that can receive notifications"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21875",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Tenant has all external organizations allowed to collaborate as Connected Organization"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21808",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Restrict device code flow"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21799",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Block high risk sign-ins"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n\n",
      "TestDescription": "Attackers might gain access if multifactor authentication (MFA) isn't universally enforced or if there are exceptions in place. Attackers might gain access by exploiting vulnerabilities of weaker MFA methods like SMS and phone calls through social engineering techniques. These techniques might include SIM swapping or phishing, to intercept authentication codes.\n\nAttackers might use these accounts as entry points into the tenant. By using intercepted user sessions, attackers can disguise their activities as legitimate user actions, evade detection, and continue their attack without raising suspicion. From there, they might attempt to manipulate MFA settings to establish persistence, plan, and execute further attacks based on the privileges of compromised accounts.\n\n**Remediation action**\n\n- [Deploy multifactor authentication](https://learn.microsoft.com/entra/identity/authentication/howto-mfa-getstarted?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Get started with a phishing-resistant passwordless authentication deployment](https://learn.microsoft.com/entra/identity/authentication/how-to-plan-prerequisites-phishing-resistant-passwordless-authentication?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Deploy Conditional Access policies to enforce authentication strength](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-mfa-strength?wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n- [Review authentication methods activity](https://learn.microsoft.com/entra/identity/monitoring-health/concept-usage-insights-report?tabs=microsoft-entra-admin-center#authentication-methods-activity&wt.mc_id=zerotrustrecommendations_automation_content_cnl_csasci)\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21800",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "All user sign-in activity uses strong authentication methods"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21955",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Manage the local administrators on Microsoft Entra joined devices"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21845",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Temporary access pass is enabled"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21874",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Tenant does have controls to selectively onboard external organizations (cross-tenant access polices and domain-based allow/deny lists)"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21889",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Medium",
      "TestTitle": "Reduce the user-visible password surface area"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21886",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Applications that use Microsoft Entra for authentication and support provisioning are configured"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21864",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All risk detections are triaged"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21836",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Workload identities assigned privileged roles"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21850",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Smart lockout threshold isn't greater than 10"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21855",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Privileged roles have access reviews"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21881",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Azure subscriptions used by Identity Governance are secured consistently with Identity Governance roles"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21847",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Password protection for on-premises is enabled"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21844",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Block legacy Azure AD PowerShell module"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21832",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All groups in Conditional Access policies belong to a restricted management administrative unit"
    },
    {
      "TestRisk": "Low",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21848",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Enable custom banned passwords"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21887",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All registered redirect URIs must have proper DNS records and ownerships"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21868",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Guests don't own apps in the tenant"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21815",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "High",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "All privileged role assignments are activated just in time and not permanently active"
    },
    {
      "TestRisk": "High",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21790",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Low",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Outbound cross-tenant access settings are configured"
    },
    {
      "TestRisk": "Medium",
      "TestResult": "\nUnder construction.\n",
      "TestDescription": "This test is under construction.\n\n**Remediation action**\n\n",
      "TestTags": [
        "Identity"
      ],
      "TestStatus": "Skipped",
      "TestId": "21858",
      "SkippedReason": "UnderConstruction",
      "TestImplementationCost": "Medium",
      "TestSkipped": "UnderConstruction",
      "TestAppliesTo": [
        "Identity"
      ],
      "TestImpact": "Low",
      "TestTitle": "Inactive guest identities are removed from the tenant"
    }
  ],
  "TenantInfo": {
    "OverviewAuthMethodsPrivilegedUsers": {
      "description": "Strongest authentication method registered by privileged users.",
      "nodes": [
        {
          "value": 3,
          "source": "Users",
          "target": "Single factor"
        },
        {
          "value": 7,
          "source": "Users",
          "target": "Phishable"
        },
        {
          "value": 2,
          "source": "Phishable",
          "target": "Phone"
        },
        {
          "value": 5,
          "source": "Phishable",
          "target": "Authenticator"
        },
        {
          "value": 4,
          "source": "Users",
          "target": "Phish resistant"
        },
        {
          "value": 3,
          "source": "Phish resistant",
          "target": "Passkey"
        },
        {
          "value": 1,
          "source": "Phish resistant",
          "target": "WHfB"
        }
      ]
    },
    "OverviewCaMfaAllUsers": {
      "description": "Over the past 29 days, 99.1% of sign-ins were protected by conditional access policies enforcing multifactor.",
      "nodes": [
        {
          "value": 12,
          "source": "User sign in",
          "target": "No CA applied"
        },
        {
          "value": 1946,
          "source": "User sign in",
          "target": "CA applied"
        },
        {
          "value": 6,
          "source": "CA applied",
          "target": "No MFA"
        },
        {
          "value": 1940,
          "source": "CA applied",
          "target": "MFA"
        }
      ]
    },
    "OverviewCaDevicesAllUsers": {
      "description": "Over the past 29 days, 0% of sign-ins were from compliant devices.",
      "nodes": [
        {
          "value": 1958,
          "source": "User sign in",
          "target": "Unmanaged"
        },
        {
          "value": 0,
          "source": "User sign in",
          "target": "Managed"
        },
        {
          "value": 0,
          "source": "Managed",
          "target": "Non-compliant"
        },
        {
          "value": 0,
          "source": "Managed",
          "target": "Compliant"
        }
      ]
    },
    "OverviewAuthMethodsAllUsers": {
      "description": "Strongest authentication method registered by all users.",
      "nodes": [
        {
          "value": 27,
          "source": "Users",
          "target": "Single factor"
        },
        {
          "value": 21,
          "source": "Users",
          "target": "Phishable"
        },
        {
          "value": 7,
          "source": "Phishable",
          "target": "Phone"
        },
        {
          "value": 14,
          "source": "Phishable",
          "target": "Authenticator"
        },
        {
          "value": 6,
          "source": "Users",
          "target": "Phish resistant"
        },
        {
          "value": 4,
          "source": "Phish resistant",
          "target": "Passkey"
        },
        {
          "value": 2,
          "source": "Phish resistant",
          "target": "WHfB"
        }
      ]
    }
  },
  "EndOfJson": "EndOfJson"
}
