<#
.SYNOPSIS
    Validates that Communication Compliance rules are configured to monitor enterprise AI app interactions.

.DESCRIPTION
    This test verifies that Collection Policies are configured for data ingestion, Communication Compliance
    rules targeting enterprise AI apps (ConnectedAIApp and/or UnifiedGenAIWorkloads) are properly configured,
    and at least one enabled policy with ReviewMailbox exists for alert processing.

.NOTES
    Test ID: 35040
    Category: Data Security Posture Management
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Security & Compliance PowerShell
#>

function Test-Assessment-35040 {
    [ZtTest(
        Category = 'Data Security Posture Management',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35040,
        Title = 'Communication compliance monitoring is configured for enterprise AI tools',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Communication Compliance for Enterprise AI Apps'

    # Q1: Verify Collection Policies are configured for enterprise AI app data ingestion
    Write-ZtProgress -Activity $activity -Status 'Checking Collection Policies'

    $collectionPolicies = @()
    $errorMsg = $null

    try {
        $featureConfig = Get-FeatureConfiguration -FeatureScenario KnowYourData -ErrorAction Stop

        if ($featureConfig) {
            foreach ($config in $featureConfig) {
                $activities = @()
                $enforcementPlanes = @()

                if ($config.ScenarioConfig) {
                    try {
                        $scenarioData = $config.ScenarioConfig | ConvertFrom-Json -ErrorAction Stop
                        if ($scenarioData.Activities) {
                            $activities = $scenarioData.Activities
                        }
                        if ($scenarioData.EnforcementPlanes) {
                            $enforcementPlanes = $scenarioData.EnforcementPlanes
                        }
                    }
                    catch {
                        Write-PSFMessage "Error parsing ScenarioConfig JSON: $_" -Level Warning
                    }
                }

                $collectionPolicies += [PSCustomObject]@{
                    PolicyName        = $config.Name
                    Enabled           = $config.Enabled
                    Mode              = $config.Mode
                    Workload          = $config.Workload
                    Activities        = $activities
                    EnforcementPlanes = $enforcementPlanes
                    CreatedBy         = $config.CreatedBy
                    ModifiedTime      = $config.ModificationTimeUtc.ToString("yyyy-MM-ddTHH:mm:ss")
                    PolicyCategory    = "ApplicableToAI"
                }
            }
        }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve Collection Policies: $_" -Tag Test -Level Warning
    }

    # Q2: Get all Communication Compliance rules and identify those targeting enterprise AI apps
    Write-ZtProgress -Activity $activity -Status 'Analyzing Communication Compliance rules'

    $enterpriseAIRules = @()

    if ($collectionPolicies -and -not $errorMsg) {
        try {
            $allRules = Get-SupervisoryReviewRule -IncludeRuleXml -ErrorAction Stop
            $allReviewPolicy = Get-SupervisoryReviewPolicyV2 -ErrorAction Stop

            $policyMap = @{}
            if ($allReviewPolicy) {
                $allReviewPolicy | ForEach-Object { $policyMap[$_.Guid] = $_.Name }
            }

            foreach ($rule in $allRules) {
                if (-not [string]::IsNullOrWhiteSpace($rule.RuleXml)) {
                    try {
                        # Wrap RuleXml in a root element to handle multiple rule elements
                        $wrappedXml = "<root>$($rule.RuleXml)</root>"
                        $ruleXml = [xml]$wrappedXml
                        $hasEnterpriseAIConfig = $false
                        $detectedWorkloads = @()
                        $detectedUnifiedGenAIWorkloads = @()

                        # Check for ConnectedAIApp and UnifiedGenAIWorkloads in JSON value elements
                        if ($ruleXml.root) {
                            $valueElements = $ruleXml.root.GetElementsByTagName('value')
                            foreach ($valueElement in $valueElements) {
                                $rawValue = $valueElement.'#text'
                                if (-not [string]::IsNullOrWhiteSpace($rawValue)) {
                                    try {
                                        $jsonText = $rawValue.Trim()

                                        # We only need object/array JSON payloads
                                        if ($jsonText -notmatch '^[\{\[]') {
                                            continue
                                        }

                                        $jsonData = $jsonText | ConvertFrom-Json -ErrorAction Stop

                                        # Check for ConnectedAIApp in Workloads
                                        if ($jsonData.Workloads -and $jsonData.Workloads -contains 'ConnectedAIApp') {
                                            $hasEnterpriseAIConfig = $true
                                            $detectedWorkloads = $jsonData.Workloads
                                        }

                                        # Check for "ChatGPT.Enterprise", "EntraApp", "AzureAI" keywords in UnifiedGenAIWorkloads
                                        $targetWorkloads = @('ChatGPT.Enterprise', 'EntraApp', 'AzureAI')
                                        if ($jsonData.UnifiedGenAIWorkloads -and ($jsonData.UnifiedGenAIWorkloads | Where-Object { $targetWorkloads -contains $_ })) {
                                            $hasEnterpriseAIConfig = $true
                                            $detectedUnifiedGenAIWorkloads = $jsonData.UnifiedGenAIWorkloads
                                        }

                                        if ($hasEnterpriseAIConfig) {
                                            break
                                        }
                                    }
                                    catch {
                                        # Skip if JSON parsing fails
                                    }
                                }
                            }
                        }

                        if ($hasEnterpriseAIConfig) {
                            # Extract rule names from RuleXml structure
                            $ruleNames = @()
                            $ruleElements = $ruleXml.root.GetElementsByTagName('rule')
                            foreach ($ruleElement in $ruleElements) {
                                if ($ruleElement.name) {
                                    $ruleNames += $ruleElement.name
                                }
                            }
                            $ruleNameDisplay = if ($ruleNames.Count -gt 0) { $ruleNames -join ', ' } else { $rule.Name }

                            # Lookup policy name from $allReviewPolicy using Policy ID
                            $policyId = $rule.Policy
                            $policyName = if ($policyMap.ContainsKey($policyId)) { $policyMap[$policyId] } else { 'Unknown' }

                            $enterpriseAIRules += [PSCustomObject]@{
                                RuleName             = $ruleNameDisplay
                                PolicyId             = $policyId
                                PolicyName           = $policyName
                                Workloads            = $detectedWorkloads
                                UnifiedGenAIWorkloads = $detectedUnifiedGenAIWorkloads
                            }
                        }
                    }
                    catch {
                        Write-PSFMessage "Error parsing RuleXml for rule '$($rule.Name)': $_" -Level Warning
                    }
                }
            }
        }
        catch {
            Write-PSFMessage "Failed to retrieve supervisory review rules: $_" -Tag Test -Level Warning
        }
    }

    # Q3: Get enabled Communication Compliance policies with ReviewMailbox configured
    Write-ZtProgress -Activity $activity -Status 'Checking enabled policies'

    $enabledPoliciesWithReviewMailbox = @()

    if ($enterpriseAIRules -and -not $errorMsg) {
        $enabledPoliciesWithReviewMailbox = $allReviewPolicy | Where-Object {
            $_.Enabled -eq $true -and $null -ne $_.ReviewMailbox
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    # Evaluation logic:
    # - Investigate if there was an error during data collection
    # - Fail if no Collection Policies are configured or policies are disabled
    # - Fail if no Communication Compliance rules target enterprise AI apps
    # - Fail if no enabled policies with ReviewMailbox exist
    # - Pass if Collection Policies are configured, rules target enterprise AI apps, and at least one enabled policy with ReviewMailbox exists

    if ($errorMsg) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine enterprise AI monitoring status due to error:`n`n$errorMsg`n`n%TestResult%"
    }
    else {
        $hasActiveCollectionPolicies = ($collectionPolicies | Where-Object { $_.Enabled -eq $true -and $_.Activities.Count -ge 1 }).Count -ge 1
        $hasEnterpriseAIRules = $enterpriseAIRules.Count -ge 1
        $hasEnabledPoliciesWithReviewMailbox = $enabledPoliciesWithReviewMailbox.Count -ge 1

        if (-not $hasActiveCollectionPolicies) {
            $passed = $false
            $testResultMarkdown = "❌ No enabled collection policies found for data ingestion.`n`n%TestResult%"
        }
        elseif (-not $hasEnterpriseAIRules) {
            $passed = $false
            $testResultMarkdown = "❌ No Communication Compliance rules targeting enterprise AI apps were found.`n`n%TestResult%"
        }
        elseif (-not $hasEnabledPoliciesWithReviewMailbox) {
            $passed = $false
            $testResultMarkdown = "❌ No Communication Compliance policies are enabled with ReviewMailbox configured, creating a gap where enterprise AI data exposure and policy violations cannot be detected and investigated.`n`n%TestResult%"
        }
        else {
            $passed = $true
            $testResultMarkdown = "✅ Collection Policies are configured for data ingestion, Communication Compliance rules are configured to target enterprise AI apps (ConnectedAIApp and/or UnifiedGenAIWorkloads identified in RuleXml), AND at least one Communication Compliance policy is ENABLED with a ReviewMailbox configured, enabling the organization to detect and investigate unauthorized data sharing and policy violations through enterprise AI interactions.`n`n%TestResult%"
        }
    }

    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''
    if(-not $errorMsg){

        # Portal Links
        $tenantId = (Get-MgContext).TenantId
        $collectionPoliciesLink = "https://purview.microsoft.com/cc/dataclassification/dataandactivitydiscovery?tid=$tenantId"
        $compliancePoliciesLink = "https://purview.microsoft.com/cc/policies?tid=$tenantId"

        # Build Collection Policies table rows
        $collectionTableRows = ''
        if ($collectionPolicies.Count -gt 0) {
            foreach ($policy in $collectionPolicies | Sort-Object PolicyName) {
                $enabledStatus = if ($policy.Enabled) { '✅ True' } else { '❌ False' }
                $modeStatus = if ($policy.Mode -eq 'Enable') { '✅ Enable' } else { '❌ Disable' }
                $activitiesDisplay = if ($policy.Activities.Count -gt 0) { ($policy.Activities -join ', ') } else { 'None' }
                $enforcementDisplay = if ($policy.EnforcementPlanes.Count -gt 0) { ($policy.EnforcementPlanes -join ', ') } else { 'None' }
                $modifiedDisplay = Get-FormattedDate -DateString $policy.ModifiedTime

                $collectionTableRows += "| $($policy.PolicyName) | $enabledStatus | $modeStatus | $($policy.Workload) | $activitiesDisplay | $enforcementDisplay | $($policy.CreatedBy) | $modifiedDisplay | $($policy.PolicyCategory) |`n"
            }
        }

        # Build Enterprise AI Rules table rows
        $rulesTableRows = ''
        if ($enterpriseAIRules.Count -gt 0) {
            foreach ($rule in $enterpriseAIRules | Sort-Object RuleName) {
                $workloadsDisplay = if ($rule.Workloads.Count -gt 0) { $rule.Workloads -join ', ' } else { 'None' }
                $unifiedGenAIDisplay = if ($rule.UnifiedGenAIWorkloads.Count -gt 0) { $rule.UnifiedGenAIWorkloads -join ', ' } else { 'None' }

                $rulesTableRows += "| $($rule.RuleName) | $($rule.PolicyName) | $workloadsDisplay | $unifiedGenAIDisplay |`n"
            }
        }

        # Build Enabled Policies table rows
        $policiesTableRows = ''
        if ($enabledPoliciesWithReviewMailbox.Count -gt 0) {
            foreach ($policy in $enabledPoliciesWithReviewMailbox | Sort-Object Name) {
                $enabledStatus = if ($policy.Enabled -eq $true) { '✅ True' } else { '❌ False' }
                $reviewMailbox = if ($policy.ReviewMailbox) { "✅ $($policy.ReviewMailbox)" } else { '❌ Not configured' }

                $policiesTableRows += "| $($policy.Name) | $enabledStatus | $reviewMailbox |`n"
            }
        }

        # Build Collection Policies section
        $collectionSection = ''
        if ($collectionPolicies.Count -gt 0) {
            $collectionSection = @"

### [Data ingestion layer (Collection policies)]($collectionPoliciesLink)

| Policy name | Enabled | Mode | Workload | Activities | Enforcement planes | Created by | Last modified | Policy category |
| :---------- | :------ | :--- | :------- | :--------- | :----------------- | :--------- | :------------ | :-------------- |
$collectionTableRows
"@
        }

        # Build Enterprise AI Rules section
        # Always show this section when Q2 ran (no error and collection policies exist)
        $rulesSection = ''
        if ($collectionPolicies.Count -gt 0) {
            if ($enterpriseAIRules.Count -gt 0) {
                $rulesSection = @"

### [Communication Compliance rules targeting Enterprise AI Apps]($compliancePoliciesLink)

| Rule name | Associated policy | Workloads | UnifiedGenAIWorkloads |
| :-------- | :---------------- | :-------- | :-------------------- |
$rulesTableRows
"@
        } else {
            $rulesSection = @"

### [Communication Compliance rules targeting Enterprise AI Apps]($compliancePoliciesLink)

No Enterprise AI rules found.
"@
        }
    }

        # Build Enabled Policies section
        $policiesSection = ''
        if ($enabledPoliciesWithReviewMailbox.Count -gt 0) {
            $policiesSection = @"

### [Enabled policies with review mailbox]($compliancePoliciesLink)

| Policy name | Enabled | Review mailbox |
| :---------- | :------ | :------------- |
$policiesTableRows
"@
    } else {
            $policiesSection = @"

### [Enabled policies with review mailbox]($compliancePoliciesLink)

No enabled policies with review mailbox configured were found.
"@
        }

        $formatTemplate = @'
{0}{1}{2}

**Summary:**
- Collection Policies Configured: {3}
- Enterprise AI Rules Detected (with ConnectedAIApp or UnifiedGenAIWorkloads): {4}
- Policies Enabled with ReviewMailbox: {5}
'@

        $mdInfo = $formatTemplate -f $collectionSection, $rulesSection, $policiesSection, $collectionPolicies.Count, $enterpriseAIRules.Count, $enabledPoliciesWithReviewMailbox.Count
    }
    # Replace placeholder with generated markdown
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '35040'
        Title  = 'Communication compliance monitoring is configured for enterprise AI tools'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
