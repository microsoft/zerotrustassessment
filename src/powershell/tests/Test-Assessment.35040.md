Communication Compliance policies configured to monitor enterprise AI app interactions (beyond Microsoft Copilot) enable organizations to detect when users expose sensitive data to custom AI applications, Power Automate flows, AI Builder automations, and third-party AI services. Without Communication Compliance policies configured to capture enterprise AI app interactions, organizations cannot monitor unauthorized data sharing with unvetted AI services, detect when AI applications misuse organizational data, or enforce data protection policies across AI-enabled workflows. Enterprise AI app interaction monitoring through Communication Compliance provides oversight of how sensitive organizational data is being processed by AI systems, whether built internally, purchased from vendors, or accessed through cloud integrations. Users may unknowingly send sensitive data to AI apps that are not approved for handling confidential information, creating compliance violations and data spillage incidents. Organizations must enable Communication Compliance policies targeting enterprise AI app interactions to maintain comprehensive visibility into all AI-assisted data processing and ensure that data protection policies extend to third-party and custom AI services.

**Remediation action**

**Step 1: Enable Collection Policies for Enterprise AI App Data Ingestion**

Collection Policies are a prerequisite - they ingest third-party AI app data into Microsoft systems before Communication Compliance can monitor it:

1. Sign in as a Global Administrator to the [Microsoft Purview portal](https://purview.microsoft.com/cc/overview)
2. Navigate to Communication Compliance > Classifiers > Collection Policies
3. Note: Creating Collection Policies for enterprise AI apps requires pay-as-you-go (PAYG) billing to be enabled
4. Create a Collection Policy targeting Enterprise AI app data sources (requires PAYG billing setup)
5. Configure data detection conditions (classifiers, activities, scope)
6. Once Collection Policy is configured, proceed to Step 2 to set up Communication Compliance monitoring

Learn more: [Microsoft Purview Data Map Collection Policies](https://learn.microsoft.com/en-us/purview/collection-policies-solution-overview)

**Step 2: Create and Enable Communication Compliance Policies for Enterprise AI App Interaction Monitoring**

1. Sign in as a Global Administrator or Compliance Administrator to the [Microsoft Purview Communication Compliance](https://purview.microsoft.com/cc/overview)
2. Navigate to Communication Compliance > Policies
3. Select "+Create policy" to create a new policy for enterprise AI app monitoring
4. Name the policy (e.g., "Enterprise AI App Data Protection")
5. Configure the scope (all users or specific groups with AI app access)
6. On the Conditions page, add conditions to detect enterprise AI app interactions:
   - Use classifiers and sensitive information types relevant to your organization
   - **Important:** When selecting data sources for the policy, explicitly choose "Enterprise AI apps" or similar workflow options (e.g., Power Automate, AI Builder, connected AI app monitoring). This configuration populates the "ConnectedAIApp" and "UnifiedGenAIWorkloads" identifiers in the RuleXml that automation uses to verify enterprise AI targeting.
7. On the Review settings page, configure:
   - Reviewers (compliance team members)
   - Alert volume preference
   - Review mailbox for alerts
8. Enable the policy
9. Verify rule creation and policy status via PowerShell using Query 2 and 3
10. Monitor alerts and adjust detection conditions as needed

Via PowerShell (Collection Policy verification):
- `Connect-ExchangeOnline`
- `Get-FeatureConfiguration -FeatureScenario KnowYourData | Format-List Name, Enabled, Workload, Mode, CreatedBy, ModificationTimeUtc`
- Note: Activities and EnforcementPlanes are nested in ScenarioConfig JSON property

Via PowerShell (Communication Compliance verification):
- `Get-SupervisoryReviewRule -IncludeRuleXml | Select-Object Name, Policy, Identity`
- To verify enterprise AI workload identifiers in rules, examine RuleXml for `textQueryMatch.value` containing: `"Workloads":["ConnectedAIApp"]` and/or `"UnifiedGenAIWorkloads":[...]`
- `Get-SupervisoryReviewPolicyV2 | Where-Object { $_.Enabled -eq $true -and $_.ReviewMailbox -ne $null } | Select-Object Name, Enabled, ReviewMailbox`

For more information:
- [Purview Data Map and Collection Policies](https://learn.microsoft.com/en-us/purview/collection-policies-solution-overview)
- [Create Communication Compliance policies](https://learn.microsoft.com/en-us/purview/communication-compliance-policies)
- [Communication Compliance conditions and scenarios](https://learn.microsoft.com/en-us/purview/communication-compliance-conditions-scenarios)
- [SupervisoryReview cmdlet reference](https://learn.microsoft.com/en-us/powershell/module/exchange/get-supervisoryreviewpolicyv2)

<!--- Results --->
%TestResult%
