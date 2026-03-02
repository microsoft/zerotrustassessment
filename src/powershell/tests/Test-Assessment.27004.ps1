<#
.SYNOPSIS
    Validates that custom TLS inspection bypass rules do not duplicate system bypass destinations.

.DESCRIPTION
    This test checks whether custom TLS inspection bypass rules contain destinations that are
    already covered by Microsoft's system bypass list. Redundant rules:
    - Consume policy capacity unnecessarily
    - Create administrative overhead
    - May cause confusion about necessary vs. duplicated rules

    The test identifies exact matches, subdomain matches, and wildcard overlaps between
    custom bypass rules and the system bypass list.

.NOTES
    Test ID: 27004
    Category: Global Secure Access
    Required API: networkAccess/tlsInspectionPolicies (beta) with $expand=policyRules
    System Bypass List: assets/27004-system-bypass-fqdns.json (sourced from GSA backend team; manually maintained until API is available)
#>

function Test-Assessment-27004 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'Low',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27004,
        Title = 'TLS inspection custom bypass rules do not duplicate system bypass destinations',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    # Constants for output display limits
    [int]$MAX_RULES_DISPLAYED = 10
    [int]$MAX_RULE_GROUPS = 10
    [int]$MAX_DESTINATIONS_PER_RULE = 10

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking TLS inspection bypass rules for redundant system destinations'
    Write-ZtProgress -Activity $activity -Status 'Loading system bypass reference list'

    # Load system bypass FQDN list from config file.
    $dataFilePath = Join-Path $PSScriptRoot '..' 'assets' '27004-system-bypass-fqdns.json' | Resolve-Path -ErrorAction SilentlyContinue
    if (-not $dataFilePath -or -not (Test-Path $dataFilePath)) {
        Write-PSFMessage "System bypass FQDN config file not found: $dataFilePath" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    $jsonErrorMsg = $null
    try {
        $bypassConfig = Get-Content $dataFilePath -Raw | ConvertFrom-Json
        $systemFqdns = @($bypassConfig.fqdns)
        $systemFqdnsLower = $systemFqdns | ForEach-Object { $_.ToLower() }
        Write-PSFMessage "Loaded $($systemFqdns.Count) system bypass FQDNs from config (last updated: $($bypassConfig.metadata.lastUpdated))" -Tag Test -Level VeryVerbose
    }
    catch {
        $jsonErrorMsg = $_
        Write-PSFMessage "Failed to parse system bypass config file: $jsonErrorMsg" -Tag Test -Level Warning
    }

    # System recommended bypass categories (from priority 65000 rule)
    $systemCategories = @('Education', 'Finance', 'Government', 'HealthAndMedicine')
    $systemCategoriesLower = $systemCategories | ForEach-Object { $_.ToLower() }

    Write-ZtProgress -Activity $activity -Status 'Querying TLS inspection policies and rules'

    $tlsPolicies = @()
    $errorMsg = $null

    try {
        $tlsPolicies = Invoke-ZtGraphRequest `
            -RelativeUri 'networkAccess/tlsInspectionPolicies' `
            -QueryParameters @{ '$expand' = 'policyRules' } `
            -ApiVersion beta
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve TLS inspection policies: $errorMsg" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null

    if ($jsonErrorMsg) {
        # JSON parsing failed - unable to load system bypass configuration
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to load system bypass configuration due to JSON parsing error.`n`n%TestResult%"
    }
    elseif ($errorMsg) {
        # API call failed - unable to determine status
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to retrieve TLS inspection policies due to API error or insufficient permissions.`n`n%TestResult%"
    }
    elseif ($null -eq $tlsPolicies -or $tlsPolicies.Count -eq 0) {
        # No TLS inspection policies configured - prerequisite not met
        Write-PSFMessage 'TLS inspection is not configured in this tenant.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'TLS inspection is not configured in this tenant. This check is not applicable until a TLS inspection policy is created.'
        return
    }
    else {

    Write-ZtProgress -Activity $activity -Status 'Analyzing bypass rules for redundancies'

    $allBypassRules = [System.Collections.Generic.List[object]]::new()
    $redundantRules = [System.Collections.Generic.List[object]]::new()

    foreach ($policy in $tlsPolicies) {
        if ($null -eq $policy.policyRules) {
            continue
        }

        $bypassRules = @($policy.policyRules | Where-Object { $_.action -eq 'bypass' })

        foreach ($rule in $bypassRules) {
            # Skip auto-created system rules
            if ($rule.description -like 'Auto-created TLS rule*') {
                continue
            }

            $destinations = @()
            $destinationTypeMap = @{}
            $matchedPairs = [System.Collections.Generic.List[object]]::new()

            # Extract destinations from matchingConditions, tracking type per value
            if ($null -ne $rule.matchingConditions -and $null -ne $rule.matchingConditions.destinations) {
                foreach ($dest in $rule.matchingConditions.destinations) {
                    if ($null -ne $dest.values) {
                        $destType = if ($dest.'@odata.type' -like '*tlsInspectionFqdnDestination*') { 'FQDN' }
                                    elseif ($dest.'@odata.type' -like '*tlsInspectionWebCategoryDestination*') { 'Category' }
                                    else { 'Unknown' }
                        foreach ($v in $dest.values) {
                            $destinations += $v
                            $destinationTypeMap[$v] = $destType
                        }
                    }
                }
            }

            # Skip rule if no destinations found
            if ($destinations.Count -eq 0) {
                continue
            }

            # Check each custom destination against the system bypass list.
            # Supports exact matches, subdomain matches under wildcards (*.domain.com),
            # wildcard-to-wildcard matches, and double-wildcard patterns (*.domain.*).
            foreach ($destination in $destinations) {
                $destLower = $destination.ToLower().Trim()
                $destType = if ($destinationTypeMap.ContainsKey($destination)) { $destinationTypeMap[$destination] } else { 'FQDN' }

                # Check if this is a web category destination
                if ($destType -eq 'Category') {
                    # Check against system recommended bypass categories
                    for ($i = 0; $i -lt $systemCategoriesLower.Count; $i++) {
                        if ($destLower -eq $systemCategoriesLower[$i]) {
                            $matchedPairs.Add([PSCustomObject]@{
                                CustomFqdn = $destination
                                SystemFqdn = $systemCategories[$i]
                                MatchType  = 'Exact'
                                DestType   = 'Category'
                            })
                            break
                        }
                    }
                }
                else {
                    # Check FQDN against system bypass FQDN list
                    for ($i = 0; $i -lt $systemFqdnsLower.Count; $i++) {
                        $sysFqdn = $systemFqdnsLower[$i]
                        $isMatch = $false
                        $matchType = ''

                        if ($destLower -eq $sysFqdn) {
                            # Exact match (covers wildcard-to-wildcard too)
                            $isMatch = $true; $matchType = 'Exact'
                        }
                        elseif ($sysFqdn -match '^\*\.([^.]+)\.\*$') {
                            # Double-wildcard: *.domain.* — check if custom destination matches the pattern
                            $mid = [regex]::Escape($Matches[1])
                            if ($destLower -match "\.$mid\.") {
                                $isMatch = $true
                                # Determine match type based on whether custom is also a wildcard
                                $matchType = if ($destLower -match '^\*\.') { 'Wildcard' } else { 'Subdomain' }
                            }
                        }
                        elseif ($sysFqdn -match '^\*\.(.+)$') {
                            # Standard wildcard: *.domain.com
                            $suffix = $Matches[1]
                            if ($destLower -eq "*.$suffix") {
                                # Exact wildcard-to-wildcard match
                                $isMatch = $true
                                $matchType = 'Exact'
                            }
                            elseif ($destLower -like "*.$suffix") {
                                # Subdomain of the wildcard suffix
                                $isMatch = $true
                                $matchType = 'Subdomain'
                            }
                            elseif ($destLower -eq $suffix) {
                                # Base domain match
                                $isMatch = $true
                                $matchType = 'Subdomain'
                            }
                        }

                        # Check if custom destination is a wildcard being covered by system base domain
                        if (-not $isMatch -and $destLower -match '^\*\.(.+)$') {
                            $customSuffix = $Matches[1]
                            if ($sysFqdn -eq $customSuffix -or $sysFqdn -eq "*.$customSuffix") {
                                $isMatch = $true; $matchType = 'Wildcard'
                            }
                        }

                        if ($isMatch) {
                            $matchedPairs.Add([PSCustomObject]@{
                                CustomFqdn = $destination
                                SystemFqdn = $systemFqdns[$i]
                                MatchType  = $matchType
                                DestType   = 'FQDN'
                            })
                            break  # Only match once per destination
                        }
                    }
                }
            }

            $ruleStatus = if ($matchedPairs.Count -eq 0) { 'No Overlap' }
                          elseif ($matchedPairs.Count -ge $destinations.Count) { 'Redundant' }
                          else { 'Partial' }

            $ruleInfo = [PSCustomObject]@{
                PolicyName        = $policy.name
                PolicyId          = $policy.id
                RuleName          = $rule.name
                RuleId            = $rule.id
                Destinations      = $destinations
                TotalDestinations = $destinations.Count
                RedundantCount    = $matchedPairs.Count
                MatchedPairs      = $matchedPairs
                Status            = $ruleStatus
            }

            $allBypassRules.Add($ruleInfo)

            if ($ruleStatus -ne 'No Overlap') {
                $redundantRules.Add($ruleInfo)
            }
        }
    }

        # Evaluate test result per spec evaluation logic
        if ($redundantRules.Count -eq 0) {
            # No custom bypass rules OR custom rules exist but none are redundant - pass
            $passed = $true
            $testResultMarkdown = "✅ All custom TLS inspection bypass rules target unique destinations not covered by the system bypass list.`n`n%TestResult%"
        }
        else {
            # Any matches found - fail with list of redundant rules
            $passed = $false
            $testResultMarkdown = "❌ Found custom bypass rules that duplicate system bypass destinations; these rules are redundant and can be removed to simplify policy management.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($allBypassRules.Count -gt 0) {
        $reportTitle = 'TLS Inspection Bypass Rule Analysis'
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/TLSInspectionPolicy.ReactView'

        # Calculate totals
        $totalDestinations = ($allBypassRules | ForEach-Object { $_.TotalDestinations } | Measure-Object -Sum).Sum
        $totalRedundantDestinations = ($allBypassRules | ForEach-Object { $_.RedundantCount } | Measure-Object -Sum).Sum
        $totalUniqueDestinations = $totalDestinations - $totalRedundantDestinations

        # Sort rules per spec: Status priority (Redundant → Partial → No Overlap), then by descending redundant count
        $statusPriority = @{ 'Redundant' = 1; 'Partial' = 2; 'No Overlap' = 3 }
        $sortedRules = $allBypassRules | Sort-Object { $statusPriority[$_.Status] }, @{ Expression = { $_.RedundantCount }; Descending = $true }

        # Build rule-level summary table with row cap
        $rulesTable = "#### Rule-level summary`n`n"
        $rulesTable += "| Policy name | Rule name | Total destinations | Redundant destinations | Status |`n"
        $rulesTable += "| :---------- | :-------- | :----------------- | :--------------------- | :----- |`n"

        $displayedRules = $sortedRules | Select-Object -First $MAX_RULES_DISPLAYED

        foreach ($rule in $displayedRules) {
            $policyName = Get-SafeMarkdown -Text $rule.PolicyName
            $ruleName = Get-SafeMarkdown -Text $rule.RuleName
            $rulesTable += "| $policyName | $ruleName | $($rule.TotalDestinations) | $($rule.RedundantCount) | $($rule.Status) |`n"
        }

        # Add overflow summary if there are more rules than the display limit
        if ($sortedRules.Count -gt $MAX_RULES_DISPLAYED) {
            $remaining = $sortedRules | Select-Object -Skip $MAX_RULES_DISPLAYED
            $remainingCount = $remaining.Count
            $remainingRedundant = ($remaining | Where-Object { $_.Status -eq 'Redundant' }).Count
            $remainingPartial = ($remaining | Where-Object { $_.Status -eq 'Partial' }).Count
            $remainingNoOverlap = ($remaining | Where-Object { $_.Status -eq 'No Overlap' }).Count
            $rulesTable += "| *+ $remainingCount more rules not shown ($remainingRedundant redundant, $remainingPartial partial, $remainingNoOverlap no overlap)* | | | | |`n"
        }

        # Build redundant destination detail grouped by rule
        $redundantDetail = ''
        if ($redundantRules.Count -gt 0) {
            $redundantDetail = "#### Redundant destination detail`n`n"

            # Sort redundant rules by same criteria: Status priority then redundant count desc
            $sortedRedundantRules = $redundantRules | Sort-Object { $statusPriority[$_.Status] }, @{ Expression = { $_.RedundantCount }; Descending = $true }

            # Cap at maximum rule groups
            $displayedRuleGroups = $sortedRedundantRules | Select-Object -First $MAX_RULE_GROUPS

            foreach ($rule in $displayedRuleGroups) {
                $policyName = Get-SafeMarkdown -Text $rule.PolicyName
                $ruleName = Get-SafeMarkdown -Text $rule.RuleName
                $redundantDetail += "**Rule: $ruleName** (Policy: $policyName) — $($rule.RedundantCount) of $($rule.TotalDestinations) destinations redundant`n`n"
                $redundantDetail += "| # | Custom bypass destination | Destination type | Matched system bypass entry | Match type |`n"
                $redundantDetail += "| :- | :----------------------- | :--------------- | :-------------------------- | :--------- |`n"

                # Cap at maximum destination entries per rule group
                $displayedPairs = $rule.MatchedPairs | Select-Object -First $MAX_DESTINATIONS_PER_RULE

                $rowNum = 1
                foreach ($pair in $displayedPairs) {
                    # Escape asterisks in FQDNs for markdown rendering (prevent italic/bold interpretation)
                    $customFqdn = $pair.CustomFqdn -replace '\*', '\*'
                    $systemFqdn = $pair.SystemFqdn -replace '\*', '\*'
                    $redundantDetail += "| $rowNum | $customFqdn | $($pair.DestType) | $systemFqdn | $($pair.MatchType) |`n"
                    $rowNum++
                }

                # Add overflow row if this rule has more redundant destinations than display limit
                if ($rule.MatchedPairs.Count -gt $MAX_DESTINATIONS_PER_RULE) {
                    $remainingPairs = $rule.MatchedPairs.Count - $MAX_DESTINATIONS_PER_RULE
                    $redundantDetail += "| | *+ $remainingPairs more redundant destinations not shown for this rule* | | | |`n"
                }

                $redundantDetail += "`n"
            }

            # Add overflow line if there are more rule groups than display limit
            if ($sortedRedundantRules.Count -gt $MAX_RULE_GROUPS) {
                $remainingRuleGroups = $sortedRedundantRules.Count - $MAX_RULE_GROUPS
                $redundantDetail += "*+ $remainingRuleGroups more rules with redundant destinations not shown*`n`n"
            }
        }

        $formatTemplate = @'

## [{0}]({1})

**Overview:**
- Total custom bypass rules: {2}
- Total custom bypass destinations: {3}
- Redundant destinations found: {4}
- Unique destinations: {5}

{6}

{7}
'@

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $allBypassRules.Count, $totalDestinations, $totalRedundantDestinations, $totalUniqueDestinations, $rulesTable, $redundantDetail
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '27004'
        Title  = 'TLS inspection custom bypass rules do not duplicate system bypass destinations'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
