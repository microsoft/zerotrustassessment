<#
.SYNOPSIS
    An app protection policy for Android devices exists
#>

function Test-Assessment-24549 {
    [ZtTest(
    	Category = 'Data',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 24549,
    	Title = 'Data on Android is protected by app protection policies',
    	UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    #region Data Collection
    $activity = "Checking that an app protection policy for Android devices exists"
    Write-ZtProgress -Activity $activity

    # Query 1: Retrieve all Android App Protection Policies and their assignments
    $androidAppProtectionPolicies = Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/androidManagedAppProtections?$expand=assignments' -ApiVersion v1.0
    #endregion Data Collection

    #region Assessment Logic
    $passed = $androidAppProtectionPolicies.Count -ne 0 -and $androidAppProtectionPolicies.Where{$_.IsAssigned -eq $true}.count -ne 0

    if ($passed) {
        $testResultMarkdown = "At least one App protection policy for Android exists and is assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No App protection policy for Android exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Android App Protection policies configured for Android"
    $tableRows = ""

    # Generate markdown table rows for each policy
    if ($androidAppProtectionPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $androidAppProtectionPolicies) {
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

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24549'
        Title              = "An app protection policy for Android devices exists"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
