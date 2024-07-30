export interface ReportData {
  ExecutedAt: string;
  TenantId: string;
  Domain: string;
  TenantName: string;
  Account: string;
  CurrentVersion: string;
  LatestVersion: string;
  Tests: Test[];
}

export interface Test {
  TestAppliesTo: string[];
  TestTitle: string;
  TestId: string;
  TestStatus: string;
  TestResult: string;
  TestLikelihood: string;
  TestImpact: string;
  TestSkipped: string;
  SkippedReason: null;
  TestTags: string[];
  TestDescription: string;
}

export const reportData: ReportData = {
  "ExecutedAt": "2024-07-30T22:49:50.387564+10:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "2.0.0",
  "LatestVersion": "1.0.2",
  "Tests": [
    {
      "TestDescription": "Why: Admins should be signing in with phishing resistant authentication to protect their identities. This will help block remote attacks against privileged identities.\n\n#### Remediation action:\n\n1. Create a conditional access policy using the steps outlined in the [Common Conditional Access policy: Require phishing-resistant multifactor authentication for administrators](https://learn.microsoft.com/entra/identity/conditional-access/how-to-policy-phish-resistant-admin-mfa) article.\n2. Add the missing privileged roles to the policy.\n\n#### Related links\n\n* [Conditional Access authentication strength](https://learn.microsoft.com/entra/identity/authentication/concept-authentication-strengths)\n* [Common Conditional Access policy: Require phishing-resistant multifactor authentication for administrators](https://learn.microsoft.com/entra/identity/conditional-access/how-to-policy-phish-resistant-admin-mfa)\n\n",
      "SkippedReason": null,
      "TestAppliesTo": [
        "Entra"
      ],
      "TestLikelihood": "Possible",
      "TestTags": [
        "Credential",
        "TenantPolicy"
      ],
      "TestTitle": "Phishing resistant authentication required for privileged roles",
      "TestResult": "\nTenant is not configured to require phishing resistant authentication for all privileged roles.\n\n## Authentication Strength Policies\n\nPhishing resistant authentication strength policies found:\n\n - ACSC Maturity Level 3\n - Phishing-resistant MFA\n\n\n## Conditional Access Policies with phishing resistant authentication policies \n\nConditional access policies with phishing resistant authentication strength policies:\n\n - AuthContext: Require FIDO2 \n - MFA CA Policy\n - Guest-Meferna-Woodgrove-PhishingResistantAuthStrength\n - NewphishingCA\n\n\n## Privileged Roles\n\n| Role Name | Phishing resistance enforced |\n| --- | --- |\n| User Administrator | ❌ |\n| Helpdesk Administrator | ❌ |\n| Partner Tier1 Support | ❌ |\n| Partner Tier2 Support | ❌ |\n| Directory Writers | ❌ |\n| Application Administrator | ❌ |\n| Application Developer | ❌ |\n| Security Reader | ❌ |\n| Security Administrator | ❌ |\n| Privileged Role Administrator | ❌ |\n| Intune Administrator | ❌ |\n| Cloud Application Administrator | ❌ |\n| Conditional Access Administrator | ❌ |\n| Cloud Device Administrator | ❌ |\n| Authentication Administrator | ❌ |\n| Privileged Authentication Administrator | ❌ |\n| B2C IEF Keyset Administrator | ❌ |\n| External Identity Provider Administrator | ❌ |\n| Security Operator | ❌ |\n| Global Reader | ❌ |\n| Password Administrator | ❌ |\n| Hybrid Identity Administrator | ❌ |\n| Domain Name Administrator | ❌ |\n| Authentication Extensibility Administrator | ❌ |\n| Lifecycle Workflows Administrator | ❌ |\n| ExamStudyTest | ❌ |\n| Global Administrator | ✅ |\n\n",
      "TestSkipped": "",
      "TestStatus": "Failed",
      "TestId": "ST0009",
      "TestImpact": "High"
    },
    {
      "TestDescription": "Only users with the Guest Inviter role should be able to invite guest users.\n\nWhy: By only allowing an authorized group of individuals to invite external users to create accounts in the tenant, an agency can enforce a guest user account approval process, reducing the risk of unauthorized account creation.\n\n#### Remediation action:\n\n1. In **Entra ID** and **External Identities**, select **[External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)**.\n2. Under **Guest invite settings**, select **Only users assigned to specific admin roles can invite guest users**.\n3. Click **Save**.\n\n#### Related links\n\n* [Entra admin center - External Identities | External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)\n\n",
      "SkippedReason": null,
      "TestAppliesTo": [
        "Entra"
      ],
      "TestLikelihood": "HighlyLikely",
      "TestTags": [
        "ExternalCollaboration"
      ],
      "TestTitle": "Guests should not invite other guests",
      "TestResult": "\nTenant allows any user (including other guests) to invite guests.\n",
      "TestSkipped": "",
      "TestStatus": "Failed",
      "TestId": "ST0018",
      "TestImpact": "High|EndJson|"
    }
  ]
}
