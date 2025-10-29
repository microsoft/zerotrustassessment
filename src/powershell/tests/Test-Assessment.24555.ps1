<#
.SYNOPSIS

#>

function Test-Assessment-24555 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 24555,
    	Title = 'Scope tag configuration is enforced to support delegated administration and least-privilege access',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions
    function Test-PolicyAssignment {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $false)]
            [array]$Policies
        )

        # Return false if $Policies is null or empty
        if (-not $Policies) {
            return $false
        }

        # Check if at least one policy has assignments
        $assignedPolicies = $Policies | Where-Object {
            $_.PSObject.Properties.Match("assignments") -and $_.assignments -and $_.assignments.Count -gt 0
        }

        return $assignedPolicies.Count -gt 0
    }

    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking Intune Scope Tags are configured for delegated administration"
    Write-ZtProgress -Activity $activity -Status "Getting scope tags"

    # Retrieve all role scope tags configured in Intune
    $roleScopeTagsUri = "deviceManagement/roleScopeTags"
    $allRoleScopeTags = Invoke-ZtGraphRequest -RelativeUri $roleScopeTagsUri -ApiVersion 'beta'

    # Filter out default scope tag
    $roleScopeTags = @($allRoleScopeTags | Where-Object { $_.displayName -ne "Default" })

    # Initialize as empty array to avoid uninitialized variable issues
    $scopeTagsWithAssignments = @()

    # Check if at least one role scope tag exists
    if ($roleScopeTags.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status "Checking scope tag assignments"

        # For each (non-default) scope tag retrieve its assignments
        foreach ($scopeTag in $roleScopeTags) {
            $assignmentsUri = "deviceManagement/roleScopeTags/$($scopeTag.id)/assignments"

            $assignments = Invoke-ZtGraphRequest -RelativeUri $assignmentsUri -ApiVersion 'beta'

            $scopeTagWithAssignments = $null

            if ($assignments -and $assignments.Count -gt 0) {
                $isAssigned = $true
            }
            else {
                $isAssigned = $false
            }

            # Add assignment info to scope tag object
            $scopeTagWithAssignments = $scopeTag |
                Add-Member -NotePropertyName 'assignments' -NotePropertyValue $assignments -Force -PassThru |
                    Add-Member -NotePropertyName 'isAssigned' -NotePropertyValue $isAssigned -Force -PassThru

            $scopeTagsWithAssignments += $scopeTagWithAssignments
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Test scope tag assignments
    $passed = Test-PolicyAssignment -Policies $scopeTagsWithAssignments

    if ($passed) {
        $testResultMarkdown = "Delegated administration is enforced with custom Intune Scope Tags assignments.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Only the Default Scope tag exists, or no scope tags are assigned, so delegated administration is not configured.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Scope Tags"
    $tableRows = ""

    if ($roleScopeTags.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Scope Tag Name | Status | Assignment Target |
| :------------- | :----- | :---------------- |
{1}

'@

        foreach ($scopeTagWithAssignments in $scopeTagsWithAssignments) {

            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/RolesLandingMenuBlade/~/scopeTags'

            $status = if ($scopeTagWithAssignments.isAssigned) {
                "✅ Assigned"
            }
            else {
                "❌ Not assigned"
            }

            $assignmentTarget = "None"

            if ($scopeTagWithAssignments.assignments -and $scopeTagWithAssignments.assignments.Count -gt 0) {
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $scopeTagWithAssignments.assignments
            }

$tableRows += @"
| [$(Get-SafeMarkdown($scopeTagWithAssignments.displayName))]($portalLink) | $status | $assignmentTarget |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24555'
        Title  = 'Intune Scope Tags are Configured for Delegated Administration'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
