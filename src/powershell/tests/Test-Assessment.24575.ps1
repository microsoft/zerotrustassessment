<#
.SYNOPSIS
    A Windows Defender Antivirus policy is created and assigned
#>

function Test-Assessment-24575 {
    [ZtTest(
    	Category = 'Device',
    	ImplementationCost = 'Medium',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce'),
    	TestId = 24575,
    	Title = 'Defender Antivirus policies protect Windows devices from malware',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking that a Windows Defender Antivirus policy is created and assigned "
    Write-ZtProgress -Activity $activity -Status "Getting compliance policies"

    # Query 1: List all Windows Defender Antivirus configurations
    $windowsDefenderAntivirusUri = "deviceManagement/configurationPolicies?`$filter=(platforms has 'windows10') and (technologies has 'mdm' and technologies has 'microsoftSense')&`$expand=settings,assignments"
    $mdmSense = Invoke-ZtGraphRequest -RelativeUri $windowsDefenderAntivirusUri -ApiVersion beta

    $avPolicies = $mdmSense.Where{$_.templateReference.templateFamily -eq 'endpointSecurityAntivirus'}

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Check if at least one notification policy exists and is assigned
    Write-ZtProgress -Activity $activity -Status "Checking Windows Defender Antivirus Policies"
    $passed = $avPolicies.Count -gt 0 -and $avPolicies.assignments.Count -gt 0
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "A Windows Defender Antivirus policy is created and assigned "
    $tableRows = ""
    if ($passed) {
        $testResultMarkdown = "Windows Defender Antivirus policies are configured and assigned in Intune.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No relevant Windows Defender Antivirus policies are configured or assigned.`n`n%TestResult%"
    }

    if ($avPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $avPolicies) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/antivirus'
            $status = if ($policy.assignments.Count -gt 0) {
                '✅ Assigned'
            }
            else {
                '❌ Not Assigned'
            }

            $policyName = Get-SafeMarkdown -Text $policy.name
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += @"
| [$policyName]($portalLink) | $status | $assignmentTarget |`n
"@
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
