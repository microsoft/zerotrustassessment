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
  TestRisk:  string;
  TestAppliesTo:   string[];
  TestImpact:      string;
  TestImplementationCost: string;
  SkippedReason:   null;
  TestResult:      string;
  TestSkipped:     string;
  TestStatus:      string;
  TestTags:        string[];
  TestId:          string;
  TestDescription: string;
}

export const reportData: ZeroTrustAssessmentReport = {
  "ExecutedAt": "2024-09-12T19:39:37.667906+10:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "1.0.6",
  "LatestVersion": "1.0.2",
  "Tests": [
    {
      "TestStatus": "Passed",
      "TestDescription": " Attackers might exploit valid but dormant applications that still have high privileges. These applications can be used to gain initial access without raising alarm because they're legitimate applications. From there, attackers can use the application privileges to plan or execute other attacks. Attackers might also maintain access by manipulating the dormant application, such as by adding credentials. This persistence ensures that even if their primary access method is detected, they can regain access later.\n\n#### Remediation\n\n- Disable privileged Service Principals  \n  - [Update serviceprincipal - Microsoft Graph v1.0](https://learn.microsoft.com/graph/api/serviceprincipal-update?view=graph-rest-1.0&tabs=http)\n- Investigate if the application has legitimate use cases\n- If service principal does not have  legitimate usage, delete it\n  - [Delete servicePrincipal - Microsoft Graph v1.0](https://learn.microsoft.com/graph/api/serviceprincipal-delete?view=graph-rest-1.0&tabs=http)\n\n",
      "TestId": "21770",
      "TestRisk": "High",
      "TestTitle": "Inactive applications don't have highly privileged permissions",
      "TestAppliesTo": [
        "Entra"
      ],
      "TestSkipped": "",
      "TestResult": "\nNo inactive applications with high privileges\n",
      "TestTags": [
        "Application"
      ],
      "TestImpact": "High",
      "TestImplementationCost": "Low",
      "SkippedReason": null
    }
  ],
  "TenantInfo": {},
  "EndOfJson": "EndOfJson"
}
