<#
.SYNOPSIS
    Named entity sensitive information types are used in auto-labeling and data loss prevention policies

.DESCRIPTION
    This test evaluates whether the organization has deployed Named Entity Sensitive
    Information Types (SITs) in auto-labeling policies or DLP rules. Named Entity SITs
    are pre-built, Microsoft-managed classifiers designed to detect common sensitive
    entities like people's names, physical addresses, and medical terminology.

.NOTES
    Test ID: 35035
    Category: Advanced Classification
    Pillar: Data
    Risk Level: High
#>

function Test-Assessment-35035 {
    [ZtTest(
        Category = 'Advanced Classification',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35035,
        Title = 'Named entity sensitive information types are used in auto-labeling and data loss prevention policies',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions

    function Get-NamedEntitySitsFromRule {
        <#
        .SYNOPSIS
            Extracts Named Entity SITs from an AdvancedRule JSON property using ID-based matching.
        .DESCRIPTION
            Parses the AdvancedRule JSON and checks SIT IDs against the Named Entity SIT catalog
            (Classifier -eq "EntityMatch"). This approach is future-proof as new Named Entity SITs
            are automatically detected.
        .OUTPUTS
            Array of PSCustomObjects with Name and Id of Named Entity SITs found in the rule.
        #>
        param(
            [Parameter(Mandatory = $false)]
            [AllowNull()]
            [AllowEmptyString()]
            [string]$AdvancedRuleJson,

            [Parameter(Mandatory = $true)]
            [AllowEmptyCollection()]
            [array]$NamedEntitySitIds,

            [Parameter(Mandatory = $false)]
            [string]$RuleName = 'Unknown',

            [Parameter(Mandatory = $false)]
            [ValidateSet('AutoLabeling', 'DLP')]
            [string]$RuleType = 'AutoLabeling'
        )

        $namedEntitySits = @()

        if ([string]::IsNullOrWhiteSpace($AdvancedRuleJson)) {
            return $namedEntitySits
        }

        if ($NamedEntitySitIds.Count -eq 0) {
            return $namedEntitySits
        }

        try {
            $advancedRule = $AdvancedRuleJson | ConvertFrom-Json -ErrorAction Stop

            # Navigate to SubConditions
            $subConditions = $advancedRule.Condition.SubConditions
            if (-not $subConditions) {
                return $namedEntitySits
            }

            foreach ($subCondition in $subConditions) {
                # Only process ContentContainsSensitiveInformation conditions
                if ($subCondition.ConditionName -ne 'ContentContainsSensitiveInformation') {
                    continue
                }

                $values = $subCondition.Value
                if (-not $values) {
                    continue
                }

                if ($RuleType -eq 'AutoLabeling') {
                    # Auto-labeling: Grouped structure - Value[].Groups[].Sensitivetypes[]
                    foreach ($value in $values) {
                        if ($value.Groups) {
                            foreach ($group in $value.Groups) {
                                if ($group.Sensitivetypes) {
                                    foreach ($sit in $group.Sensitivetypes) {
                                        if ($sit.id -and $sit.id -in $NamedEntitySitIds) {
                                            $namedEntitySits += [PSCustomObject]@{
                                                Name = $sit.name
                                                Id   = $sit.id
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    # DLP: Nested structure - Value[0].groups[].sensitivetypes[]
                    if ($values -and $values[0].groups) {
                        foreach ($group in $values[0].groups) {
                            if ($group.sensitivetypes) {
                                foreach ($sit in $group.sensitivetypes) {
                                    if ($sit.id -and $sit.id -in $NamedEntitySitIds) {
                                        $namedEntitySits += [PSCustomObject]@{
                                            Name = $sit.name
                                            Id   = $sit.id
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch {
            Write-PSFMessage "Error parsing AdvancedRule JSON for rule '$RuleName': $_" -Level Warning
            throw
        }

        # Return unique SITs by Id
        return $namedEntitySits | Sort-Object -Property Id -Unique
    }

    #endregion Helper Functions

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating Named Entity SIT usage in policies'
    Write-ZtProgress -Activity $activity -Status 'Building Named Entity SIT catalog lookup'

    $namedEntitySitIds = @()
    $autoLabelRules = @()
    $dlpRules = @()
    $queryError = $null
    $catalogError = $null

    # Build lookup of Named Entity SIT IDs from catalog (Classifier -eq "EntityMatch")
    try {
        $namedEntitySits = Get-DlpSensitiveInformationType -ErrorAction Stop | Where-Object { $_.Classifier -eq 'EntityMatch' }
        $namedEntitySitIds = @($namedEntitySits.Id)
        Write-PSFMessage "Built Named Entity SIT catalog with $($namedEntitySitIds.Count) SITs" -Level Verbose
    }
    catch {
        Write-PSFMessage "Error building Named Entity SIT catalog: $_" -Level Warning
        $catalogError = $_
    }

    # Q1: Get all auto-sensitivity label rules
    Write-ZtProgress -Activity $activity -Status 'Retrieving auto-labeling rules'
    try {
        $autoLabelRules = Get-AutoSensitivityLabelRule -ErrorAction Stop
        Write-PSFMessage "Retrieved $($autoLabelRules.Count) auto-labeling rules" -Level Verbose
    }
    catch {
        Write-PSFMessage "Error retrieving auto-labeling rules: $_" -Level Warning
        $queryError = $_
    }

    # Q2: Get all DLP compliance rules
    Write-ZtProgress -Activity $activity -Status 'Retrieving DLP compliance rules'
    try {
        $dlpRules = Get-DlpComplianceRule -ErrorAction Stop
        Write-PSFMessage "Retrieved $($dlpRules.Count) DLP rules" -Level Verbose
    }
    catch {
        Write-PSFMessage "Error retrieving DLP rules: $_" -Level Warning
        if (-not $queryError) {
            $queryError = $_
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passed = $false
    $customStatus = $null
    $testResultMarkdown = ''

    $autoLabelRulesWithNamedEntity = @()
    $dlpRulesWithNamedEntity = @()
    $parseErrors = @()

    # Check if catalog lookup failed
    if ($catalogError) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine Named Entity SIT usage. Failed to build SIT catalog lookup: $catalogError`n`n%TestResult%"
    }
    # Check if both queries failed
    elseif ($queryError -and $autoLabelRules.Count -eq 0 -and $dlpRules.Count -eq 0) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine Named Entity SIT usage due to query error: $queryError`n`n%TestResult%"
    }
    # Check if catalog is empty (no Named Entity SITs found - unusual)
    elseif ($namedEntitySitIds.Count -eq 0) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine Named Entity SIT usage. No Named Entity SITs found in the SIT catalog (Classifier = 'EntityMatch'). This is unexpected - please verify tenant access.`n`n%TestResult%"
    }
    else {
        # Process auto-labeling rules
        Write-ZtProgress -Activity $activity -Status 'Analyzing auto-labeling rules for Named Entity SITs'
        foreach ($rule in $autoLabelRules) {
            try {
                $foundSits = Get-NamedEntitySitsFromRule -AdvancedRuleJson $rule.AdvancedRule -NamedEntitySitIds $namedEntitySitIds -RuleName $rule.Name -RuleType 'AutoLabeling'

                if ($foundSits.Count -gt 0) {
                    $autoLabelRulesWithNamedEntity += [PSCustomObject]@{
                        RuleName        = $rule.Name
                        PolicyName      = $rule.ParentPolicyName
                        NamedEntitySits = ($foundSits | ForEach-Object { $_.Name }) -join ', '
                        SitIds          = ($foundSits | ForEach-Object { $_.Id }) -join ', '
                        Workload        = $rule.Workload
                        CreatedDate     = $rule.WhenCreatedUTC
                        RuleType        = 'Auto-Labeling'
                        Count           = $foundSits.Count
                    }
                }
            }
            catch {
                $parseErrors += [PSCustomObject]@{
                    RuleName = $rule.Name
                    RuleType = 'Auto-Labeling'
                    Error    = $_.Exception.Message
                }
            }
        }

        # Process DLP rules
        Write-ZtProgress -Activity $activity -Status 'Analyzing DLP rules for Named Entity SITs'
        foreach ($rule in $dlpRules) {
            try {
                $foundSits = Get-NamedEntitySitsFromRule -AdvancedRuleJson $rule.AdvancedRule -NamedEntitySitIds $namedEntitySitIds -RuleName $rule.Name -RuleType 'DLP'

                if ($foundSits.Count -gt 0) {
                    $dlpRulesWithNamedEntity += [PSCustomObject]@{
                        RuleName        = $rule.Name
                        PolicyName      = $rule.ParentPolicyName
                        NamedEntitySits = ($foundSits | ForEach-Object { $_.Name }) -join ', '
                        SitIds          = ($foundSits | ForEach-Object { $_.Id }) -join ', '
                        Workload        = $rule.Workload
                        CreatedDate     = $rule.WhenCreatedUTC
                        RuleType        = 'DLP'
                        Count           = $foundSits.Count
                    }
                }
            }
            catch {
                $parseErrors += [PSCustomObject]@{
                    RuleName = $rule.Name
                    RuleType = 'DLP'
                    Error    = $_.Exception.Message
                }
            }
        }

        # Determine pass/fail status
        $totalRulesWithNamedEntity = $autoLabelRulesWithNamedEntity.Count + $dlpRulesWithNamedEntity.Count

        if ($totalRulesWithNamedEntity -gt 0) {
            $passed = $true
            $testResultMarkdown = "✅ At least one auto-labeling or DLP policy rule uses a Named Entity SIT (such as 'All Full Names', 'All Physical Addresses', 'All Medical Terms and Conditions', or similar pre-built classifiers).`n`n%TestResult%"
        }
        else {
            $passed = $false

            if ($autoLabelRules.Count -eq 0 -and $dlpRules.Count -eq 0) {
                $testResultMarkdown = "❌ No auto-labeling or DLP rules were found in your tenant.`n`n%TestResult%"
            }
            else {
                $testResultMarkdown = "❌ No auto-labeling or DLP policy rules contain any Named Entity SITs. All policies use only standard SITs (credit card numbers, social security numbers, etc.) or are not configured.`n`n%TestResult%"
            }
        }

        # Check for excessive parse errors which might indicate Investigate status
        if ($parseErrors.Count -gt 0 -and $totalRulesWithNamedEntity -eq 0) {
            $totalRules = $autoLabelRules.Count + $dlpRules.Count
            if ($parseErrors.Count -eq $totalRules -and $totalRules -gt 0) {
                $customStatus = 'Investigate'
                $testResultMarkdown = "⚠️ Unable to determine Named Entity SIT usage due to JSON parsing errors in all rules.`n`n%TestResult%"
            }
        }
    }

    #endregion Assessment Logic

    #region Report Generation

    $mdInfo = ''

    # Combine all rules with Named Entity SITs for display
    $allRulesWithNamedEntity = @()
    $allRulesWithNamedEntity += $autoLabelRulesWithNamedEntity
    $allRulesWithNamedEntity += $dlpRulesWithNamedEntity

    if ($allRulesWithNamedEntity.Count -gt 0) {
        $mdInfo += "`n`n### [Rules using named entity SITs](https://purview.microsoft.com/informationprotection/dataclassification/multicloudsensitiveinfotypes)`n"
        $mdInfo += "| Rule name | Policy name | Named Entity SITs | Count | Workload | Type |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($rule in $allRulesWithNamedEntity) {
            $ruleName = Get-SafeMarkdown -Text $rule.RuleName
            $safePolicyName = Get-SafeMarkdown -Text $rule.PolicyName
            $sits = Get-SafeMarkdown -Text $rule.NamedEntitySits
            $workload = Get-SafeMarkdown -Text ($rule.Workload -join ', ')

            # Build policy URL based on rule type
            if ($rule.RuleType -eq 'Auto-Labeling') {
                $policyUrl = 'https://purview.microsoft.com/informationprotection/autolabeling'
            }
            else {
                $policyUrl = 'https://purview.microsoft.com/datalossprevention/policies'
            }
            $policyLink = "[$safePolicyName]($policyUrl)"

            $mdInfo += "| $ruleName | $policyLink | $sits | $($rule.Count) | $workload | $($rule.RuleType) |`n"
        }
    }

    # Summary section
    $mdInfo += "`n`n### Summary`n"
    $mdInfo += "| Metric | Count |`n"
    $mdInfo += "| :--- | :--- |`n"
    $mdInfo += "| Named entity SITs in catalog | $($namedEntitySitIds.Count) |`n"
    $mdInfo += "| Total auto-labeling rules | $($autoLabelRules.Count) |`n"
    $mdInfo += "| Total DLP rules | $($dlpRules.Count) |`n"
    $mdInfo += "| Auto-labeling rules using named entity SITs | $($autoLabelRulesWithNamedEntity.Count) |`n"
    $mdInfo += "| DLP rules using named entity SITs | $($dlpRulesWithNamedEntity.Count) |"

    # Report parsing errors if any occurred
    if ($parseErrors.Count -gt 0) {
        $mdInfo += "`n`n### ⚠️ Parsing Errors`n"
        $mdInfo += "The following rules could not be fully parsed:`n`n"
        $mdInfo += "| Rule name | Type | Error |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($parseError in $parseErrors) {
            $ruleName = Get-SafeMarkdown -Text $parseError.RuleName
            $errorMsg = Get-SafeMarkdown -Text $parseError.Error
            $mdInfo += "| $ruleName | $($parseError.RuleType) | $errorMsg |`n"
        }
        $mdInfo += "`n**Note**: These rules were excluded from the named entity SIT analysis.`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '35035'
        Title  = 'Named Entity SITs Usage in Auto-Labeling and DLP Policies'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if status is 'Investigate'
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
