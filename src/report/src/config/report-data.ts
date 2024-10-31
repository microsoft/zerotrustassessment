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
  EndOfJson: string;
}

export interface TenantInfo {
  OverviewCaMfaAllUsers: SankeyData;
  OverviewCaDevicesAllUsers: SankeyData;
  OverviewAuthMethodsPrivilegedUsers: SankeyData;
  OverviewAuthMethodsAllUsers: SankeyData;
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
  "ExecutedAt": "2024-09-16T20:55:42.757028+10:00",
  "TenantId": "0817c655-a853-4d8f-9723-3a333b5b9235",
  "TenantName": "Pora",
  "Domain": "elapora.com",
  "Account": "merill@elapora.com",
  "CurrentVersion": "1.0.6",
  "LatestVersion": "1.0.2",
  "Tests": [
    {
      "TestStatus": "Failed",
      "TestDescription": "Certificates, if not securely stored, can be extracted and exploited by attackers, leading to unauthorized access. Long-lived certificates are more likely to be exposed over time. Credentials, when exposed, provide attackers with legitimate credentials to blend their activities with legitimate operations, making it easier to bypass security controls. If an attacker compromises an application’s certificate, they can escalate their privileges within the system, leading to broader access and control, depending on the privileges of the application.\n\n#### Remediation\n\n- [Define certificate based application configuration](https://devblogs.microsoft.com/identity/app-management-policy/)\n- [certificateBasedApplicationConfiguration](https://learn.microsoft.com/graph/api/resources/certificatebasedapplicationconfiguration)\n- [Create a the least-privileged custom role to rotate application credentials](https://learn.microsoft.com/entra/identity/role-based-access-control/custom-create) \n\n",
      "TestId": "21773",
      "TestRisk": "High",
      "TestTitle": "Applications don't have certificates with expiration longer than 180 days",
      "TestAppliesTo": [
        "Entra"
      ],
      "TestSkipped": "",
      "TestResult": "\nThe following applications and service principals have certificates longer than 180 days\n\n\n## Applications with long-lived credentials\n\n| Application | Certificate Expiry |\n| :--- | :--- |\n| [PnPPowerShell](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/1d93462e-0f39-4e4c-898a-b6b1df5fa997) | 03/28/2031 13:00:00 |\n| [SharePoint Version App](https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/2bb68591-782c-4c64-9415-bdf9414ae400) | 11/16/2033 13:00:00 |\n\n\n## Service Principals with long-lived credentials\n\n| Service Principal | Tenant | Certificate Expiry |\n| :--- | :--- | :--- |\n| [AWS Single-Account Access](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/dc89bf5d-83e8-4419-9162-3b9280a85755/appId/091edd89-b342-4bb5-9144-82fe6c913987/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | Pora | 10/26/2025 |\n| [Saml test entity id](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/d589a2e6-4a78-4cdd-901b-f574dc7880db/appId/6590313e-1c00-4c07-be28-72858e837a52/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | Pora | 11/17/2025 |\n| [SumoLogic](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/144df581-a0c9-4280-9739-0c3612ab9ccf/appId/1b6c36b2-f2b1-43d3-b74f-8d52c44fc9c1/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | Pora | 02/15/2027 |\n| [test](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/31e80a1b-3faa-4ce9-9794-2b77f61f20f7/appId/8ae2b566-71f5-467e-8960-cfe8da3a2cfa/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/) | Pora | 10/10/2025 |\n\n",
      "TestTags": [
        "Application"
      ],
      "TestImpact": null,
      "TestImplementationCost": "Medium",
      "SkippedReason": null
    }
  ],
  "TenantInfo": {
    "OverviewCaMfaAllUsers": {
      description: "Over the past 7 days, 20% of sign-ins were not protected by any conditional access policies.",
      nodes: [
        {
          "value": 1,
          "target": "No CA applied",
          "source": "User sign in"
        },
        {
          "value": 1244,
          "target": "CA applied",
          "source": "User sign in"
        },
        {
          "value": 0,
          "target": "No MFA",
          "source": "CA applied"
        },
        {
          "value": 1244,
          "target": "MFA",
          "source": "CA applied"
        }
      ]
    },
    "OverviewCaDevicesAllUsers": {
      description: "Over the past 7 days, 20% of sign-ins were from non-compliant.",
      nodes: [
        {
          "value": 70,
          "target": "Unmanaged",
          "source": "User sign in"
        },
        {
          "value": 30,
          "target": "Managed",
          "source": "User sign in"
        },
        {
          "value": 10,
          "target": "Non-compliant",
          "source": "Managed"
        },
        {
          "value": 20,
          "target": "Compliant",
          "source": "Managed"
        }
      ]
    },
    "OverviewAuthMethodsPrivilegedUsers": {
      description: "Strongest authentication method registered by privileged users.",
      nodes: [
        {
          "value": 20,
          "target": "Single factor",
          "source": "Users"
        },
        {
          "value": 40,
          "target": "Phishable",
          "source": "Users"
        },
        {
          "value": 20,
          "target": "Phone",
          "source": "Phishable"
        },
        {
          "value": 20,
          "target": "Authenticator",
          "source": "Phishable"
        },
        {
          "value": 40,
          "target": "Phish resistant",
          "source": "Users"
        },

        {
          "value": 20,
          "target": "Passkey",
          "source": "Phish resistant"
        },
        {
          "value": 20,
          "target": "WHfB",
          "source": "Phish resistant"
        },

      ]
    },
    "OverviewAuthMethodsAllUsers": {
      description: "Strongest authentication method registered by all users.",
      nodes: [
        {
          "value": 10,
          "target": "Single factor",
          "source": "Users"
        },
        {
          "value": 70,
          "target": "Phishable",
          "source": "Users"
        },
        {
          "value": 40,
          "target": "Phone",
          "source": "Phishable"
        },
        {
          "value": 30,
          "target": "Authenticator",
          "source": "Phishable"
        },
        {
          "value": 20,
          "target": "Phish resistant",
          "source": "Users"
        },

        {
          "value": 5,
          "target": "Passkey",
          "source": "Phish resistant"
        },
        {
          "value": 15,
          "target": "WHfB",
          "source": "Phish resistant"
        },

      ]
    }
  },
  "EndOfJson": "EndOfJson"
}
