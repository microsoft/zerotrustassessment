<#
.SYNOPSIS
    Windows Endpoint Privilege Management is configured and assigned
#>

function Test-Assessment-51001 {
    [ZtTest(
        Category = 'Device',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Intune'),
        Pillar = 'Devices',
        RiskLevel = 'High',
        SfiPillar = 'Protect engineering systems',
        TenantType = ('Workforce'),
        TestId = 51001,
        Title = 'Windows Endpoint Privilege Management is configured and assigned',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if (-not (Get-ZtLicense Intune)) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    #region Data Collection
    $activity = 'Checking that Windows Endpoint Privilege Management policies are configured and assigned'
    Write-ZtProgress -Activity $activity

    $sql = @"
    SELECT id, name, platforms, technologies, isAssigned, templateReference, to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE templateReference.templateFamily = 'endpointSecurityEndpointPrivilegeManagement'
"@
    $epmPolicies = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    foreach ($policy in $epmPolicies) {
        if ($policy.assignments -is [string]) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }

        $displayName = [string]$policy.templateReference.templateDisplayName
        $policyType = 'Other'
        if ($displayName -match 'Elevation settings') {
            $policyType = 'Elevation settings'
        }
        elseif ($displayName -match 'Elevation rules') {
            $policyType = 'Elevation rules'
        }
        $policy | Add-Member -NotePropertyName PolicyType -NotePropertyValue $policyType -Force
    }

    $settingsPolicies = @($epmPolicies | Where-Object { $_.PolicyType -eq 'Elevation settings' })
    $rulesPolicies    = @($epmPolicies | Where-Object { $_.PolicyType -eq 'Elevation rules' })

    $settingsAssigned = @($settingsPolicies | Where-Object { $_.isAssigned }).Count -gt 0
    $rulesAssigned    = @($rulesPolicies    | Where-Object { $_.isAssigned }).Count -gt 0
    #endregion Data Collection

    #region Assessment Logic
    if ($epmPolicies.Count -eq 0) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($settingsAssigned -and $rulesAssigned) {
        $passed = $true
        $customStatus = $null
        $summary = '✅ An EPM elevation settings policy and an elevation rules policy are configured and assigned.'
    }
    elseif ($settingsAssigned -xor $rulesAssigned) {
        $passed = $false
        $customStatus = 'Investigate'
        $present = if ($settingsAssigned) { 'elevation settings' } else { 'elevation rules' }
        $missing = if ($settingsAssigned) { 'elevation rules' } else { 'elevation settings' }
        $summary = "⚠️ An EPM $present policy is assigned, but no $missing policy is assigned. Manual review needed."
    }
    else {
        $passed = $false
        $customStatus = $null
        $summary = '❌ No Endpoint Privilege Management elevation settings policy or elevation rules policy is configured and assigned.'
    }
    #endregion Assessment Logic

    #region Report Generation
    # Intune portal landing page for Endpoint Privilege Management (Endpoint security > Endpoint Privilege Management)
    $epmPortalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/epm'
    $tableRows = ''
    $totalCount = $epmPolicies.Count
    $policiesToShow = @($epmPolicies | Select-Object -First 10)

    foreach ($policy in $policiesToShow) {
        $policyName = Get-SafeMarkdown -Text $policy.name
        $assignedIcon = if ($policy.isAssigned) { '✅ Yes' } else { '❌ No' }
        $assignmentTarget = if ($policy.assignments -and $policy.assignments.Count -gt 0) {
            Get-PolicyAssignmentTarget -Assignments $policy.assignments
        } else { 'None' }

        $tableRows += "| $policyName | $($policy.PolicyType) | $assignedIcon | $assignmentTarget |`n"
    }

    $formatTemplate = @'

## [Windows Endpoint Privilege Management policies]({3})

{0}

Total EPM policies found: **{1}**

| Policy Name | Policy Type | Assigned | Assignment Targets |
| :---------- | :---------- | :------- | :----------------- |
{2}

'@

    $mdInfo = $formatTemplate -f $summary, $totalCount, $tableRows, $epmPortalLink
    $testResultMarkdown =  $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '51001'
        Title  = 'Windows Endpoint Privilege Management is configured and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($customStatus) { $params.CustomStatus = $customStatus }

    Add-ZtTestResultDetail @params
}
