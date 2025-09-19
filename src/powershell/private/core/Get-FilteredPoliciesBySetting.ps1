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
Returns an array of policy objects that contain all of the required settings with matching values.

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

Filters policies that contain both required settings, each located in different JSON paths.

.NOTES
- The function uses a nested helper function Get-NestedProperty to safely navigate object properties
- If any path evaluation fails, the function logs a verbose message and continues with the next setting
- The function returns policies that match ALL of the required settings (AND logic)
- Empty or null policy arrays are handled gracefully by returning an empty array
#>
function Get-FilteredPoliciesBySetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Policies,

        [Parameter(Mandatory)]
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
        $matchedSettingsCount = 0

        # Check each required setting configuration
        foreach ($settingId in $RequiredSettings.Keys) {
            $settingConfig = $RequiredSettings[$settingId]
            $expectedValues = $settingConfig.ExpectedValues
            $containerPath = $settingConfig.ContainerPath
            $settingIdPath = $settingConfig.SettingIdPath
            $valuePath = $settingConfig.ValuePath

            $settingMatched = $false

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
                                $settingMatched = $true
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

            if ($settingMatched) {
                $matchedSettingsCount++
            }
        }

        # Policy must match ALL required settings (AND logic)
        if ($matchedSettingsCount -eq $RequiredSettings.Keys.Count) {
            $filteredPolicies += $policy
        }
    }

    return $filteredPolicies
}
