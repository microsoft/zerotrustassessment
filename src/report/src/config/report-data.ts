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
    "ExecutedAt": "2024-07-29T13:06:13.828454+10:00",
    "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
    "TenantName": "Pora",
    "Domain": "elapora.com",
    "Account": "merill@elapora.com",
    "CurrentVersion": "2.0.0",
    "LatestVersion": "1.0.2",
    "Tests": [
      {
        "TestStatus": "Failed",
        "TestTitle": "Guests should not invite other guests",
        "TestId": "ST0018",
        "TestLikelihood": "HighlyLikely",
        "TestSkipped": "",
        "TestAppliesTo": [
          "Entra"
        ],
        "TestImpact": "Medium",
        "TestResult": "\nTenant allows any user (including other guests) to invite guests.\n",
        "SkippedReason": null,
        "TestTags": [
          "ExternalCollaboration"
        ],
        "TestDescription": "Only users with the Guest Inviter role should be able to invite guest users.\n\nWhy: By only allowing an authorized group of individuals to invite external users to create accounts in the tenant, an agency can enforce a guest user account approval process, reducing the risk of unauthorized account creation.\n\n#### Remediation action:\n\n1. In **Entra ID** and **External Identities**, select **[External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)**.\n2. Under **Guest invite settings**, select **Only users assigned to specific admin roles can invite guest users**.\n3. Click **Save**.\n\n#### Related links\n\n* [Entra admin center - External Identities | External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)\n\n"
      },
      {
        "TestStatus": "Skipped",
        "TestTitle": "Guests should not invite other guests",
        "TestId": "ST0018",
        "TestLikelihood": "Likely",
        "TestSkipped": "",
        "TestAppliesTo": [
          "Entra"
        ],
        "TestImpact": "High",
        "TestResult": "\nTenant allows any user (including other guests) to invite guests.\n",
        "SkippedReason": null,
        "TestTags": [
          "ExternalCollaboration"
        ],
        "TestDescription": "Only users with the Guest Inviter role should be able to invite guest users.\n\nWhy: By only allowing an authorized group of individuals to invite external users to create accounts in the tenant, an agency can enforce a guest user account approval process, reducing the risk of unauthorized account creation.\n\n#### Remediation action:\n\n1. In **Entra ID** and **External Identities**, select **[External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)**.\n2. Under **Guest invite settings**, select **Only users assigned to specific admin roles can invite guest users**.\n3. Click **Save**.\n\n#### Related links\n\n* [Entra admin center - External Identities | External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)\n\n"
      },
      {
        "TestStatus": "Passed",
        "TestTitle": "Guests should not invite other guests",
        "TestId": "ST0018",
        "TestLikelihood": "HighlyLikely",
        "TestSkipped": "",
        "TestAppliesTo": [
          "Entra"
        ],
        "TestImpact": "Low",
        "TestResult": "\nTenant allows any user (including other guests) to invite guests.\n",
        "SkippedReason": null,
        "TestTags": [
          "ExternalCollaboration"
        ],
        "TestDescription": "Only users with the Guest Inviter role should be able to invite guest users.\n\nWhy: By only allowing an authorized group of individuals to invite external users to create accounts in the tenant, an agency can enforce a guest user account approval process, reducing the risk of unauthorized account creation.\n\n#### Remediation action:\n\n1. In **Entra ID** and **External Identities**, select **[External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)**.\n2. Under **Guest invite settings**, select **Only users assigned to specific admin roles can invite guest users**.\n3. Click **Save**.\n\n#### Related links\n\n* [Entra admin center - External Identities | External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)\n\n"
      },
      {
        "TestStatus": "Failed",
        "TestTitle": "Guests should not invite other guests",
        "TestId": "ST0018",
        "TestLikelihood": "HighlyLikely",
        "TestSkipped": "",
        "TestAppliesTo": [
          "Entra"
        ],
        "TestImpact": "High",
        "TestResult": "\nTenant allows any user (including other guests) to invite guests.\n",
        "SkippedReason": null,
        "TestTags": [
          "ExternalCollaboration"
        ],
        "TestDescription": "Only users with the Guest Inviter role should be able to invite guest users.\n\nWhy: By only allowing an authorized group of individuals to invite external users to create accounts in the tenant, an agency can enforce a guest user account approval process, reducing the risk of unauthorized account creation.\n\n#### Remediation action:\n\n1. In **Entra ID** and **External Identities**, select **[External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)**.\n2. Under **Guest invite settings**, select **Only users assigned to specific admin roles can invite guest users**.\n3. Click **Save**.\n\n#### Related links\n\n* [Entra admin center - External Identities | External collaboration settings](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/Settings)\n\n"
      }


    ]
  }
