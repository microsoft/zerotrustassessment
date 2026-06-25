<#
.SYNOPSIS
    Windows Endpoint Privilege Management is configured and assigned
#>

function Test-Assessment-51001 {
    # CompatibleLicense is intentionally omitted: a custom license check is performed
    # in the function body (verifying the Intune-EPM service plan via subscribedSkus).
    [ZtTest(
        Category = 'Devices',
        ImplementationCost = 'Medium',
        Pillar = 'Devices',
        RiskLevel = 'High',
        Service = ('Graph'),
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

    #region Data Collection
    $activity = 'Checking that Windows Endpoint Privilege Management policies are configured and assigned'
    Write-ZtProgress -Activity $activity

    # Q1: Verify Intune Suite / EPM license is present in the tenant
    $epmLicensed = $false
    $licenseQueryFailed = $false
    try {
        $subscribedSkus = Invoke-ZtGraphRequest -RelativeUri 'subscribedSkus' -ErrorAction Stop
        $epmLicensed = @($subscribedSkus | Where-Object {
            $_.capabilityStatus -eq 'Enabled' -and
            ($_.servicePlans | Where-Object {
                $_.servicePlanName -eq 'Intune-EPM' -and $_.provisioningStatus -eq 'Success'
            })
        }).Count -gt 0
    }
    catch {
        $licenseQueryFailed = $true
        Write-PSFMessage "Failed to retrieve subscribed SKUs: $_" -Tag Test -Level Warning
    }

    # Q2: Retrieve all EPM elevation settings and elevation rules policies
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
            $policyType = 'Elevation Settings'
        }
        elseif ($displayName -match 'Elevation rules') {
            $policyType = 'Elevation Rules'
        }
        $policy | Add-Member -NotePropertyName PolicyType -NotePropertyValue $policyType -Force
    }

    $settingsPolicies = @($epmPolicies | Where-Object { $_.PolicyType -eq 'Elevation Settings' })
    $rulesPolicies    = @($epmPolicies | Where-Object { $_.PolicyType -eq 'Elevation Rules' })

    $settingsAssigned = @($settingsPolicies | Where-Object { $_.assignments -and $_.assignments.Count -gt 0 }).Count -gt 0
    $rulesAssigned    = @($rulesPolicies    | Where-Object { $_.assignments -and $_.assignments.Count -gt 0 }).Count -gt 0
    #endregion Data Collection

    #region Assessment Logic
    if ($licenseQueryFailed) {
        Add-ZtTestResultDetail -TestId '51001' -Status $false -CustomStatus 'Investigate' -Result '⚠️ The licensing check (subscribedSkus) failed — an authorization (401/403) or transient (5xx) error was returned, so EPM license status and policy coverage could not be determined. Re-run after verifying caller permissions — Global Reader at tenant scope.'
        return
    }
    elseif (-not $epmLicensed) {
        Add-ZtTestResultDetail -TestId '51001' -Status $false -Result '❌ Windows endpoints are not protected by centrally governed elevation control — the tenant does not have an active Intune Suite license (no Intune-EPM service plan). EPM is an Intune Suite add-on and cannot be enabled without the license.'
        return
    }
    elseif ($settingsAssigned -and $rulesAssigned) {
        $passed = $true
        $customStatus = $null
        $summary = '✅ At least one Windows Endpoint Privilege Management elevation settings policy is assigned, and at least one EPM elevation rules policy is created and assigned.'
    }
    elseif ($settingsAssigned -xor $rulesAssigned) {
        $passed = $false
        $customStatus = $null
        $present = if ($settingsAssigned) { 'elevation settings' } else { 'elevation rules' }
        $missing = if ($settingsAssigned) { 'elevation rules' } else { 'elevation settings' }
        $summary = "❌ Windows endpoints are not protected by centrally governed elevation control — an EPM $present policy is assigned but no $missing policy is assigned. Both policy types are required."
    }
    else {
        $passed = $false
        $customStatus = $null
        $summary = '❌ Windows endpoints are not protected by centrally governed elevation control — no elevation settings policy or elevation rules policy is configured and assigned.'
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

| Policy Name | Policy Type | Assigned | Status |
| :---------- | :---------- | :------- | :----- |
{3}

'@

        foreach ($policy in ($epmPolicies | Select-Object -First 10)) {
            $policyName = Get-SafeMarkdown -Text $policy.name
            $encodedTechnologies = ([string]$policy.technologies) -replace ',', '%2C'
            $policyLink = "https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/PolicySummaryBlade/policyId/$($policy.id)/isAssigned~/true/technology/$encodedTechnologies/templateId/$($policy.templateReference.templateId)/platformName/$($policy.platforms)"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assigned = '✅ Yes'
                $rowStatus = 'Pass'
            }
            else {
                $assigned = '❌ No'
                $rowStatus = 'Fail'
            }

            $tableRows += "| [$policyName]($policyLink) | $($policy.PolicyType) | $assigned | $rowStatus |`n"
        }

        if ($epmPolicies.Count -gt 10) {
            $tableRows += "| ... | ... | ... | ... |`n"
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
