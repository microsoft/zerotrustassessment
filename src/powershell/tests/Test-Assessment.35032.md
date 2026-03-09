Adaptive Protection in DLP integrates Microsoft Purview Insider Risk Management with Data Loss Prevention policies. This feature uses machine learning to identify users exhibiting risky behaviors (classified as elevated, moderate, or minor risk levels) and automatically applies appropriate DLP controls. Rather than applying uniform DLP policies to all users, Adaptive Protection allows organizations to dynamically enforce stronger protections for high-risk users while maintaining flexibility for normal operations.

For example, when insider risk identifies a user engaging in suspicious data access patterns, DLP policies can automatically enforce stricter rules for that user—blocking external sharing, requiring additional authentication, or logging all activities. Without Adaptive Protection, DLP policies apply the same rules uniformly regardless of user risk profile, missing opportunities to prevent insider threats based on behavioral indicators.

**Remediation action**

To configure Adaptive Protection in DLP policies:

**Prerequisites:**
- Microsoft 365 E5 or E5 Compliance license (Adaptive Protection is a premium feature)
- Insider Risk Management solution must be enabled in your organization
- Global Administrator or Compliance Administrator role

**Via Microsoft Purview Portal:**
1. Sign in as Global Administrator or Compliance Administrator to the [Microsoft Purview portal](https://purview.microsoft.com)
2. Navigate to Data Loss Prevention > Policies
3. Create a new policy or edit an existing one
4. Under "Locations", select the workloads to monitor (Teams, Exchange, OneDrive, Endpoint, etc.)
5. When creating rules, select "Edit rule" and choose advanced conditions
6. In the rule conditions, look for "User is flagged as Insider Risk"
7. Select the risk level(s) to apply this rule to:
   - Elevated Risk: Applies to users flagged with highest risk indicators
   - Moderate Risk: Applies to users with medium-level risk indicators
   - Minor Risk: Applies to users with lower-level risk indicators
8. Configure the rule action (Block, Warn, Audit, Notify, etc.)
9. Save and enable the policy
10. Monitor DLP alerts dashboard to track Adaptive Protection enforcement

**Via PowerShell:**
1. Connect to Compliance & Security PowerShell: `Connect-IPPSSession`
2. Create a DLP policy: `New-DlpCompliancePolicy -Name "Adaptive Protection - Elevated Risk" -Enabled $true`
3. Create a rule with IRM User Risk condition:
   ```powershell
   $AdvancedRule = @'
   {
     "Version": "1.0",
     "Condition": {
       "Operator": "And",
       "SubConditions": [
         {
           "ConditionName": "SharedByIRMUserRisk",
           "Value": ["FCB9FA93-6269-4ACF-A756-832E79B36A2A"]
         }
       ]
     }
   }
   '@
   New-DlpComplianceRule -Name "Block elevated-risk data transfers" -Policy "Adaptive Protection - Elevated Risk" -AdvancedRule $AdvancedRule -BlockAccess $true
   ```
4. Verify configuration: `Get-DlpComplianceRule | Where-Object { $_.AdvancedRule -match "SharedByIRMUserRisk" }`

**Risk Level GUIDs:**
- Elevated: FCB9FA93-6269-4ACF-A756-832E79B36A2A
- Moderate: 797C4446-5C73-484F-8E58-0CCA08D6DF6C
- Minor: 75A4318B-94A2-4323-BA42-2CA6DB29AAFE

- [Adaptive Protection in DLP](https://learn.microsoft.com/en-us/purview/dlp-adaptive-protection-learn)
- [Insider Risk Management](https://learn.microsoft.com/en-us/purview/insider-risk-management)
- [Get-DlpComplianceRule](https://learn.microsoft.com/en-us/powershell/module/exchange/get-dlpcompliancerule)

<!--- Results --->
%TestResult%
