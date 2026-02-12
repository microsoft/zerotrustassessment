<#
.SYNOPSIS
    Validates that TLS inspection bypass policies are regularly reviewed to prevent security protection gaps.

.DESCRIPTION
    This test checks whether TLS inspection policies containing custom bypass rules have been
    reviewed within the last 90 days. Bypass rules that are not regularly reviewed can create
    security blind spots, as threat actors specifically target uninspected traffic channels.

.NOTES
    Test ID: 27001
    Category: Global Secure Access
    Required API: networkAccess/tlsInspectionPolicies
#>

function Test-Assessment-27001 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = 'Entra_Premium_Internet_Access',
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27001,
        Title = 'TLS inspection bypass policies are regularly reviewed to prevent security protection gaps',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking TLS inspection policy review status'

    # Query 1: Retrieve all TLS Inspection Policies
    Write-ZtProgress -Activity $activity -Status 'Retrieving TLS inspection policies'

    $tlsInspectionPolicies = $null
    try {
        $tlsInspectionPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/tlsInspectionPolicies' -ApiVersion beta -ErrorAction Stop
    }
    catch {
        Write-PSFMessage "Unable to retrieve TLS inspection policies: $_" -Level Warning
    }

    # Check if we got any policies
    if (-not $tlsInspectionPolicies -or $tlsInspectionPolicies.Count -eq 0) {
        Write-PSFMessage "No TLS inspection policies found or unable to retrieve policies." -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Query 2: For each policy, retrieve policy rules
    $policiesWithCustomBypass = @()

    foreach ($policy in $tlsInspectionPolicies) {
        Write-ZtProgress -Activity $activity -Status "Checking policy: $($policy.name)"

        $policyRules = $null
        try {
            $policyRules = Invoke-ZtGraphRequest -RelativeUri "networkAccess/tlsInspectionPolicies/$($policy.id)/policyRules" -ApiVersion beta -ErrorAction Stop
        }
        catch {
            Write-PSFMessage "Unable to retrieve policy rules for policy '$($policy.name)': $_" -Level Warning
            continue
        }

        if (-not $policyRules -or $policyRules.Count -eq 0) {
            continue
        }

        # Filter out auto-created system rules (description starts with "Auto-created TLS rule")
        $customRules = $policyRules | Where-Object {
            -not ($_.description -and $_.description -like "Auto-created TLS rule*")
        }

        # Count custom bypass rules
        $customBypassRules = @($customRules | Where-Object { $_.action -eq 'bypass' })
        $customBypassCount = $customBypassRules.Count

        # Skip policies with no custom bypass rules
        if ($customBypassCount -eq 0) {
            continue
        }

        # Calculate days since last modified
        $daysSinceModified = ([datetime]::UtcNow - $policy.lastModifiedDateTime).Days

        $policiesWithCustomBypass += [PSCustomObject]@{
            PolicyName           = $policy.name
            LastModifiedDateTime = $policy.lastModifiedDateTime
            DaysSinceModified    = $daysSinceModified
            CustomBypassCount    = $customBypassCount
            RequiresReview       = $daysSinceModified -gt 90
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Check if no policies with custom bypass rules were found
    if ($policiesWithCustomBypass.Count -eq 0) {
        $passed = $true
        $testResultMarkdown = "✅ No TLS inspection policies with custom bypass rules found.`n`n%TestResult%"
    }
    else {
        # Check if any policies require review
        $policiesRequiringReview = @($policiesWithCustomBypass | Where-Object { $_.RequiresReview -eq $true })

        if ($policiesRequiringReview.Count -gt 0) {
            $passed = $false
            $testResultMarkdown = "❌ One or more TLS inspection policies with custom bypass rules have not been modified in over 90 days and require review.`n`n%TestResult%"
        }
        else {
            $passed = $true
            $testResultMarkdown = "✅ All TLS inspection policies with custom bypass rules have been reviewed within the last 90 days.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($policiesWithCustomBypass.Count -gt 0) {
        $reportTitle = 'TLS inspection policies'
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/TLSInspectionPolicy.ReactView'

        # Prepare table rows
        $tableRows = ''
        foreach ($item in $policiesWithCustomBypass) {
            $lastModifiedDisplay = $item.LastModifiedDateTime.ToString('yyyy-MM-dd')
            $reviewStatus = if ($item.RequiresReview) { '❌' } else { '✅' }

            $tableRows += "| $($item.PolicyName) | $lastModifiedDisplay | $($item.DaysSinceModified) | $($item.CustomBypassCount) | $reviewStatus |`n"
        }

        $totalCount = $policiesWithCustomBypass.Count
        $oldPoliciesCount = ($policiesRequiringReview).Count

        $formatTemplate = @'

## [{0}]({1})

| Policy name | Last modified | Days since modified | Custom Bypass rule count | Status |
| :---------- | :------------ | :------------------ | :----------------------- | :----- |
{2}

**Summary:**
- Total policies with custom bypass rules: {3}
- Policies older than 90 days: {4}
'@

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows, $totalCount, $oldPoliciesCount
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '27001'
        Title  = 'TLS inspection bypass policies are regularly reviewed to prevent security protection gaps'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
