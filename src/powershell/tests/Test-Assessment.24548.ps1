<#
.SYNOPSIS
    An app protection policy for iOS devices exists
#>

function Test-Assessment-24548 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = "Checking that an app protection policy for iOS devices exists"
    Write-ZtProgress -Activity $activity

    # Query 1: Retrieve all iOS App Protection Policies and their assignments
    $iosAppProtectionPolicies = Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/iosManagedAppProtections?$expand=assignments' -ApiVersion v1.0
    #endregion Data Collection

    #region Assessment Logic
    $passed = $iosAppProtectionPolicies.Count -ne 0 -and $iosAppProtectionPolicies.Where{$_.IsAssigned -eq $true}.count -ne 0

    if ($passed) {
        $testResultMarkdown = "At least one App protection policy for iOS exists and is assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No App protection policy for iOS exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "OS App Protection policies configured for iOS"
    $tableRows = ""

    # Generate markdown table rows for each policy

    if ($iosAppProtectionPolicies.Count -gt 0) {
                # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $iosAppProtectionPolicies) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/protection'
            $status = if ($policy.IsAssigned) {
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
| [$policyName]($portalLink) | $status | $assignmentTarget |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    else {
        $mdInfo = "No iOS App Protection policies were found.`n"
    }

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24548'
        Title              = "An app protection policy for iOS devices exists"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
