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
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }
    elseif ($settingsAssigned -and $rulesAssigned) {
        $passed = $true
        $customStatus = $null
        $summary = '✅ Windows Endpoint Privilege Management elevation settings and elevation rules policies are configured and assigned.'
    }
    elseif ($settingsAssigned -xor $rulesAssigned) {
        $passed = $false
        $customStatus = 'Investigate'
        $present = if ($settingsAssigned) { 'elevation settings' } else { 'elevation rules' }
        $missing = if ($settingsAssigned) { 'elevation rules' } else { 'elevation settings' }
        $summary = "⚠️ An EPM $present policy is configured and assigned, but no $missing policy is assigned. Manual review is needed."
    }
    else {
        $passed = $false
        $customStatus = $null
        $summary = '❌ No Endpoint Privilege Management elevation settings policy or elevation rules policy is configured and assigned.'
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = 'Windows Endpoint Privilege Management policies'
    $epmPortalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/epm'
    $tableRows = ''
    $mdInfo = ''

    $testResultMarkdown = "$summary`n`n%TestResult%"

    if ($epmPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## [{0}]({1})

Total EPM policies found: **{2}**

| Policy Name | Policy Type | Assigned | Assignment Target | Status |
| :---------- | :---------- | :------- | :---------------- | :----- |
{3}

'@

        foreach ($policy in ($epmPolicies | Select-Object -First 10)) {
            $policyName = Get-SafeMarkdown -Text $policy.name

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assigned = '✅ Yes'
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
                $rowStatus = 'Pass'
            }
            else {
                $assigned = '❌ No'
                $assignmentTarget = 'None'
                $rowStatus = 'Fail'
            }

            $tableRows += "| $policyName | $($policy.PolicyType) | $assigned | $assignmentTarget | $rowStatus |`n"
        }

        if ($epmPolicies.Count -gt 10) {
            $tableRows += "| ... | ... | ... | ... | ... |`n"
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $epmPortalLink, $epmPolicies.Count, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
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
