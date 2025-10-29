<#
.SYNOPSIS
    Compliance policy assignment for Android Enterprise Fully managed device is configured and assigned
#>

function Test-Assessment-24545 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24545,
    	Title = 'Compliance policies protect fully managed and corporate-owned Android devices',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    #region Data Collection
    $activity = "Checking the Compliance policy assignment for Android Enterprise Fully managed device is configured and assigned"
    Write-ZtProgress -Activity $activity

    # Query 1: Retrieve all Android Device Owner Compliance Policies and their assignments
    $androidDeviceOwnerPolicies = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceCompliancePolicies?$filter=isOf(''microsoft.graph.androidDeviceOwnerCompliancePolicy'')&$expand=assignments' -ApiVersion beta

    #region Assessment Logic
    $passed = $androidDeviceOwnerPolicies.Count -ne 0 -and $androidDeviceOwnerPolicies.Assignments.count -ne 0

    if ($passed) {
        $testResultMarkdown = "At least one compliance policy for Android Enterprise Fully managed devices exists and is assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No compliance policy for Android Enterprise exists or none are assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Compliance policy assignment for Android Enterprise Fully managed device is configured and assigned"
    $tableRows = ""

    # Generate markdown table rows for each policy
    if ($androidDeviceOwnerPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment |
| :---------- | :----- | :--------- |
{1}

'@

        foreach ($policy in $androidDeviceOwnerPolicies) {
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
    else {
        $mdInfo = "`nNo compliance policy for Android Enterprise exists or none are assigned.`n"
    }

    # Replace the placeholder in the test result markdown with the generated details
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '24545'
        Title              = "Compliance policy assignment for Android Enterprise Fully managed device is configured and assigned"
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
