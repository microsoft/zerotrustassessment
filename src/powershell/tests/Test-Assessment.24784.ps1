<#
.SYNOPSIS
    A Microsoft Defender Antivirus policy is created and assigned in Intune for macOS
#>

function Test-Assessment-24784 {
        [ZtTest(
        	Category = 'Device',
        	ImplementationCost = 'Low',
        	Pillar = 'Devices',
        	RiskLevel = 'High',
        	SfiPillar = 'Protect networks',
        	TenantType = ('Workforce'),
        	TestId = 24784,
        	Title = 'Defender Antivirus policies protect macOS devices from malware',
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

    $activity = "Checking that a Microsoft Defender Antivirus policy is created and assigned in Intune for macOS"
    Write-ZtProgress -Activity $activity -Status "Getting compliance policies"

    # Query 1: List all Microsoft Defender Antivirus configurations for macOS
    $macOSDefenderAntivirusUri = "deviceManagement/configurationPolicies?`$filter=(platforms has 'macOS') and (technologies has 'mdm' and technologies has 'microsoftSense')&`$expand=settings,assignments"
    $mdmMacOSSense = Invoke-ZtGraphRequest -RelativeUri $macOSDefenderAntivirusUri -ApiVersion beta

    $avPolicies = $mdmMacOSSense.Where{$_.templateReference.templateFamily -eq 'endpointSecurityAntivirus'}

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Check if at least one notification policy exists and is assigned
    Write-ZtProgress -Activity $activity -Status "Checking Defender Antivirus Policies for macOS"
    $passed = $avPolicies.Count -gt 0 -and $avPolicies.assignments.Count -gt 0
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "A Microsoft Defender Antivirus policy is created and assigned in Intune for macOS"
    $tableRows = ""
    if ($passed) {
        $testResultMarkdown = "Defender Antivirus policies are configured and assigned in Intune for macOS.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No relevant Defender Antivirus policies are configured or assigned for macOS.`n`n%TestResult%"
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
    else {
        $mdInfo = "No relevant Defender Antivirus policies are configured or assigned for macOS.`n"
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
