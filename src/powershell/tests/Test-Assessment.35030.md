Data Loss Prevention (DLP) policies protect sensitive information by monitoring, detecting, and preventing the sharing of confidential data across Microsoft 365 workloads including Exchange Online, SharePoint Online, OneDrive, and Microsoft Teams.

When DLP policies are not enabled or configured, organizations lack automated controls to prevent accidental or intentional disclosure of sensitive information such as credit card numbers, social security numbers, financial data, or proprietary information. Without active DLP policies, employees can freely share sensitive content through email, file uploads, or team communications without organizational oversight, increasing the risk of data breaches, regulatory violations (GDPR, HIPAA, PCI-DSS), and reputational damage. 

Enabling and configuring at least one DLP policy ensures organizations have automated detection and response capabilities for sensitive data, reducing the risk of unauthorized data exfiltration and demonstrating compliance readiness to regulators and auditors.

**Remediation action**

To create and enable DLP policies:

1. Sign in as a Global Administrator or Compliance Administrator to the [Microsoft Purview portal](https://purview.microsoft.com)
2. Navigate to Data Loss Prevention > Policies
3. Select "+ Create policy" to start a new DLP policy
4. Choose a template (Financial data, Health data, Privacy, Custom, etc.) or create a custom policy
5. Define sensitive information types (SITs) to detect (credit card numbers, SSN, bank account numbers, etc.)
6. Configure rule conditions (locations, conditions for detection, scope)
7. Set enforcement actions (notify users, restrict access, block sharing, etc.)
8. Choose enforcement mode:
   - Test mode (audit-only): Monitors but does not block activities
   - Enforce mode: Blocks activities matching policy rules
9. Enable the policy and deploy to workloads (Exchange, SharePoint, OneDrive, Teams)
10. Monitor DLP alerts and adjust rules as needed

Alternatively, create via PowerShell:
1. Connect to Exchange Online: `Connect-ExchangeOnline`
2. Create a policy: `New-DlpCompliancePolicy -Name "Sensitive Data Protection" -Mode "Enforce"`
3. Add rules to the policy: `New-DlpComplianceRule -Name "Block SSN" -Policy "Sensitive Data Protection"`
4. Enable and test: `Get-DlpCompliancePolicy | Select-Object -Property Name, Enabled`

- [Create and configure DLP policies](https://learn.microsoft.com/en-us/purview/dlp-create-deploy-policy)
- [DLP policy templates](https://learn.microsoft.com/en-us/purview/dlp-policy-templates)
- [DLP Compliance Rules](https://learn.microsoft.com/en-us/powershell/module/exchange/new-dlpcompliancerule)
<!--- Results --->
%TestResult%
