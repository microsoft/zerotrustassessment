<#
.SYNOPSIS
    Auto-Labeling Enforcement Mode Enabled
#>

function Test-Assessment-35020 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce','External'),
        TestId = 35020,
        Title = 'Auto-labeling enforcement mode enabled',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking auto-labeling enforcement mode configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting auto-labeling policies'

    $errorMsg = $null
    $allPolicies = @()

    try {
        # Q1: Get all auto-labeling policies
        $allPolicies = Get-AutoSensitivityLabelPolicy -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying auto-labeling policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $enforcementPolicies = @()
    $simulationPolicies = @()
    $disabledPolicies = @()
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        $testResultMarkdown = "⚠️ Unable to determine auto-labeling enforcement mode status due to error: $errorMsg`n`n"
        $customStatus = 'Investigate'
    }
    else {
        Write-PSFMessage "Found $($allPolicies.Count) auto-labeling policies" -Level Verbose

        try {
            # Categorize policies by status and mode
            foreach ($policy in $allPolicies) {
                $policyInfo = [PSCustomObject]@{
                    Name = $policy.Name
                    Enabled = $policy.Enabled
                    Mode = $policy.Mode
                    Workload = $policy.Workload
                    Comment = $policy.Comment # Description field
                    WhenCreatedUTC = $policy.WhenCreatedUTC
                    WhenChangedUTC = $policy.WhenChangedUTC
                }

                # Categorize policies by Mode property
                # Possible Mode values per documentation: Enable, TestWithNotifications, TestWithoutNotifications, Disable
                # Reference: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/set-autosensitivitylabelpolicy?view=exchange-ps#-mode

                if ($policy.Enabled -eq $true -and $policy.Mode -eq 'Enable') {
                    $enforcementPolicies += $policyInfo
                }
                elseif ($policy.Enabled -eq $true -and ($policy.Mode -eq 'TestWithoutNotifications' -or $policy.Mode -eq 'TestWithNotifications')) {
                    $simulationPolicies += $policyInfo
                }
                elseif ($policy.Enabled -eq $false) {
                    $disabledPolicies += $policyInfo
                }
            }

            # Determine pass/fail status
            if ($enforcementPolicies.Count -gt 0) {
                $passed = $true
                $testResultMarkdown = "✅ At least one auto-labeling policy is enabled and actively labeling content in enforcement mode.`n`n%TestResult%"
            }
            else {
                $passed = $false

                if ($allPolicies.Count -eq 0) {
                    $testResultMarkdown = "❌ No auto-labeling policies were found in your tenant.`n`n%TestResult%"
                }
                else {
                    $testResultMarkdown = "❌ No auto-labeling policies are in enforcement mode. All policies are either disabled or in simulation mode.`n`n%TestResult%"
                }
            }
        }
        catch {
            Write-PSFMessage "Error processing auto-labeling policies: $_" -Level Error
            $testResultMarkdown = "⚠️ Unable to determine auto-labeling enforcement mode status due to unexpected policy structure: $_`n`n"
            $customStatus = 'Investigate'
        }
    }

    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Show enforcement policies table if any exist
    if ($enforcementPolicies.Count -gt 0) {
        $mdInfo += "`n`n### [Auto-labeling policies in enforcement mode](https://purview.microsoft.com/informationprotection/autolabeling)`n"
        $mdInfo += "| Policy name | Enabled status | Mode | Workload(s) targeted | Description | Date activated | Last modified |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $enforcementPolicies) {
            $policyName = Get-SafeMarkdown -Text $policy.Name
            $enabledStatus = $policy.Enabled
            $workload = if ($policy.Workload) { $policy.Workload -join ', ' } else { 'N/A' }
            $description = if ($policy.Comment) { Get-SafeMarkdown -Text $policy.Comment } else { 'N/A' }
            $created = if ($policy.WhenCreatedUTC) { $policy.WhenCreatedUTC.ToString('yyyy-MM-dd') } else { 'N/A' }
            $modified = if ($policy.WhenChangedUTC) { $policy.WhenChangedUTC.ToString('yyyy-MM-dd') } else { 'N/A' }
            $mdInfo += "| $policyName | $enabledStatus | $($policy.Mode) | $workload | $description | $created | $modified |`n"
        }
    }

    # Build summary metrics
    if ($allPolicies.Count -gt 0) {
        # Analyze workload coverage from enforcement policies
        $workloadCoverage = @{
            Exchange = $false
            SharePoint = $false
            OneDrive = $false
            Teams = $false
            PowerBI = $false
        }

        foreach ($policy in $enforcementPolicies) {
            if ($policy.Workload -contains 'Exchange') { $workloadCoverage.Exchange = $true }
            if ($policy.Workload -contains 'SharePoint') { $workloadCoverage.SharePoint = $true }
            if ($policy.Workload -contains 'OneDrive') { $workloadCoverage.OneDrive = $true }
            if ($policy.Workload -contains 'Teams') { $workloadCoverage.Teams = $true }
            if ($policy.Workload -contains 'PowerBI') { $workloadCoverage.PowerBI = $true }
        }

        $mdInfo += "`n`n### Summary`n"
        $mdInfo += "| Metric | Value |`n"
        $mdInfo += "| :--- | :--- |`n"
        $mdInfo += "| Total policies in enforcement mode | $($enforcementPolicies.Count) |`n"
        $mdInfo += "| Total policies in simulation mode | $($simulationPolicies.Count) |`n"
        $mdInfo += "| Total policies disabled | $($disabledPolicies.Count) |`n"
        $mdInfo += "| **Workloads covered by enforcement policies** | |`n"
        $mdInfo += "| *Exchange/Outlook* | $(if ($workloadCoverage.Exchange) { '✅ Yes' } else { '❌ No' }) |`n"
        $mdInfo += "| *SharePoint* | $(if ($workloadCoverage.SharePoint) { '✅ Yes' } else { '❌ No' }) |`n"
        $mdInfo += "| *OneDrive* | $(if ($workloadCoverage.OneDrive) { '✅ Yes' } else { '❌ No' }) |`n"
        $mdInfo += "| *Teams* | $(if ($workloadCoverage.Teams) { '✅ Yes' } else { '❌ No' }) |`n"
        $mdInfo += "| *Power BI* | $(if ($workloadCoverage.PowerBI) { '✅ Yes' } else { '❌ No' }) |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35020'
        Title  = 'Auto-labeling enforcement mode enabled'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if status is 'Investigate'
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
