// Use quicktype (Paste JSON as Code) VSCode extension to generate this typescript interface from ZeroTrustAssessmentReport.json created by PowerShell

export interface ZeroTrustAssessmentReport {
  ExecutedAt:     string;
  TenantId:       string;
  TenantName:     string;
  Domain:         string;
  Account:        string;
  CurrentVersion: string;
  LatestVersion:  string;
  Tests:          Test[];
  TenantInfo:     TenantInfo;
  EndOfJson:      string;
}

export interface TenantInfo {
  OverviewCaMfaAllUsers: OverviewCAMfaAllUser[];
}

export interface OverviewCAMfaAllUser {
  value:  number;
  source: string;
  target: string;
}

export interface Test {
  TestTitle:       string;
  TestLikelihood:  string;
  TestAppliesTo:   string[];
  TestImpact:      string;
  SkippedReason:   null;
  TestResult:      string;
  TestSkipped:     string;
  TestStatus:      string;
  TestTags:        string[];
  TestId:          string;
  TestDescription: string;
}

export const reportData: ZeroTrustAssessmentReport = {
  "ExecutedAt": "2024-08-21T21:00:18.1436+10:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "1.0.5",
  "LatestVersion": "1.0.2",
  "Tests": [
    {
      "TestTitle": "Guests should not invite other guests",
      "TestLikelihood": "HighlyLikely",
      "TestAppliesTo": [
        "Entra"
      ],
      "TestImpact": "High",
      "SkippedReason": null,
      "TestResult": "\nTenant allows any user (including other guests) to invite guests.\n",
      "TestSkipped": "",
      "TestStatus": "Failed",
      "TestTags": [
        "ExternalCollaboration"
      ],
      "TestId": "ST0018",
      "TestDescription": "Only users with the Guest Inviter role should be able to invite guest users.\n\nBy only allowing an authorized group of individuals to invite external users to create accounts in the tenant, an agency can enforce a guest user account approval process, reducing the risk of unauthorized account creation.\n\n#### Remediation action\n\n1. In **Entra ID** and **External Identities**, select **[External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)**.\n2. Under **Guest invite settings**, select **Only users assigned to specific admin roles can invite guest users**.\n3. Click **Save**.\n\n#### Related links\n\n* [Entra admin center - External Identities | External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)\n\n"
    },
    {
      "TestTitle": "Phishing resistant authentication required for privileged roles",
      "TestLikelihood": "Possible",
      "TestAppliesTo": [
        "Entra"
      ],
      "TestImpact": "High",
      "SkippedReason": null,
      "TestResult": "\nTenant is not configured to require phishing resistant authentication for all privileged roles.\n\n\n\n## Conditional Access Policies with phishing resistant authentication policies \n\nFound 4 phishing resistant conditional access policies.\n\n  - [AuthContext: Require FIDO2 ](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/854ff675-1eef-448d-8382-533788fae7e5) (Disabled)\n  - [MFA CA Policy](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/e589544c-0c92-432e-86ae-4e4ef103eac8)\n  - [Guest-Meferna-Woodgrove-PhishingResistantAuthStrength](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/0f0a0c1c-41b0-4c18-ae20-d02492d03737)\n  - [NewphishingCA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/3fe49849-5ab6-4717-a22d-aa42536eb560)\n\n\n## Privileged Roles\n\nFound 2 of 27 privileged roles protected by phishing resistant authentication.\n\n| Role Name | Phishing resistance enforced |\n| :--- | :---: |\n| Hybrid Identity Administrator | ✅ |\n| Security Administrator | ✅ |\n| Application Administrator | ❌ |\n| Application Developer | ❌ |\n| Authentication Administrator | ❌ |\n| Authentication Extensibility Administrator | ❌ |\n| B2C IEF Keyset Administrator | ❌ |\n| Cloud Application Administrator | ❌ |\n| Cloud Device Administrator | ❌ |\n| Conditional Access Administrator | ❌ |\n| Directory Writers | ❌ |\n| Domain Name Administrator | ❌ |\n| ExamStudyTest | ❌ |\n| External Identity Provider Administrator | ❌ |\n| Global Administrator | ❌ |\n| Global Reader | ❌ |\n| Helpdesk Administrator | ❌ |\n| Intune Administrator | ❌ |\n| Lifecycle Workflows Administrator | ❌ |\n| Partner Tier1 Support | ❌ |\n| Partner Tier2 Support | ❌ |\n| Password Administrator | ❌ |\n| Privileged Authentication Administrator | ❌ |\n| Privileged Role Administrator | ❌ |\n| Security Operator | ❌ |\n| Security Reader | ❌ |\n| User Administrator | ❌ |\n## Authentication Strength Policies\n\nFound 2 custom phishing resistant authentication strength policies.\n\n  - [ACSC Maturity Level 3](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n  - [Phishing-resistant MFA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/AuthStrengths/fromNav/)\n\n",
      "TestSkipped": "",
      "TestStatus": "Failed",
      "TestTags": [
        "Credential",
        "TenantPolicy"
      ],
      "TestId": "ST0009",
      "TestDescription": "Admins should be signing in with phishing resistant authentication to protect their identities. This will help block remote attacks against privileged identities.\n\n#### Remediation action\n\n1. Create a conditional access policy using the steps outlined in the [Common Conditional Access policy: Require phishing-resistant multifactor authentication for administrators](https://learn.microsoft.com/entra/identity/conditional-access/how-to-policy-phish-resistant-admin-mfa) article.\n2. Add the missing privileged roles to the policy.\n\n#### Related links\n\n* [Conditional Access authentication strength](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths)\n* [Common Conditional Access policy: Require phishing-resistant multifactor authentication for administrators](https://learn.microsoft.com/entra/identity/conditional-access/how-to-policy-phish-resistant-admin-mfa)\n\n"
    },
    {
      "TestTitle": "Block legacy authentication",
      "TestLikelihood": "HighlyLikely",
      "TestAppliesTo": [
        "Entra"
      ],
      "TestImpact": "High",
      "SkippedReason": null,
      "TestResult": "\nTenant has a policy to block legacy authentication but does not target all users or is not enabled.\n\n  - [Block legacy authentication](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/4086128c-3850-48ac-8962-e19a956828bd) (Disabled)\n  - [Block legacy authentication - Testing](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/bedecc1e-85c9-4d54-b885-cefe6bcc8763) (Report-only)\n\n",
      "TestSkipped": "",
      "TestStatus": "Failed",
      "TestTags": [
        "User",
        "Credential"
      ],
      "TestId": "ST0020",
      "TestDescription": "A conditional access policy that blocks legacy authentication protocols in the tenant.\n\nBased on Microsoft's analysis more than 97 percent of credential stuffing attacks use legacy authentication and more than 99 percent of password spray attacks use legacy authentication protocols. These attacks would stop with basic authentication disabled or blocked.\n\n#### Remediation action\n\nCreate a block legacy authentication conditional access policy and assign it to all users.\n\n- [Block legacy authentication - Microsoft Learn](https://learn.microsoft.com/entra/identity/conditional-access/howto-conditional-access-policy-block-legacy#create-a-conditional-access-policy)\n\n"
    },
    {
      "TestTitle": "Priviliged users are not synced from on-premise",
      "TestLikelihood": "Possible",
      "TestAppliesTo": [
        "Entra"
      ],
      "TestImpact": "High",
      "SkippedReason": null,
      "TestResult": "\nThis tenant has 1 privileged users that are synced from on-premise.\n\n## Privileged Roles\n\n| Role Name | User | Source | Status |\n| :--- | :--- | :--- | :---: |\n| Global Administrator | [Merill Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/513f3db2-044c-41be-af14-431bf88a2b3e) | Cloud native identity | ✅ |\n| Global Administrator | [Bob Leaf](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/653c7fdd-1b41-4229-992a-69cc35aad4f7) | Cloud native identity | ✅ |\n| Global Administrator | [Joshua Fernando](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/babe04c9-8340-4329-a727-a8cee0cd2b1a) | Cloud native identity | ✅ |\n| Global Administrator | [Damien Bowden](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/f431700c-6d81-45b8-8f8d-581a8aa7cda6) | Cloud native identity | ✅ |\n| Global Reader | [Anna Jorayew](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/58d9ed99-93ca-4674-8c5f-ec770f5ba17d) | Synced from on-premise | ❌ |\n\n",
      "TestSkipped": "",
      "TestStatus": "Failed",
      "TestTags": [
        "PrivilegedIdentity"
      ],
      "TestId": "ST0037",
      "TestDescription": "Admin users are cloud native identities and not synced from on-premise or federated \n\nIn Microsoft Entra ID, users who have privileged roles, such as administrators, are the root of trust to build and manage the rest of the environment.Use cloud-only accounts for Microsoft Entra ID and Microsoft 365 privileged roles.\n\nMicrosoft recommends that you ensure that synchronized objects hold no privileges beyond a user in Microsoft 365. Ensure these objects have no direct or nested assignment in trusted cloud roles or groups.\n\n#### Remediation action\n\n1. Perform the steps below for each [highly privileged role](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/RolesManagementMenuBlade/~/AllRoles).\n2. Review the users listed that have an **OnPremisesImmutableId** and have **OnPremisesSyncEnabled** set.\n3. Create a cloud only user account for that individual and remove their hybrid identity from privileged roles.\n\n#### Related links\n\n* [Protecting Microsoft 365 from on-premises attacks](https://learn.microsoft.com/entra/architecture/protect-m365-from-on-premises-attacks)\n* [Privileged roles and permissions in Microsoft Entra ID](https://learn.microsoft.com/entra/identity/role-based-access-control/privileged-roles-permissions?tabs=admin-center)\n\n"
    },
    {
      "TestTitle": "Multi-factor authentication for all users",
      "TestLikelihood": "HighlyLikely",
      "TestAppliesTo": [
        "Entra"
      ],
      "TestImpact": "High",
      "SkippedReason": null,
      "TestResult": "\nTenant is configured to require multi-factor authentication for all users.\n\n  - [MFA - All users](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/474ddef4-5620-4e7a-8976-6e9b095b2675)\n\n",
      "TestSkipped": "",
      "TestStatus": "Passed",
      "TestTags": [
        "User",
        "Credential"
      ],
      "TestId": "ST0024",
      "TestDescription": "A conditional access policy that blocks legacy authentication protocols in the tenant.\n\nBased on Microsoft's analysis more than 97 percent of credential stuffing attacks use legacy authentication and more than 99 percent of password spray attacks use legacy authentication protocols. These attacks would stop with basic authentication disabled or blocked.\n\n#### Remediation action\n\nCreate a block legacy authentication conditional access policy and assign it to all users.\n\n- [Block legacy authentication - Microsoft Learn](https://learn.microsoft.com/entra/identity/conditional-access/howto-conditional-access-policy-block-legacy#create-a-conditional-access-policy)\n\n"
    },
    {
      "TestTitle": "Stale apps not signed in over 90 days",
      "TestLikelihood": "HighlyLikely",
      "TestAppliesTo": [
        "Entra"
      ],
      "TestImpact": "High",
      "SkippedReason": null,
      "TestResult": "\nThis tenant has 16 apps that haven't been signed into for more than 90 days. ❌\n\n## Stale applications\n\n| Application | Date created | Last sign in |\n| :--- | :--- | :--- |\n| [elapora-Maester-54d3ea01-5a07-45d0-8d69-e5f5b0b20098](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/291fe4f6-b8cf-4362-a283-1ee22baceb56) | 03/22/2024 03:40:43 | 2024-05-11T00:00:27.6449267Z |\n| [Zero Trust Assessment](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/a84bb04d-98d2-438f-bbdd-5cb85654231f) | 04/09/2024 21:10:32 | 2024-04-09T22:13:32.0612619Z |\n| [CachingSampleApp](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/dea9bcf6-f79f-4010-9a36-a22739c71cad) | 01/23/2024 10:12:18 | 2024-01-23T11:02:00.2194945Z |\n| [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/8d419c9d-5d14-4918-955e-8e8321504f35) | 11/16/2023 23:19:00 | 2023-11-17T03:58:06.2145491Z |\n| [Graph PowerShell - Privileged Perms](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/e79a109b-e26b-4697-b343-c7122b6a3a38) | 07/13/2023 05:00:23 | 2023-11-17T01:31:37.2419263Z |\n| [MyZtA\\[\\[](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/4f1dc4c6-908b-44bd-aea5-278e0c8a3839) | 09/01/2023 11:45:24 | 2023-09-05T10:08:37.8478338Z |\n| [MyZt](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/9e6943c3-02a7-4118-99fd-4786c27f463c) | 09/01/2023 11:31:33 | 2023-09-01T11:32:23.3463508Z |\n| [Microsoft Graph PowerShell - Used by Team Incredibles](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/54b3f546-f0c1-4258-bd62-91fd6b715487) | 03/03/2023 02:34:15 | 2023-08-15T12:44:19.5548487Z |\n| [MyTokenTestApp](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/cf71d2a0-d706-4d6b-8b59-728ab1937ade) | 07/05/2023 09:43:45 | 2023-07-05T11:10:54.5787148Z |\n| [Postman](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/12a14526-56f6-42f9-91ad-7e87c477939a) | 04/19/2023 09:44:31 | 2023-04-19T16:28:51.3512897Z |\n| [graph-developer-proxy-samples](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/4b464802-467f-4835-a607-268dcb4b8912) | 04/19/2023 13:04:23 | 2023-04-19T15:53:56.8346834Z |\n| [My Doc Gen](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/57c96587-e920-4c3b-9fb3-08f9d1b0062a) | 03/17/2023 02:55:58 | 2023-03-17T08:02:35.9482074Z |\n| [aadgraphmggraph](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/eaf1e531-0d58-4874-babe-b9a9f436e6c3) | 10/20/2021 02:54:03 | 2023-03-02T01:59:07.1120888Z |\n| [BlazorMultiDemo](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/013f3f5d-159d-4de3-9f81-6f1af895a7dd) | 11/02/2022 10:28:38 | 2023-02-06T09:13:55.4520949Z |\n| [Graph Filter](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/6b787355-2ebd-4954-b082-1c38c7e027fc) | 09/16/2022 06:08:16 | 2022-09-16T06:51:11.3622807Z |\n| [AppProxyDemoLocalhost](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/338dcb7c-0784-4b30-b1d8-e5b634256f02) | 07/12/2022 06:39:48 | 2022-07-13T01:32:12.6271486Z |\n\n",
      "TestSkipped": "",
      "TestStatus": "Failed",
      "TestTags": [
        "Application"
      ],
      "TestId": "ST0002",
      "TestDescription": "Removing unused applications improves the security posture and promotes good application hygiene. It reduces the risk of application compromise by someone discovering an unused application and misusing it to get tokens. Depending on the permissions granted to the application and the resources that it exposes, an application compromise could expose sensitive data in an organization.\n\n#### Remediation action\n\nFor each application listed\n1. Click on the link to open the application in Entra admin center.\n2. Determine if the application is needed.\n3. If the application is not needed, remove it from your tenant.\n\n#### Related links\n\n* [Delete an enterprise application](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/delete-application-portal?pivots=portal)\n\n"
    },
    {
      "TestTitle": "Registering applications is restricted to privileged users",
      "TestLikelihood": "HighlyLikely",
      "TestAppliesTo": [
        "Entra"
      ],
      "TestImpact": "Medium",
      "SkippedReason": null,
      "TestResult": "\nTenant is configured to prevent users from registering applications.\n\n**[Users can register applications](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)** → **No** ✅\n",
      "TestSkipped": "",
      "TestStatus": "Passed",
      "TestTags": [
        "Application"
      ],
      "TestId": "ST0030",
      "TestDescription": "The default configuration allows any user in the tenant to register new apps and service principles. This can provide an avenue for threat actors to build malicious apps and phish users into signing to the app. \nUsers may also create apps for production workloads in corporate tenants without oversight from the organization’s cyber security team.\n\n#### Remediation action\n\n1. In **Entra**, under **Identity** and **Users**, select **[User settings](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)**.\n2. For **Users can register applications**, select **No**.\n3. Click **Save**.\n\n#### Related links\n\n* [Entra admin center - User settings](https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings)\n\n"
    }
  ],
  "TenantInfo": {
    "OverviewCaMfaAllUsers": [
      {
        "value": 500,
        "source": "User sign in",
        "target": "No CA applied"
      },
      {
        "value": 2100,
        "source": "User sign in",
        "target": "CA applied"
      },
      {
        "value": 200,
        "source": "CA applied",
        "target": "No MFA"
      },
      {
        "value": 1900,
        "source": "CA applied",
        "target": "MFA"
      }
    ]
  },
  "EndOfJson": "EndOfJson"
}
