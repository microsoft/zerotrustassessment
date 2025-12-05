<#
.SYNOPSIS
    A Microsoft Defender Antivirus policy is created and assigned in Intune for macOS
#>

function Test-Assessment-24784 {
    [ZtTest(
        Category = 'Device',
        ImplementationCost = 'Low',
        MinimumLicense = ('Intune'),
        Pillar = 'Devices',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 24784,
        Title = 'Defender Antivirus policies protect macOS devices from malware',
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

    $activity = "Checking that a Microsoft Defender Antivirus policy is created and assigned in Intune for macOS"
    Write-ZtProgress -Activity $activity -Status "Getting compliance policies"

    # Query: Retrieve all macOS policies with mdm and microsoftSense technologies
    $sql = @"
    SELECT id, name, platforms, technologies, templateReference, to_json(settings) as settings, to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE platforms LIKE '%macOS%'
      AND technologies LIKE '%mdm%'
      AND technologies LIKE '%microsoftSense%'
"@
    $mdmMacOSSense = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    # Parse JSON settings field
    foreach ($policy in $mdmMacOSSense) {
        if ($policy.settings -is [string]) {
            $policy.settings = $policy.settings | ConvertFrom-Json
        }
        if ($policy.assignments -is [string]) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }
    }

    $avPolicies = $mdmMacOSSense.Where{ $_.templateReference.templateFamily -eq 'endpointSecurityAntivirus' }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Check if at least one notification policy exists and is assigned
    Write-ZtProgress -Activity $activity -Status "Checking Defender Antivirus Policies for macOS"
    $passed = $avPolicies.Count -gt 0 -and $avPolicies.assignments.Count -gt 0

    if ($passed) {
        $testResultMarkdown = "Defender Antivirus policies are configured and assigned in Intune for macOS.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No relevant Defender Antivirus policies are configured or assigned for macOS.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "A Microsoft Defender Antivirus policy is created and assigned in Intune for macOS"
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
        TestId = '24784'
        Title  = 'A Microsoft Defender Antivirus policy is created and assigned in Intune for macOS'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
