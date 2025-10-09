<#
.SYNOPSIS
    Intune Windows Update policy is configured and assigned
#>

function Test-Assessment-24553 {
    [ZtTest(
    	Category = 'Devices',
    	ImplementationCost = 'Medium',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24553,
    	Title = 'Windows Update policy for Windows devices',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = 'Checking that the Intune Windows Update policy is configured and assigned'
    Write-ZtProgress -Activity $activity

    # Retrieve all Windows Update Policies and their assignments
    $windowsUpdatePolicy = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceConfigurations?$expand=assignments' -ApiVersion v1.0 | Where-Object {
        $_.'@odata.type' -eq '#microsoft.graph.windowsUpdateForBusinessConfiguration'
    }
    #endregion Data Collection

    #region Assessment Logic
    # Check if at least one policy has assignments
    $hasAssignments = $false
    foreach ($policy in $windowsUpdatePolicy) {
        if ($policy.assignments -and $policy.assignments.Count -gt 0) {
            $hasAssignments = $true
            break
        }
    }

    $passed = $windowsUpdatePolicy.Count -gt 0 -and $hasAssignments

    if ($passed) {
        $testResultMarkdown = "Windows Update policy is assigned and enforced.`n`n%TestResult%"
    }
    else {
        if ($windowsUpdatePolicy.Count -eq 0) {
            $testResultMarkdown = "No Windows Update policies found.`n`n%TestResult%"
        } else {
            $testResultMarkdown = "Windows Update policy is not assigned or enforced.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Intune Windows Update policy is configured and assigned"
    $tableRows = ""

    # Generate markdown table rows for each policy
    $mdInfo = ""
    if ($windowsUpdatePolicy.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :------------- | :--------- |
{1}

'@

        $tableRows = ""
        foreach ($policy in $windowsUpdatePolicy) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesWindowsMenu/~/windows10Update'
            $status = if ($policy.assignments -and $policy.assignments.count -gt 0) {
                '✅&nbsp;Assigned'
            }
            else {
                '❌&nbsp;Not&nbsp;Assigned'
            }

            $policyName = Get-SafeMarkdown -Text $policy.displayName
            $assignmentTarget = "None"

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }

            $tableRows += "| [$policyName]($portalLink) | $status | $assignmentTarget |`n"
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
