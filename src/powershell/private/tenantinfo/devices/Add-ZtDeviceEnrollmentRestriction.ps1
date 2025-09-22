
<#
.SYNOPSIS
    Add Windows enrollment restriction used in Devices config view.
#>

function Add-ZtDeviceEnrollmentRestriction {
    [CmdletBinding()]
    param ()

    function Get-BlockAllow {
        [CmdletBinding()]
        param (
            $blockAllowBoolean
        )
        switch ($blockAllowBoolean) {
            'true' {
                return 'Blocked'
            }
            'false' {
                return 'Allowed'
            }
            default {
                return ''
            }
        }
    }

    function Get-GroupName {
        [CmdletBinding()]
        param (
            $groupId
        )
        $result = $groupId
        $group = Invoke-ZtGraphRequest -RelativeUri "groups/$groupId" -ErrorAction SilentlyContinue
        if ($group) {
            $result = $group.displayName
        }

        return $result
    }

    function Get-PlatformTypes {
        [CmdletBinding()]
        param (

        )
        return @(
            @{
                Name        = 'android'
                DisplayName = 'Android device administrator'
            },
            @{
                Name        = 'androidForWork'
                DisplayName = 'Android Enterprise (work profile)'
            },
            @{
                Name        = 'ios'
                DisplayName = 'iOS/iPadOS'
            },
            @{
                Name        = 'mac'
                DisplayName = 'macOS'
            },
            @{
                Name        = 'linux'
                DisplayName = 'Android Enterprise (work profile)'
            },
            @{
                Name        = 'windows'
                DisplayName = 'Windows'
            },
            @{
                Name        = 'windowsPhone'
                DisplayName = 'Windows Phone'
            }
        )
    }

    function Get-PlatformTypeName {
        [CmdletBinding()]
        param (
            $platformTypeName
        )
        $platformTypes = Get-PlatformTypes
        $platformName = $platformTypes | Where-Object { $_.Name -eq $platformTypeName }
        if ($platformName) {
            return $platformName.DisplayName
        }
        else {
            return $platformTypeName
        }
    }

    function Get-AssignmentText {
        [CmdletBinding()]
        param (
            $assignments
        )
        $text = @()
        foreach ($assignment in $assignments) {
            switch ($assignment.target.'@odata.type') {
                '#microsoft.graph.allLicensedUsersAssignmentTarget' {
                    $text += "All users"
                }

                '#microsoft.graph.groupAssignmentTarget' {
                    $text += Get-GroupName $assignment.target.groupId
                }
            }
        }
        return $text -join ", "
    }

    $activity = "Getting Device enrollment restriction summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $deviceEnrollmentConfigurations = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceEnrollmentConfigurations' -QueryParameters @{ '$expand' = 'assignments' } -ApiVersion 'beta'

    $platformRestrictions = $deviceEnrollmentConfigurations | Where-Object { $_.deviceEnrollmentConfigurationType -eq 'singlePlatformRestriction' }

    # Sort by Priority (descending) then by DisplayName (ascending)
    $platformRestrictions = $platformRestrictions | Sort-Object @{Expression = 'priority'; Descending = $true }, @{Expression = 'displayName'; Ascending = $true }

    # Create the table data structure
    $tableData = @()
    $platformTypes = Get-PlatformTypes
    foreach ($enrollmentRestriction in $platformRestrictions) {

        $tableData += [PSCustomObject]@{
            Platform             = Get-PlatformTypeName $enrollmentRestriction.platformType
            Priority             = $enrollmentRestriction.priority
            Name                 = $enrollmentRestriction.displayName
            MDM                  = Get-BlockAllow $enrollmentRestriction.platformRestriction.platformBlocked
            MinVer               = $enrollmentRestriction.platformRestriction.osMinimumVersion
            MaxVer               = $enrollmentRestriction.platformRestriction.osMaximumVersion
            PersonallyOwned      = Get-BlockAllow $enrollmentRestriction.platformRestriction.personalDeviceEnrollmentBlocked
            BlockedManufacturers = $enrollmentRestriction.platformRestriction.blockedManufacturers | Join-String -Separator ', '
            Scope                = Get-ZtRoleScopeTag $enrollmentRestriction.roleScopeTagIds
            AssignedTo           = Get-AssignmentText($enrollmentRestriction.assignments)
        }
    }

    # Get all the platform restriction with @odata.type #microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration
    $defaultPlatformRestriction = $deviceEnrollmentConfigurations | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration' }

    $defaultRestrictions = @()

    if ($defaultPlatformRestriction) {

        $defaultPlatforms = @(
            @{
                Name        = 'iosRestriction'
                DisplayName = 'iOS/iPadOS'
            },
            @{
                Name        = 'windowsRestriction'
                DisplayName = 'Windows'
            },
            @{
                Name        = 'androidRestriction'
                DisplayName = 'Android device administrator'
            },
            @{
                Name        = 'macOSRestriction'
                DisplayName = 'macOS'
            },
            @{
                Name        = 'androidForWorkRestriction'
                DisplayName = 'Android Enterprise (work profile)'
            }
        )

        foreach ($defaultPlatform in $defaultPlatforms) {
            $propName = $defaultPlatform.Name
            $restriction = $defaultPlatformRestriction.$propName
            $json = $restriction | ConvertTo-Json

            $tableData += [PSCustomObject]@{
                Platform             = $defaultPlatform.DisplayName
                Priority             = 'Default'
                Name                 = 'All users'
                MDM                  = Get-BlockAllow $restriction.platformBlocked
                MinVer               = $restriction.osMinimumVersion
                MaxVer               = $restriction.osMaximumVersion
                PersonallyOwned      = Get-BlockAllow $restriction.personalDeviceEnrollmentBlocked
                BlockedManufacturers = $restriction.blockedManufacturers | Join-String -Separator ', '
                Scope                = ''
                AssignedTo           = 'All devices'
            }
        }
    }
    Add-ZtTenantInfo -Name "ConfigDeviceEnrollmentRestriction" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
