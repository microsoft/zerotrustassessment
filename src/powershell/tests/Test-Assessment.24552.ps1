<#
.SYNOPSIS
    Test macOS Firewall Policy is created and assigned
#>



function Test-Assessment-24552 {
    [ZtTest(
        Category = 'Device',
        ImplementationCost = 'Low',
        MinimumLicense = ('Intune'),
        Pillar = 'Devices',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 24552,
        Title = 'macOS Firewall policies protect against unauthorized network access',
        UserImpact = 'High'
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

    $activity = "Checking macOS Firewall Policy is Created and Assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query: Retrieve all macOS policies with mdm and appleRemoteManagement technologies
    # We use unnest(settings) to find the specific firewall setting we are interested in.
    # We also cast assignments to JSON to simplify parsing in PowerShell.
    $sql = @"
    SELECT
        id,
        name,
        to_json(assignments) as assignments,
        list_transform(
            setting.settingInstance.groupSettingCollectionValue[1].children,
            x -> x.choiceSettingValue."value"
        ) as firewallSettingValues
    FROM (
        SELECT
            id,
            name,
            assignments,
            unnest(settings) as setting
        FROM ConfigurationPolicy
        WHERE platforms LIKE '%macOS%'
          AND technologies LIKE '%mdm%'
          AND technologies LIKE '%appleRemoteManagement%'
    )
    WHERE setting.settingInstance.SettingDefinitionID = 'com.apple.security.firewall_com.apple.security.firewall'
"@
    $macOSFirewallPolicies = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    # Parse JSON assignments field
    foreach ($policy in $macOSFirewallPolicies) {
        if ($policy.assignments) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }
    }

    # Filter policies to include only those related to firewall settings
    foreach ($macOSPolicy in $macOSFirewallPolicies) {
        $validSettingIds = @('com.apple.security.firewall_enablefirewall_true')

        # Get all setting definition IDs from the policy (handle both single values and arrays)
        # The SQL query returns this as a list of strings (or list of JSONs)
        $policySettingIds = $macOSPolicy.firewallSettingValues

        # Convert to array if it's a single value to ensure consistent handling
        if ($policySettingIds -isnot [array]) {
            $policySettingIds = @($policySettingIds)
        }

        # Check if any of the policy's setting IDs match our valid setting IDs
        $hasValidSetting = $false
        foreach ($settingId in $policySettingIds) {
            if ($validSettingIds -contains $settingId) {
                $hasValidSetting = $true
                [PSFramework.Object.ObjectHost]::AddNoteProperty($macOSPolicy, 'FirewallSettings', $true)
                break
            }
        }

        if (-not $hasValidSetting) {
             [PSFramework.Object.ObjectHost]::AddNoteProperty($macOSPolicy, 'FirewallSettings', $false)
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Test macOS firewall policy assignments
    $passed = Test-PolicyAssignment -Policies $macOSFirewallPolicies

    if ($passed) {
        $testResultMarkdown = "A macOS firewall policy is configured and assigned in Intune.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No assigned macOS firewall policy was found in Intune.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "macOS Firewall Policies"
    $tableRows = ""

    if ($macOSFirewallPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target | Firewall Status |
| :---------- | :----- | :---------------- | :-------------- |
{1}

'@

        foreach ($policy in $macOSFirewallPolicies) {

            $policyName = Get-SafeMarkdown -Text $policy.name
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration'

            if ($policy.assignments -and $policy.assignments.Count -gt 0) {
                $status = '✅ Assigned'
                $assignmentTarget = Get-PolicyAssignmentTarget -Assignments $policy.assignments
            }
            else {
                $status = '❌ Not assigned'
                $assignmentTarget = 'None'
            }

            if ($policy.FirewallSettings) {
                $firewallSettings = '✅ Enabled'
            }
            else {
                $firewallSettings = '❌ Disabled'
            }

            $tableRows += "| [$policyName]($portalLink) | $status | $assignmentTarget | $firewallSettings |`n"
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    else {
        $mdInfo = ''
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24552'
        Title  = 'macOS - Firewall policy is created and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
