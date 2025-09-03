
<#
.SYNOPSIS
    Add Windows enrollment restriction used in Devices config view.
#>

function Add-ZtDeviceEnrollmentRestriction {

    function Get-BlockAllow($blockAllowBoolean) {
        switch($blockAllowBoolean) {
            'true' { return 'Blocked' }
            'false' { return 'Allowed' }
            default { return '' }
        }
    }

    function Get-RoleScopeTag ($roleScopeTagId){

    }

    $activity = "Getting Device enrollment restriction summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $deviceEnrollmentConfigurations = Invoke-ZtGraphRequest -RelativeUri 'DeviceManagement/DeviceEnrollmentConfigurations' -QueryParameters @{ '$expand' = 'assignments' } -ApiVersion 'beta'

    $scopeTags =  Invoke-ZtGraphRequest -RelativeUri 'DeviceManagement/RoleScopeTags' -ApiVersion 'beta'

    # Filter the ones where the id contains '_SinglePlatformRestriction'
    $platformRestrictions = $deviceEnrollmentConfigurations | Where-Object { $_.id -like '*_SinglePlatformRestriction*' }

    # Sort by Priority (descending) then by DisplayName (ascending)
    $platformRestrictions = $platformRestrictions | Sort-Object @{Expression='priority';Descending=$true}, @{Expression='displayName';Ascending=$true}

    # Create the table data structure
    $tableData = @()
    foreach ($enrollmentRestriction in $platformRestrictions) {

        $tableData += [PSCustomObject]@{
            Platform = ''
            Priority = $enrollmentRestriction.priority
            Name = $enrollmentRestriction.displayName
            MDM = ''
            MinVer = ''
            MaxVer = ''
            PersonallyOwned = ''
            BlockedManufacturers = ''
            Scope = ''
            AssignedTo = ''
        }
    }

    # Get all the platform restriction with @odata.type #microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration
    $defaultPlatformRestriction = $deviceEnrollmentConfigurations | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration' }

    $defaultRestrictions = @()

    if ($defaultPlatformRestriction) {

        $defaultPlatforms = @(
            @{
                Name = 'iosRestriction'
                DisplayName = 'iOS/iPadOS'
            },
            @{
                Name = 'windowsRestriction'
                DisplayName = 'Windows'
            },
            @{
                Name = 'androidRestriction'
                DisplayName = 'Android device administrator'
            },
            @{
                Name = 'macOSRestriction'
                DisplayName = 'macOS'
            },
            @{
                Name = 'androidForWorkRestriction'
                DisplayName = 'Android Enterprise (work profile)'
            }
        )

        foreach($defaultPlatform in $defaultPlatforms){
            $propName = $defaultPlatform.Name
            $restriction = $defaultPlatformRestriction.$propName
            $json = $restriction | ConvertTo-Json

            $platformBlockAllow = Get-BlockAllow $restriction.platformBlocked
            $personallyOwnedBlockAllow = Get-BlockAllow $restriction.personalDeviceEnrollmentBlocked

            $tableData += [PSCustomObject]@{
                Platform = $defaultPlatform.DisplayName
                Priority = 'Default'
                Name = 'All users'
                MDM = $platformBlockAllow
                MinVer = $restriction.osMinimumVersion
                MaxVer = $restriction.osMaximumVersion
                PersonallyOwned = $personallyOwnedBlockAllow
                BlockedManufacturers = $restriction.blockedManufacturers | Join-String -Separator ', '
                Scope = ''
                AssignedTo = 'All devices'
            }
        }
    }
    Add-ZtTenantInfo -Name "ConfigDeviceEnrollmentRestriction" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
