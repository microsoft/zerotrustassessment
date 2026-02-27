<#
.SYNOPSIS
    Email retention policies configured

.DESCRIPTION
    Email retention policies automatically manage message lifecycle by deleting, archiving,
    or preserving emails based on organizational compliance and legal requirements. Without
    retention policies configured for Exchange Online, organizations have no centralized
    mechanism to enforce record retention schedules or comply with regulatory mandates.
    This test checks that at least one enabled retention policy with Exchange workload
    scope exists.

.NOTES
    Test ID: 35028
    Pillar: Data
    Risk Level: Medium
    Category: Information Protection
#>

function Test-Assessment-35028 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce', 'External'),
        TestId = 35028,
        Title = 'Email retention policies are configured',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking email retention policy configuration'

    Write-ZtProgress -Activity $activity -Status 'Getting retention compliance policies and rules'

    $errorMsg = $null
    $retentionPolicies = $null
    $retentionRules = $null
    try {
        # Q1: Get all retention compliance policies

        Write-PSFMessage "Querying retention compliance policies" -Level Verbose
        # These cmdlets are available only in Security & Compliance PowerShell
        # Reference: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-retentioncompliancepolicy?view=exchange-ps
        # Note: -DistributionDetail is required for accurate ExchangeLocation values
        $retentionPolicies = Get-RetentionCompliancePolicy -DistributionDetail -ErrorAction Stop

        # Q2: Get retention rules associated with policies

        Write-PSFMessage "Querying retention compliance rules" -Level Verbose
        # Reference: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-retentioncompliancerule?view=exchange-ps
        $retentionRules = Get-RetentionComplianceRule -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying retention data: $errorMsg" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        Write-PSFMessage "Query failure or connection issue: $errorMsg" -Level Warning
        $testResultMarkdown = "⚠️ Unable to determine retention policy configuration due to permissions issues or query failure.`n`n%TestResult%"
        $customStatus = 'Investigate'
    }
    else {
        # Filter for enabled retention policies with Exchange workload
        # Note: Workload property always shows all workloads regardless of actual scope.
        # Use ExchangeLocation to determine actual Exchange scope.
        $enabledExchangePolicies = @($retentionPolicies | Where-Object {
            $_.Enabled -eq $true -and
            $null -ne $_.ExchangeLocation -and
            @($_.ExchangeLocation).Count -gt 0
        })

        $passed = $enabledExchangePolicies.Count -gt 0

        if ($passed) {
            $testResultMarkdown = "✅ Email retention policies are configured and enabled for Exchange Online, automatically managing message lifecycle and enforcing compliance-required retention schedules.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ No email retention policies are configured for Exchange Online, creating a compliance and legal risk where emails are retained indefinitely and eDiscovery scope is uncontrolled.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    $exchangePolicies = @($retentionPolicies | Where-Object {
        $null -ne $_.ExchangeLocation -and
        @($_.ExchangeLocation).Count -gt 0
    })

    if ($exchangePolicies.Count -gt 0) {
        $policyRows = ''
        foreach ($pol in $exchangePolicies | Sort-Object -Property Name) {
            $policyName = Get-SafeMarkdown -Text $pol.Name
            $enabledIcon = if ($pol.Enabled) { '✅ Yes' } else { '❌ No' }
            $exchangeScope = Get-SafeMarkdown -Text (@($pol.ExchangeLocation) -join ', ')
            $mode = if ($pol.Mode) { Get-SafeMarkdown -Text "$($pol.Mode)" } else { 'N/A' }
            $policyRows += "| $policyName | $enabledIcon | $exchangeScope | $mode |`n"
        }

        $ruleRows = ''
        $exchangeRules = @()
        if (@($retentionRules).Count -gt 0) {
            $exchangePolicyGuids = $exchangePolicies | ForEach-Object { $_.Guid.ToString() }
            $exchangeRules = @($retentionRules | Where-Object { $_.Policy -in $exchangePolicyGuids })

            foreach ($rule in $exchangeRules | Sort-Object -Property Name) {
                $ruleName = Get-SafeMarkdown -Text $rule.Name
                $parentPolicy = Get-SafeMarkdown -Text ($exchangePolicies | Where-Object { $_.Guid.ToString() -eq $rule.Policy }).Name
                $ruleEnabled = if ($rule.Disabled) { '❌ No' } else { '✅ Yes' }
                $retentionAction = if ($rule.RetentionComplianceAction) { Get-SafeMarkdown -Text "$($rule.RetentionComplianceAction)" } else { 'N/A' }
                $retentionDuration = if ($rule.RetentionDuration) { "$($rule.RetentionDuration)" } else { 'Indefinite' }
                if ($rule.RetentionDurationDisplayHint) {
                    $safeRetentionDurationDisplayHint = Get-SafeMarkdown -Text "$($rule.RetentionDurationDisplayHint)"
                    $retentionDuration += " ($safeRetentionDurationDisplayHint)"
                }
                $ruleRows += "| $ruleName | $parentPolicy | $ruleEnabled | $retentionAction | $retentionDuration |`n"
            }
        }

        $activeExchangeRules = @($exchangeRules | Where-Object { -not $_.Disabled })

        $rulesSection = ''
        if ($ruleRows) {
            $rulesSection = @'

### Retention rules for Exchange policies

| Rule name | Parent policy | Enabled | Retention action | Retention period |
| :--- | :--- | :--- | :--- | :--- |
{1}
'@ -f $null, $ruleRows
        }

        $formatTemplate = @'

### [Retention policies with Exchange scope](https://purview.microsoft.com/datalifecyclemanagement/retention)

| Policy name | Enabled | Exchange scope | Mode |
| :--- | :--- | :--- | :--- |
{0}
{1}
### Summary

| Metric | Value |
| :--- | :--- |
| Total retention policies | {2} |
| Enabled Exchange policies | {3} |
| Active retention rules (Exchange) | {4} |
'@

        $mdInfo = $formatTemplate -f $policyRows, $rulesSection, @($retentionPolicies).Count, $enabledExchangePolicies.Count, $activeExchangeRules.Count
    }

    $testResultMarkdown = $testResultMarkdown.Replace('%TestResult%', $mdInfo)
    #endregion Report Generation

    $params = @{
        TestId = '35028'
        Title  = 'Email retention policies are configured'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
