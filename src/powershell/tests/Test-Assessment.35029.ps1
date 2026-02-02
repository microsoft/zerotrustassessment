<#
.SYNOPSIS
    Mail Flow Rules with Rights Protection

.DESCRIPTION
    This test validates whether Exchange Online mail flow (transport) rules exist that automatically
    apply encryption or rights protection (ApplyOME, ApplyRightsProtectionTemplate, ApplyClassification).
    It checks for rules that are enabled and that contain specific conditions (not an "Always"/generic rule).
    A pass indicates the tenant has automated mail flow protections that help prevent sensitive data
    from being sent unprotected.

.NOTES
    Test ID: 35029
    Category: Information Protection
    Pillar: Data
    Risk Level: Medium
    Required Module: ExchangeOnlineManagement
    Required Connection: Exchange Online
#>

function Test-Assessment-35029 {
    [ZtTest(
        Category = 'Information Protection',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35029,
        Title = 'Mail Flow Rules with Rights Protection',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Querying Exchange Online mail flow rules (transport rules)'
    Write-ZtProgress -Activity $activity -Status 'Getting transport rules'

    $allRules = $null
    $protectionRules = @()
    $errorMsg = $null

    try {
        $allRules = Get-TransportRule -ErrorAction Stop
        $protectionRules = $allRules | Where-Object { ($_.ApplyOME -eq $true) -or ($_.ApplyRightsProtectionTemplate) -or ($_.ApplyClassification) }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve transport rules: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        $passed = $false
        $customStatus = 'Investigate'
    }
    elseif (-not $protectionRules -or $protectionRules.Count -eq 0) {
        # No protection rules found
        $passed = $false
    }
    else {
        $enabledRules = $protectionRules | Where-Object { $_.Enabled -eq $true }

        $omeCount = @($protectionRules | Where-Object { $_.ApplyOME -eq $true }).Count
        $rmsCount = @($protectionRules | Where-Object { $_.ApplyRightsProtectionTemplate }).Count
        $classCount = @($protectionRules | Where-Object { $_.ApplyClassification }).Count

        # Heuristic: consider a rule "specific" when its Conditions output contains content other than generic 'Always' or empty
        function Test-HasSpecificConditions($rule) {
            try {
                $cond = ($rule.Conditions | Out-String).Trim()
                if ([string]::IsNullOrWhiteSpace($cond)) { return $false }
                if ($cond -match '(?i)Always|True|Any') { return $false }
                return $true
            }
            catch {
                return $false
            }
        }

        $goodEnabledRule = $enabledRules | Where-Object { Test-HasSpecificConditions $_ } | Select-Object -First 1

        if ($goodEnabledRule) {
            $passed = $true
        }
        else {
            # There are protection rules but none that are both enabled and appear to have specific conditions
            $passed = $false
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''

    if ($customStatus -eq 'Investigate') {
        $testResultMarkdown = "⚠️ Unable to determine mail flow rule configuration due to permissions issues or connectivity failure.`n`n"
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ One or more enabled mail flow rules exist that apply rights protection (OME/RMS/Classification) and appear to have targeted conditions.`n`n"
        }
        else {
            $testResultMarkdown = "❌ No enabled mail flow rules were found that apply rights protection with specific conditions; sensitive emails may not be automatically protected.`n`n"
        }

        # Summary counts
        $totalProtectionRules = @($protectionRules).Count
        $enabledCount = @($protectionRules | Where-Object { $_.Enabled -eq $true }).Count

        $testResultMarkdown += "**Summary**`n`n"
        $testResultMarkdown += "* Total rights protection rules: $totalProtectionRules`n"
        $testResultMarkdown += "* Enabled rules: $enabledCount`n"
        $testResultMarkdown += "* OME encryption rules: $omeCount`n"
        $testResultMarkdown += "* RMS template application rules: $rmsCount`n"
        $testResultMarkdown += "* Classification/DLP rules: $classCount`n`n"

        # Detailed table
        if ($totalProtectionRules -gt 0) {
            $testResultMarkdown += "### Mail Flow Rules with Rights Protection`n`n"
            $testResultMarkdown += "| Rule Name | Enabled | Actions | Priority | Conditions | Last Modified |`n"
            $testResultMarkdown += "| :--- | :---: | :--- | :---: | :--- | :---: |`n"

            foreach ($r in $protectionRules) {
                $actions = @()
                if ($r.ApplyOME -eq $true) { $actions += 'OME' }
                if ($r.ApplyRightsProtectionTemplate) { $actions += 'RMS Template' }
                if ($r.ApplyClassification) { $actions += 'Classification' }
                $actionsText = ($actions -join ', ')

                $condText = ($r.Conditions | Out-String).Trim() -replace '\s+', ' '
                if ([string]::IsNullOrWhiteSpace($condText)) { $condText = 'N/A' }

                $lastModified = if ($r.LastModifiedTime) { $r.LastModifiedTime.ToString('yyyy-MM-dd') } else { 'N/A' }

                $testResultMarkdown += "| $($r.Name) | $($r.Enabled) | $actionsText | $($r.Priority) | $condText | $lastModified |`n"
            }
            $testResultMarkdown += "`n"
        }

        $testResultMarkdown += "[Manage mail flow rules in Microsoft Purview](https://purview.microsoft.com/datalossprevention/rules)`n"
    }
    #endregion Report Generation

    $params = @{
        TestId = '35029'
        Title  = 'Mail Flow Rules with Rights Protection'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) { $params.CustomStatus = $customStatus }

    Add-ZtTestResultDetail @params
}
