<#
.SYNOPSIS
    On-Demand Scans Configured for Sensitive Information Discovery

.DESCRIPTION
    On-demand scans enable organizations to discover sensitive information in historical
    SharePoint, OneDrive, and Exchange content that predates auto-labeling policies.
    If no on-demand scans are configured, organizations lack visibility into existing
    sensitive data and cannot establish a compliance baseline.

.NOTES
    Test ID: 35022
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-350022 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35022,
        Title = 'On-Demand Scans Configured for Sensitive Information Discovery',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    Write-ZtProgress -Activity 'Checking On-Demand Sensitive Information Scans'

    $scans        = $null
    $errorMsg     = $null
    $customStatus = $null

    try {
        $scans = Get-SensitiveInformationScan -ErrorAction Stop
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-PSFMessage "Error retrieving on-demand scans: $errorMsg" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($errorMsg) {
        $passed = $false
        $customStatus = 'Investigate'
    }
    elseif ($scans -and $scans.Count -gt 0) {
        $passed = $true
    }
    else {
        $passed = $false
    }
    #endregion Assessment Logic

    #region Data Processing & Report Generation
    if ($errorMsg) {
        $testResultMarkdown  = "### Investigate`n`n"
        $testResultMarkdown += "Unable to retrieve on-demand scan configuration due to an error:`n`n"
        $testResultMarkdown += $errorMsg
    }
    elseif (-not $passed) {
        $testResultMarkdown  = "❌ No on-demand scans are configured. Historical sensitive data cannot be discovered.`n"
    }
    else {
        $testResultMarkdown  = "### On-Demand Sensitive Information Discovery Summary`n`n"
        $testResultMarkdown += "Total Scans Configured: **$($scans.Count)**`n`n"

        # Define Table Header
        $testResultMarkdown += "| Scan name | Status | Workload | Last run | Sensitive info types covered |`n"
        $testResultMarkdown += "|-----------|--------|----------|----------|------------------------------|`n"

        foreach ($scan in $scans) {
            # 1. Retrieve the matching Rule to find SIT details
            # We use SilentlyContinue because a broken/orphan scan might lack a rule
            $rule = Get-SensitiveInformationScanRule -Policy $scan.Name -ErrorAction SilentlyContinue

            # 2. Extract SIT Names using the discovered property path
            $sitNamesList = @()
            if ($rule -and $rule.ContentContainsSensitiveInformation -and $rule.ContentContainsSensitiveInformation.groups -and $rule.ContentContainsSensitiveInformation.groups.sensitivetypes) {
                $types = $rule.ContentContainsSensitiveInformation.groups.sensitivetypes
                foreach ($t in $types) {
                    if ($t.Name) { $sitNamesList += $t.Name }
                }
            }

            # Fallback if list is empty but rule exists (uncommon, but handles potential unexpected structures)
            if ($sitNamesList.Count -eq 0) {
                if ($rule) { $sitNamesList += "All/None Specific" }
                else       { $sitNamesList += "Rule Not Found" }
            }

            $sitString = $sitNamesList -join ", "

            # 3. Format Other Columns
            $scanName = $scan.Name
            $status   = $scan.SensitiveInformationScanStatus
            $workload = if ($scan.Workload) { $scan.Workload -replace ",", ", " } else { "None" }
            $lastRun  = if ($scan.LastImpactAssessmentStartTime) { $scan.LastImpactAssessmentStartTime.ToString("yyyy-MM-dd") } else { "Never" }

            # 4. Append Row to Markdown Table
            $testResultMarkdown += "| $scanName | $status | $workload | $lastRun | $sitString |`n"
        }
    }
    #endregion Data Processing & Report Generation

    $testResultDetail = @{
        TestId = '35022'
        Title  = 'On-Demand Scans Configured for Sensitive Information Discovery'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($customStatus) {
        $testResultDetail.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @testResultDetail
}
