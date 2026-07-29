<#
.SYNOPSIS
    Application control is enforced via Intune.

.NOTES
    Test ID: 41052
    Required permission: DeviceManagementConfiguration.Read.All
#>

function Test-Assessment-41052 {
    [ZtTest(
        Category = 'Endpoint threat protection',
        CompatibleLicense = ('INTUNE_A'),
        ImplementationCost = 'High',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41052,
        Title = 'Application control (WDAC / App Control for Business) is enforced via Intune',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking App Control for Business policies'
    $queryError = $null
    $policies = @()

    Write-ZtProgress -Activity $activity -Status 'Getting Intune application control policies'
    try {
        $policies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/configurationPolicies' -ApiVersion beta -ErrorAction Stop |
            Where-Object { $_.templateReference.templateFamily -eq 'endpointSecurityApplicationControl' })
    }
    catch {
        $queryError = $_
        Write-PSFMessage "Failed to retrieve App Control for Business policies: $_" -Tag Test -Level Warning
    }

    if ($queryError) {
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $queryError
        if ($statusCode -in 401, 403, 404) {
            Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'Microsoft Graph returned HTTP 401, 403, or 404. Verify Intune licensing, user RBAC, and DeviceManagementConfiguration.Read.All consent.'
            return
        }

        $params = @{
            TestId       = '41052'
            Title        = 'Application control (WDAC / App Control for Business) is enforced via Intune'
            Status       = $false
            Result       = '⚠️ Intune App Control for Business policies could not be retrieved. Retry after resolving the Microsoft Graph error.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $policyResults = @()
    foreach ($policy in $policies) {
        try {
            Write-ZtProgress -Activity $activity -Status "Reading policy $($policy.name)"
            $assignments = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies('$($policy.id)')/assignments" -ApiVersion beta -ErrorAction Stop)
        }
        catch {
            $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($statusCode -in 401, 403, 404) {
                Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'Microsoft Graph returned HTTP 401, 403, or 404. Verify Intune licensing, user RBAC, and DeviceManagementConfiguration.Read.All consent.'
                return
            }

            $policyResults += [pscustomobject]@{
                Name = $policy.name; TemplateFamily = $policy.templateReference.templateFamily; Mode = 'Unknown'
                AssignmentCount = $null; LastModified = $policy.lastModifiedDateTime; Status = 'Investigate'
            }
            continue
        }

        try {
            $settings = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies('$($policy.id)')/settings" -ApiVersion beta -ErrorAction Stop)
        }
        catch {
            $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
            if ($statusCode -in 401, 403, 404) {
                Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'Microsoft Graph returned HTTP 401, 403, or 404. Verify Intune licensing, user RBAC, and DeviceManagementConfiguration.Read.All consent.'
                return
            }

            $assignmentCount = $assignments.Count
            $policyResults += [pscustomobject]@{
                Name = $policy.name; TemplateFamily = $policy.templateReference.templateFamily; Mode = 'Unknown'
                AssignmentCount = $assignmentCount; LastModified = $policy.lastModifiedDateTime
                Status = if ($assignmentCount -gt 0) { 'Investigate' } else { 'Fail' }
            }
            continue
        }

        # WDAC is in audit mode only when its Enabled:Audit Mode rule is present.
        $settingsText = $settings | ConvertTo-Json -Depth 20 -Compress
        $mode = if ($settings.Count -eq 0) {
            'Unknown'
        }
        elseif ($settingsText -match '(?i)enabled\s*:\s*audit\s*mode|audit[\s_-]*(mode|only)?') {
            'Audit'
        }
        else {
            'Enforce'
        }
        $assignmentCount = $assignments.Count
        $status = if ($assignmentCount -eq 0) { 'Fail' } elseif ($mode -eq 'Enforce') { 'Pass' } elseif ($mode -eq 'Unknown') { 'Investigate' } else { 'Fail' }

        $policyResults += [pscustomobject]@{
            Name = $policy.name; TemplateFamily = $policy.templateReference.templateFamily; Mode = $mode
            AssignmentCount = $assignmentCount; LastModified = $policy.lastModifiedDateTime; Status = $status
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $enforcedPolicies = @($policyResults | Where-Object { $_.Status -eq 'Pass' })
    $unknownPolicies = @($policyResults | Where-Object { $_.Status -eq 'Investigate' })
    $passed = $enforcedPolicies.Count -gt 0
    $customStatus = $null

    if ($passed) {
        $testResultMarkdown = "✅ An App Control for Business policy is configured, enforced, and assigned in Microsoft Intune.`n`n%TestResult%"
    }
    elseif ($unknownPolicies.Count -gt 0) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ An assigned App Control for Business policy was returned, but its enforcement mode could not be determined from the returned settings.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No App Control for Business policies were returned, no policies are assigned, or all assigned policies are audit-only.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalUrl = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/applicationcontrol'
    $tableRows = @($policyResults | Select-Object -First 10 | ForEach-Object {
        $lastModified = if ($_.LastModified) { Get-FormattedDate -DateString $_.LastModified } else { '—' }
        "| $((Get-SafeMarkdown $_.Name) -replace '\|', '\\|') | $($_.TemplateFamily) | $($_.Mode) | $($_.AssignmentCount) | $lastModified | $($_.Status) |"
    })
    if ($policyResults.Count -gt 10) {
        $tableRows += "| ... | | | | | $($policyResults.Count) total policies |"
    }
    if ($tableRows.Count -eq 0) {
        $tableRows = '| No App Control for Business policies found | endpointSecurityApplicationControl | — | 0 | — | Fail |'
    }

    $mdInfo = @"

## [Intune App Control for Business]($portalUrl)

| Policy Name | Template Family | Mode | Assignment Count | Last Modified | Status |
| :---------- | :-------------- | :--- | ---------------: | :------------ | :----- |
$($tableRows -join "`n")
"@
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    $params = @{
        TestId = '41052'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params

    #endregion Report Generation
}
