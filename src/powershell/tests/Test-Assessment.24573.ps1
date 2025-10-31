<#
.SYNOPSIS
    Windows security baseline is configured and assigned
#>

function Test-Assessment-24573 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Medium',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24573,
    	Title = 'Security baselines are applied to Windows devices to strengthen security posture',
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

    $activity = "Checking that a Windows security baseline is configured and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting compliance policies"

    # Query 1: List all compliance policies for Windows in Intune
    $baselinesUri = 'deviceManagement/intents?$expand=assignments'
    $allBaselines = Invoke-ZtGraphRequest -RelativeUri $baselinesUri -ApiVersion beta

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false

    # Check if at least one Windows compliance policy exists
    Write-ZtProgress -Activity $activity -Status "Checking policy assignments"
    $passed = $allBaselines.Count -gt 0 -and $allBaselines.Where{$_.isAssigned}.count -gt 0
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Windows Security Baselines"
    $tableRows = ""
    if ($passed) {
        $testResultMarkdown = "Security baselines are configured and assigned to Windows devices.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No security baselines are configured or assigned to Windows devices in Intune.`n`n%TestResult%"
    }

    if ($allBaselines.Count -gt 0) {
                # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $allBaselines) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/securityBaselines'
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
        TestId = '24573'
        Title  = 'Windows Security Baseline is Configured and Assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
