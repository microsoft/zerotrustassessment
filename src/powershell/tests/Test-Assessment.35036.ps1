<#
.SYNOPSIS
    Trainable classifiers are used in data loss prevention and auto-labeling policies

.DESCRIPTION
    This test checks if trainable classifiers are being used in policies by:
    1. Retrieving all auto-sensitivity label rules and searching for trainable classifiers in AdvancedRule
    2. Retrieving all DLP compliance rules and searching for trainable classifiers in AdvancedRule
    3. Parsing AdvancedRule JSON to extract classifier details (identified by Classifiertype=MLModel)

.NOTES
    Test ID: 35036
    Category: Advanced Classification
    Required Module: ExchangeOnlineManagement v3.5.1+
    Required Connection: Connect-IPPSSession
#>

function Test-Assessment-35036 {
    [ZtTest(
        Category = 'Advanced Classification',
        ImplementationCost = 'High',
        MinimumLicense = 'Microsoft 365 E5',
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce', 'External'),
        TestId = 35036,
        Title = 'Trainable classifiers are used in data loss prevention and auto-labeling policies',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking trainable classifier usage in policies'
    Write-ZtProgress -Activity $activity -Status 'Querying auto-labeling and DLP rules'

    $autoLabelCmdletFailed = $false
    $dlpCmdletFailed = $false
    $autoLabelRulesWithClassifiers = @()
    $dlpRulesWithClassifiers = @()

    # Query 1 & 2: Get auto-sensitivity label rules with trainable classifiers
    try {
        Write-ZtProgress -Activity $activity -Status 'Checking auto-labeling rules'
        $allAutoLabelRules = Get-AutoSensitivityLabelRule -ErrorAction Stop

        # Filter rules that contain trainable classifiers (MLModel in AdvancedRule)
        $rulesWithMLModel = $allAutoLabelRules | Where-Object { $_.AdvancedRule -match 'MLModel' }

        foreach ($rule in $rulesWithMLModel) {
            try {
                # Parse AdvancedRule JSON to extract classifier details
                $advancedRule = $rule.AdvancedRule | ConvertFrom-Json -ErrorAction Stop

                # Navigate to ContentContainsSensitiveInformation condition
                $sensitiveInfoCondition = $advancedRule.Condition.SubConditions | Where-Object {
                    $_.ConditionName -eq 'ContentContainsSensitiveInformation'
                }

                if ($sensitiveInfoCondition) {
                    # Extract trainable classifiers from Groups (Value is an array)
                    $trainableClassifiers = @()
                    foreach ($valueItem in $sensitiveInfoCondition.Value) {
                        foreach ($group in $valueItem.Groups) {
                            # Check all groups regardless of name (could be "Default", "Trainable Classifiers", etc.)
                            foreach ($classifier in $group.Sensitivetypes) {
                                if ($classifier.Classifiertype -eq 'MLModel') {
                                    $trainableClassifiers += $classifier.Name
                                }
                            }
                        }
                    }

                    if ($trainableClassifiers.Count -gt 0) {
                        # Deduplicate classifier names
                        $uniqueClassifiers = $trainableClassifiers | Select-Object -Unique
                        $autoLabelRulesWithClassifiers += [PSCustomObject]@{
                            RuleName          = $rule.Name
                            ParentPolicyName  = $rule.ParentPolicyName
                            CreatedDate       = $rule.WhenCreatedUTC
                            Classifiers       = $uniqueClassifiers
                        }
                    }
                }
            }
            catch {
                Write-PSFMessage "Failed to parse AdvancedRule for auto-labeling rule '$($rule.Name)': $_" -Tag Test -Level Warning

                # Fallback: this rule matched 'MLModel' via string search, so record it even if JSON parsing failed
                $autoLabelRulesWithClassifiers += [PSCustomObject]@{
                    RuleName          = $rule.Name
                    ParentPolicyName  = $rule.ParentPolicyName
                    CreatedDate       = $rule.WhenCreatedUTC
                    Classifiers       = @('Unknown (AdvancedRule parse failed)')
                }
            }
        }
    }
    catch {
        $autoLabelCmdletFailed = $true
        Write-PSFMessage "Failed to retrieve auto-sensitivity label rules: $_" -Tag Test -Level Warning
    }

    # Query 3 & 4: Get DLP compliance rules with trainable classifiers
    try {
        Write-ZtProgress -Activity $activity -Status 'Checking DLP rules'
        $allDlpRules = Get-DlpComplianceRule -ErrorAction Stop

        # Filter rules that contain trainable classifiers (MLModel in AdvancedRule)
        $rulesWithMLModel = $allDlpRules | Where-Object { $_.AdvancedRule -match 'MLModel' }

        foreach ($rule in $rulesWithMLModel) {
            try {
                # Parse AdvancedRule JSON to extract classifier details
                $advancedRule = $rule.AdvancedRule | ConvertFrom-Json -ErrorAction Stop

                # Navigate to ContentContainsSensitiveInformation condition
                $sensitiveInfoCondition = $advancedRule.Condition.SubConditions | Where-Object {
                    $_.ConditionName -eq 'ContentContainsSensitiveInformation'
                }

                if ($sensitiveInfoCondition) {
                    # Extract trainable classifiers from Groups (Value is an array)
                    $trainableClassifiers = @()
                    foreach ($valueItem in $sensitiveInfoCondition.Value) {
                        foreach ($group in $valueItem.Groups) {
                            # Check all groups regardless of name (could be "Default", "Trainable Classifiers", etc.)
                            foreach ($classifier in $group.Sensitivetypes) {
                                if ($classifier.Classifiertype -eq 'MLModel') {
                                    $trainableClassifiers += $classifier.Name
                                }
                            }
                        }
                    }

                    if ($trainableClassifiers.Count -gt 0) {
                        # Deduplicate classifier names
                        $uniqueClassifiers = $trainableClassifiers | Select-Object -Unique
                        $dlpRulesWithClassifiers += [PSCustomObject]@{
                            RuleName          = $rule.Name
                            ParentPolicyName  = $rule.ParentPolicyName
                            CreatedDate       = $rule.WhenCreatedUTC
                            Classifiers       = $uniqueClassifiers
                        }
                    }
                }
            }
            catch {
                Write-PSFMessage "Failed to parse AdvancedRule for DLP rule '$($rule.Name)': $_" -Tag Test -Level Warning

                # Fallback: this rule matched 'MLModel' via string search, so record it even if JSON parsing failed
                $dlpRulesWithClassifiers += [PSCustomObject]@{
                    RuleName          = $rule.Name
                    ParentPolicyName  = $rule.ParentPolicyName
                    CreatedDate       = $rule.WhenCreatedUTC
                    Classifiers       = @('Unknown (AdvancedRule parse failed)')
                }
            }
        }
    }
    catch {
        $dlpCmdletFailed = $true
        Write-PSFMessage "Failed to retrieve DLP compliance rules: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null

    $totalRulesWithClassifiers = $autoLabelRulesWithClassifiers.Count + $dlpRulesWithClassifiers.Count

    # Check if both cmdlets failed
    if ($autoLabelCmdletFailed -and $dlpCmdletFailed) {
        $testResultMarkdown = "⚠️ Unable to determine trainable classifier usage due to permissions issues or service connection failure.`n`n%TestResult%"
        $passed = $false
        $customStatus = 'Investigate'
    }
    # Check if one cmdlet failed but we have some results
    elseif ($autoLabelCmdletFailed -or $dlpCmdletFailed) {
        $failedQuery = if ($autoLabelCmdletFailed) { 'auto-labeling rules' } else { 'DLP rules' }
        $testResultMarkdown = "⚠️ Unable to retrieve $failedQuery due to query failure, connection issues, or insufficient permissions.`n`n%TestResult%"
        $passed = if ($totalRulesWithClassifiers -gt 0) { $true } else { $false }
        $customStatus = 'Investigate'
    }
    # Check if any rules use trainable classifiers
    elseif ($totalRulesWithClassifiers -eq 0) {
        $testResultMarkdown = "❌ No trainable classifiers are being used in auto-labeling or DLP policies; relying solely on pattern-based classification.`n`n%TestResult%"
        $passed = $false
    }
    else {
        $testResultMarkdown = "✅ Trainable classifiers are integrated into auto-labeling and/or DLP policies, enabling AI-powered content classification for complex business documents.`n`n%TestResult%"
        $passed = $true
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($totalRulesWithClassifiers -gt 0) {
        $formatTemplate = @'

## [{0}]({1})

{2}

**Summary:**
* Total Auto-Labeling Rules Using Classifiers: {3}
* Total DLP Rules Using Classifiers: {4}

'@

        $reportTitle = 'Trainable Classifier Usage in Policies'
        $portalLink = 'https://purview.microsoft.com/informationprotection/dataclassification/trainableclassifiers'

        # Build details section
        $details = ''

        # Auto-Labeling Rules
        if ($autoLabelRulesWithClassifiers.Count -gt 0) {
            $details += "**Trainable Classifiers in Auto-Labeling Rules:**`n`n"
            $details += "| Rule name | Parent policy | Created date | Classifiers in rule |`n"
            $details += "| :-------- | :------------ | :----------- | :------------------ |`n"

            foreach ($rule in $autoLabelRulesWithClassifiers) {
                $ruleName = if ($rule.RuleName) { Get-SafeMarkdown -Text $rule.RuleName } else { 'N/A' }
                $policyName = if ($rule.ParentPolicyName) { Get-SafeMarkdown -Text $rule.ParentPolicyName } else { 'N/A' }
                $createdDate = if ($rule.CreatedDate) { $rule.CreatedDate.ToString('yyyy-MM-dd') } else { 'N/A' }

                if ($rule.Classifiers) {
                    $sanitizedClassifiers = $rule.Classifiers | ForEach-Object { Get-SafeMarkdown -Text $_ }
                    if (@($sanitizedClassifiers).Count -gt 5) {
                        $classifiers = ($sanitizedClassifiers[0..4] -join ', ') + ', ...'
                    }
                    else {
                        $classifiers = $sanitizedClassifiers -join ', '
                    }
                }
                else {
                    $classifiers = 'N/A'
                }

                $details += "| $ruleName | $policyName | $createdDate | $classifiers |`n"
            }
            $details += "`n"
        }

        # DLP Rules
        if ($dlpRulesWithClassifiers.Count -gt 0) {
            $details += "**Trainable Classifiers in DLP Rules:**`n`n"
            $details += "| Rule name | Parent policy | Created date | Classifiers in rule |`n"
            $details += "| :-------- | :------------ | :----------- | :------------------ |`n"

            foreach ($rule in $dlpRulesWithClassifiers) {
                $ruleName = if ($rule.RuleName) { Get-SafeMarkdown -Text $rule.RuleName } else { 'N/A' }
                $policyName = if ($rule.ParentPolicyName) { Get-SafeMarkdown -Text $rule.ParentPolicyName } else { 'N/A' }
                $createdDate = if ($rule.CreatedDate) { $rule.CreatedDate.ToString('yyyy-MM-dd') } else { 'N/A' }

                if ($rule.Classifiers) {
                    $sanitizedClassifiers = $rule.Classifiers | ForEach-Object { Get-SafeMarkdown -Text $_ }
                    if (@($sanitizedClassifiers).Count -gt 5) {
                        $classifiers = ($sanitizedClassifiers[0..4] -join ', ') + ', ...'
                    }
                    else {
                        $classifiers = $sanitizedClassifiers -join ', '
                    }
                }
                else {
                    $classifiers = 'N/A'
                }

                $details += "| $ruleName | $policyName | $createdDate | $classifiers |`n"
            }
            $details += "`n"
        }

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $details,
            $autoLabelRulesWithClassifiers.Count,
            $dlpRulesWithClassifiers.Count
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35036'
        Title  = 'Trainable Classifiers Usage in Policies'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
