<#
.SYNOPSIS
    Intune Windows Update policy is configured and assigned
#>

function Test-Assessment-24553 {
    [ZtTest(
    	Category = 'Device management',
    	ImplementationCost = 'Medium',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect engineering systems',
    	TenantType = ('Workforce'),
    	TestId = 24553,
    	Title = 'Windows Update policy is assigned and enforced.',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = "Checking that the Intune Windows Update policy is configured and assigned"
    Write-ZtProgress -Activity $activity

    # Query 1: Retrieve all Windows Update Policies and their assignments
    $windowsUpdatePolicy = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceConfigurations?$expand=assignments' -ApiVersion v1.0 | Where-Object {
        $_.'@odata.type' -eq '#microsoft.graph.windowsUpdateForBusinessConfiguration'
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $windowsUpdatePolicy.Count -ne 0 -and $windowsUpdatePolicy.Assignments.count -ne 0

    if ($passed) {
        $testResultMarkdown = "Windows Update policy is assigned and enforced.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Windows Update policy is not assigned or enforced.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Intune Windows Update policy is configured and assigned"
    $tableRows = ""

    # Generate markdown table rows for each policy
    if ($windowsUpdatePolicy.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $windowsUpdatePolicy) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesWindowsMenu/~/windows10Update'
            $status = if ($policy.assignments.count -gt 0) {
                '✅ Assigned'
            }
            else {
                '❌ Not Assigned'
            }

            $policyName = Get-SafeMarkdown -Text $policy.displayName
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += @"
| [$policyName]($portalLink) | $status | $assignmentTarget |
"@
        }

         # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24553'
        Title              = "Intune Windows Update policy is configured and assigned"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
