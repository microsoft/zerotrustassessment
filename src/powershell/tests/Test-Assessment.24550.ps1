
<#
.SYNOPSIS

#>



function Test-Assessment-24550 {
    [ZtTest(
        Category = 'Device',
        ImplementationCost = 'Low',
        MinimumLicense = ('Intune'),
        Pillar = 'Devices',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 24550,
        Title = 'Data on Windows is protected by BitLocker encryption',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

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

    if ( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking Windows BitLocker policy is configured and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query: Retrieve all Windows 10 configuration policies and their assignments
    $sql = @"
    SELECT id, name, description, platforms, to_json(settings) as settings, to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE platforms LIKE '%windows10%'
"@
    $windowsPolicies = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    # Parse JSON settings field
    foreach ($policy in $windowsPolicies) {
        if ($policy.settings -is [string]) {
            $policy.settings = $policy.settings | ConvertFrom-Json
        }
        if ($policy.assignments -is [string]) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }
    }

    # Filter policies to include only those related to Windows BitLocker settings
    $windowsBitLockerPolicies = @()
    foreach ($windowsPolicy in $windowsPolicies) {
        $validSettingValues = @('device_vendor_msft_bitlocker_requiredeviceencryption_1')

        # Get all setting values from the policy (handle both single values and arrays)
        $policySettingValues = $windowsPolicy.settings.settinginstance.choicesettingvalue.value

        # Convert to array if it's a single value to ensure consistent handling
        if ($policySettingValues -isnot [array]) {
            $policySettingValues = @($policySettingValues)
        }

        # Check if any of the policy's setting values match our valid setting values
        $hasValidSetting = $false
        foreach ($settingValues in $policySettingValues) {
            if ($validSettingValues -contains $settingValues) {
                $hasValidSetting = $true
                break
            }
        }

        if ($hasValidSetting) {
            $windowsBitLockerPolicies += $windowsPolicy
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Test Windows BitLocker policy assignments
    $passed = Test-PolicyAssignment -Policies $windowsBitLockerPolicies

    if ($passed) {
        $testResultMarkdown = "At least one Windows BitLocker policy is configured and assigned.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No Windows BitLocker policy is configured or assigned.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Windows BitLocker Policies"
    $tableRows = ""
    $mdInfo = ""

    if ($windowsBitLockerPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($policy in $windowsBitLockerPolicies) {

            $policyName = Get-SafeMarkdown -Text $policy.name
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration'

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

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24550'
        Title  = 'Windows BitLocker policy is configured and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
