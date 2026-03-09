
<#
.SYNOPSIS

#>



function Test-Assessment-24540 {
    [ZtTest(
        Category = 'Device',
        ImplementationCost = 'Low',
        MinimumLicense = ('Intune'),
        Pillar = 'Devices',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 24540,
        Title = 'Windows Firewall policies protect against unauthorized network access',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if ( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking Windows Firewall policies are created and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query: Retrieve all Windows Firewall configuration policies and their assignments
    $sql = @"
    SELECT id, name, description, templateReference, to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE templateReference IS NOT NULL
      AND templateReference.templateFamily = 'endpointSecurityFirewall'
"@
    $firewallPoliciesWithAssignments = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    # Parse JSON settings field
    foreach ($policy in $firewallPoliciesWithAssignments) {
        if ($policy.assignments -is [string]) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Check if at least one policy exists
    if ($firewallPoliciesWithAssignments.Count -gt 0) {

        # Check if at least one policy has assignments
        $assignedPolicies = $firewallPoliciesWithAssignments | Where-Object {
            $_.assignments -and $_.assignments.Count -gt 0
        }

        if ($assignedPolicies.Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "At least one Windows Firewall policy is created and assigned to a group.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "There are no firewall policies assigned to any groups.`n`n%TestResult%"
        }
    }
    else {
        $passed = $false
        $testResultMarkdown = "No Windows Firewall configuration policies found.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Windows Firewall Configuration Policies"
    $tableRows = ""

    if ($firewallPoliciesWithAssignments.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($policy in $firewallPoliciesWithAssignments) {

            $policyName = Get-SafeMarkdown -Text $policy.name
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/firewall'

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $status = "✅ Assigned"
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }
            else {
                $status = "❌ Not assigned"
                $assignmentTarget = 'None'
            }

            $tableRows += "| [$policyName]($portalLink) | $status | $assignmentTarget |`n"
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    else {
        $mdInfo = "No Windows Firewall configuration policies found in this tenant.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24540'
        Title  = 'Windows Firewall Policy is Created and Assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
