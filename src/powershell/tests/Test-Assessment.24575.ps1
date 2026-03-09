<#
.SYNOPSIS
    A Windows Defender Antivirus policy is created and assigned
#>

function Test-Assessment-24575 {
    [ZtTest(
        Category = 'Device',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Intune'),
        Pillar = 'Devices',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 24575,
        Title = 'Defender Antivirus policies protect Windows devices from malware',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if ( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking that a Windows Defender Antivirus policy is created and assigned "
    Write-ZtProgress -Activity $activity -Status "Getting compliance policies"

    # Query: Retrieve all Windows 10 policies with mdm and microsoftSense technologies
    $sql = @"
    SELECT id, name, platforms, technologies, templateReference, to_json(settings) as settings, to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE platforms LIKE '%windows10%'
      AND technologies LIKE '%mdm%'
      AND technologies LIKE '%microsoftSense%'
"@
    $mdmSense = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    # Parse JSON settings field
    foreach ($policy in $mdmSense) {
        if ($policy.settings -is [string]) {
            $policy.settings = $policy.settings | ConvertFrom-Json
        }
        if ($policy.assignments -is [string]) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }
    }

    $avPolicies = $mdmSense.Where{ $_.templateReference.templateFamily -eq 'endpointSecurityAntivirus' }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Check if at least one notification policy exists and is assigned
    Write-ZtProgress -Activity $activity -Status "Checking Windows Defender Antivirus Policies"
    $passed = $avPolicies.Count -gt 0 -and $avPolicies.assignments.Count -gt 0

    if ($passed) {
        $testResultMarkdown = "Windows Defender Antivirus policies are configured and assigned in Intune.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No relevant Windows Defender Antivirus policies are configured or assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "A Windows Defender Antivirus policy is created and assigned "
    $tableRows = ""

    if ($avPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $avPolicies) {

            $policyName = Get-SafeMarkdown -Text $policy.name
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/antivirus'

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $status = '✅ Assigned'
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }
            else {
                $status = '❌ Not assigned'
                $assignmentTarget = 'None'
            }

            $tableRows += "| [$policyName]($portalLink) | $status | $assignmentTarget |`n"
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24575'
        Title  = 'A Windows Defender Antivirus policy is created and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
