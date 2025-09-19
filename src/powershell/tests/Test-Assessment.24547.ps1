<#
.SYNOPSIS
    Compliance Policy for Android Enterprise Personally-Owned Work Profile is configured and assigned
#>

function Test-Assessment-24547 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = "Checking the compliance policy for Android Enterprise Personally-Owned Work Profile is configured and assigned "
    Write-ZtProgress -Activity $activity

    # Query 1: Retrieve all Android Device WorkProfile Compliance Policies and their assignments
    $androidDeviceWorkProfilePolicies = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceCompliancePolicies?$filter=isOf(''microsoft.graph.androidWorkProfileCompliancePolicy'')&$expand=assignments' -ApiVersion beta

    #region Assessment Logic
    $passed = $androidDeviceWorkProfilePolicies.Count -ne 0 -and $androidDeviceWorkProfilePolicies.Assignments.count -ne 0

    if ($passed) {
        $testResultMarkdown = "At least one compliance policy for Android Enterprise Personally-Owned Work Profile exists and is assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No compliance policy for Android Enterprise Personally-Owned Work Profile exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Compliance policy assignment for Android Enterprise Fully managed device is configured and assigned"
    $tableRows = ""

    # Generate markdown table rows for each policy
    if ($androidDeviceWorkProfilePolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $androidDeviceWorkProfilePolicies) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesComplianceMenu/~/policies'
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
        TestId             = '24547'
        Title              = "Compliance Policy for Android Enterprise Personally-Owned Work Profile is configured and assigned"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
