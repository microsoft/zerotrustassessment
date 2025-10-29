<#
.SYNOPSIS
    Device enrollment notification is configured and assigned
#>

function Test-Assessment-24572 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24572,
    	Title = 'Device enrollment notifications are enforced to ensure user awareness and secure onboarding',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking that a device enrollment notification is configured and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting compliance policies"

    # Query 1: List all Enrollment Notification configurations
    $enrollmentNotificationsUri = "deviceManagement/deviceEnrollmentConfigurations?`$expand=assignments&`$filter=deviceEnrollmentConfigurationType eq 'EnrollmentNotificationsConfiguration'"
    $enrollmentNotifications = Invoke-ZtGraphRequest -RelativeUri $enrollmentNotificationsUri -ApiVersion beta

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Check if at least one notification policy exists and is assigned
    Write-ZtProgress -Activity $activity -Status "Checking Enrollment Notifications"
    $passed = $enrollmentNotifications.Count -gt 0 -and $enrollmentNotifications.assignments.Count -gt 0
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Device enrollment notifications"
    $tableRows = ""
    if ($passed) {
        $testResultMarkdown = "At least one device enrollment notification is configured and assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No device enrollment notification is configured or assigned in Intune.`n`n%TestResult%"
    }

    if ($enrollmentNotifications.Count -gt 0) {
                # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $enrollmentNotifications) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityBaselineSummaryMenu/~/profiles/summaryName/Security%20Baseline%20for%20Windows%2010%20and%20later/'
            $status = if ($policy.assignments.Count -gt 0) {
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

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24572'
        Title  = 'Device enrollment notification is configured and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
