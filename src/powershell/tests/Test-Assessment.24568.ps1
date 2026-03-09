
<#
.SYNOPSIS

#>



function Test-Assessment-24568 {
    [ZtTest(
        Category = 'Tenant',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Intune'),
        Pillar = 'Devices',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and isolate production systems',
        TenantType = ('Workforce'),
        TestId = 24568,
        Title = 'Platform SSO is configured to strengthen authentication on macOS devices',
        UserImpact = 'Medium'
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

    <#
.SYNOPSIS
Filters policies based on specific setting configurations and their expected values.

.DESCRIPTION
This function filters an array of policies by checking if they contain specific settings with expected values.
Each setting can have its own path configuration for navigating the policy's JSON structure, making this
function flexible enough to work with different policy types and structures.

.PARAMETER Policies
An array of policy objects to filter. Each policy should contain settings that can be navigated using
the paths specified in RequiredSettings.

.PARAMETER RequiredSettings
A hashtable where each key is a setting definition ID and the value is a configuration object containing:
- ExpectedValues: Array of values that the setting should have
- ContainerPath: Dot-separated path to the container holding the settings (e.g., 'settings.settinginstance.groupSettingCollectionValue.children')
- SettingIdPath: Property name or path to access the setting ID within each container item
- ValuePath: Property name or path to access the setting value within the target setting
- Description: (Optional) Human-readable description of what the setting controls

.OUTPUTS
System.Array
Returns an array of policy objects that contain at least one of the required settings with matching values.

.EXAMPLE
$requiredSettings = @{
    'com.apple.extensiblesso_extensionidentifier' = @{
        ExpectedValues = @('com.microsoft.CompanyPortalMac.ssoextension')
        ContainerPath  = 'settings.settinginstance.groupSettingCollectionValue.children'
        SettingIdPath  = 'settingDefinitionId'
        ValuePath      = 'simplesettingvalue.value'
        Description    = 'Microsoft SSO Extension Identifier'
    }
}

$filteredPolicies = Get-FilteredPoliciesBySetting -Policies $allPolicies -RequiredSettings $requiredSettings

Filters policies to include only those that have the Microsoft SSO extension configured.

.EXAMPLE
$multipleSettings = @{
    'setting.id.one' = @{
        ExpectedValues = @('value1', 'value2')
        ContainerPath  = 'settings.configurations'
        SettingIdPath  = 'id'
        ValuePath      = 'value'
    }
    'setting.id.two' = @{
        ExpectedValues = @('requiredvalue')
        ContainerPath  = 'customSettings.payloadContent'
        SettingIdPath  = 'payloadType'
        ValuePath      = 'payloadContent.value'
    }
}

$filteredPolicies = Get-FilteredPoliciesBySetting -Policies $policies -RequiredSettings $multipleSettings

Filters policies that contain either of two different settings, each located in different JSON paths.

.NOTES
- The function uses a nested helper function Get-NestedProperty to safely navigate object properties
- If any path evaluation fails, the function logs a verbose message and continues with the next setting
- The function returns policies that match ANY of the required settings (OR logic)
- Empty or null policy arrays are handled gracefully by returning an empty array
    #>
    function Get-FilteredPoliciesBySetting {
        [CmdletBinding()]
        param(
            [array]$Policies,
            [hashtable]$RequiredSettings
        )

        <#
        .SYNOPSIS
        Retrieves a nested property value from an object using a dot-separated path.

        .DESCRIPTION
        Traverses an object's properties according to the provided dot-separated path and returns the value found at that path, or $null if any segment is missing.

        .PARAMETER InputObject
        The object from which to retrieve the nested property.

        .PARAMETER Path
        The dot-separated path string indicating the property to retrieve (e.g., 'settings.settinginstance.groupSettingCollectionValue').

        .OUTPUTS
        Returns the value at the specified path, or $null if not found.
        #>
        function Get-NestedProperty {
            [CmdletBinding()]
            param(
                [Parameter(Mandatory)][object]$InputObject,
                [Parameter(Mandatory)][string]$Path
            )
            $current = $InputObject
            foreach ($segment in $Path -split '\.') {
                if ($null -eq $current) {
                    return $null
                }
                $current = $current."$segment"
            }
            return $current
        }

        $filteredPolicies = @()

        foreach ($policy in $Policies) {
            $hasValidConfiguration = $false

            # Check each required setting configuration
            foreach ($settingId in $RequiredSettings.Keys) {
                $settingConfig = $RequiredSettings[$settingId]
                $expectedValues = $settingConfig.ExpectedValues
                $containerPath = $settingConfig.ContainerPath
                $settingIdPath = $settingConfig.SettingIdPath
                $valuePath = $settingConfig.ValuePath

                try {
                    # Get the settings container using the configured path
                    $settingsContainer = Get-NestedProperty -InputObject $policy -Path $containerPath

                    if ($settingsContainer) {
                        # Find the specific setting by ID
                        $targetSetting = $settingsContainer | Where-Object {
                            (Get-NestedProperty -InputObject $_ -Path $settingIdPath) -eq $settingId
                        }

                        if ($targetSetting) {
                            # Get actual values using the configured value path
                            $actualValues = @(Get-NestedProperty -InputObject $targetSetting -Path $valuePath)

                            # Check if any actual value matches any expected value
                            foreach ($actualValue in $actualValues) {
                                if ($expectedValues -contains $actualValue) {
                                    $hasValidConfiguration = $true
                                    break
                                }
                            }
                        }
                    }
                }
                catch {
                    Write-Verbose "Failed to evaluate paths for setting $settingId : $_"
                    continue
                }

                if ($hasValidConfiguration) {
                    break
                }
            }

            if ($hasValidConfiguration) {
                $filteredPolicies += $policy
            }
        }

        return $filteredPolicies
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if ( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking macOS Platform SSO is configured and assigned"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query: Retrieve all macOS policies with mdm and appleRemoteManagement technologies
    $sql = @"
    SELECT id, name, platforms, technologies, to_json(settings) as settings, to_json(assignments) as assignments
    FROM ConfigurationPolicy
    WHERE platforms LIKE '%macOS%'
      AND technologies LIKE '%mdm%'
      AND technologies LIKE '%appleRemoteManagement%'
"@
    $macOSPolicies = Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject

    # Parse JSON settings field
    foreach ($policy in $macOSPolicies) {
        if ($policy.settings -is [string]) {
            $policy.settings = $policy.settings | ConvertFrom-Json
        }
        if ($policy.assignments -is [string]) {
            $policy.assignments = $policy.assignments | ConvertFrom-Json
        }
    }

    # Define setting configurations with their specific paths and expected values
    $requiredSettings = @{
        'com.apple.extensiblesso_extensionidentifier' = @{
            ExpectedValues = @('com.microsoft.CompanyPortalMac.ssoextension')
            ContainerPath  = 'settings.settinginstance.groupSettingCollectionValue.children'
            SettingIdPath  = 'settingDefinitionId'
            ValuePath      = 'simplesettingvalue.value'
            Description    = 'Microsoft SSO Extension Identifier'
        }

        # Example: Different setting with different path structure
        # 'com.apple.anothersetting_id' = @{
        #     ExpectedValues = @('expectedvalue1', 'expectedvalue2')
        #     ContainerPath = 'settings.deviceSettings.configurations'
        #     SettingIdPath = 'id'
        #     ValuePath = 'configurationValue.stringValue'
        #     Description = 'Another SSO Setting'
        # }
    }

    # Filter policies to include only those with required SSO settings
    $macOSSSOPolicies = Get-FilteredPoliciesBySetting -Policies $macOSPolicies -RequiredSettings $requiredSettings
    <#
    $macOSSSOPolicies = @()
    foreach ($macOSPolicy in $macOSPolicies) {
        # Get all setting definition IDs from the policy
        $policySettingIds = @($macOSPolicy.settings.settinginstance.groupSettingCollectionValue.children.settingDefinitionId)

        # Check if policy has any of our required settings with correct values
        $hasValidConfiguration = $false

        foreach ($settingId in $policySettingIds) {
            if ($requiredSettings.ContainsKey($settingId)) {
                $expectedValues = $requiredSettings[$settingId]
                $validSetting = $macOSPolicy.settings?.settinginstance?.groupSettingCollectionValue?.children.where{ $_.settingDefinitionId -eq $settingId }

                # Get actual values from the policy
                $actualValues = @($validSetting.simplesettingvalue?.value)

                # Check if any actual value matches any expected value
                foreach ($actualValue in $actualValues) {
                    if ($expectedValues -contains $actualValue) {
                        $hasValidConfiguration = $true
                        break
                    }
                }

                if ($hasValidConfiguration) {
                    break
                }
            }
        }

        if ($hasValidConfiguration) {
            $macOSSSOPolicies += $macOSPolicy
        }
    }
    #>
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Test macOS SSO policy assignments
    $passed = Test-PolicyAssignment -Policies $macOSSSOPolicies

    if ($passed) {
        $testResultMarkdown = "macOS SSO policies are configured and assigned in Intune.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No assigned macOS SSO policy was found in Intune.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "macOS SSO Policies"
    $tableRows = ""

    if ($macOSSSOPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy Name | Status | Assignment Target |
| :---------- | :----- | :---------------- |
{1}

'@

        foreach ($policy in $macOSSSOPolicies) {

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

            $tableRows += "| [$policyName]($portalLink) | $status | $assignmentTarget |`n"
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24568'
        Title  = 'macOS - Platform SSO is configured and assigned'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
