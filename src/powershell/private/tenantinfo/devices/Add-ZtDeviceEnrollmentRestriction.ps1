
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
        $scopeTags =  Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/roleScopeTags' -ApiVersion 'beta'
        return ($roleScopeTagId | ConvertTo-Json)
    }

    $activity = "Getting Device enrollment restriction summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $deviceEnrollmentConfigurations = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceEnrollmentConfigurations' -QueryParameters @{ '$expand' = 'assignments' } -ApiVersion 'beta'



    # Filter the ones where the id contains '_SinglePlatformRestriction'
    $platformRestrictions = $deviceEnrollmentConfigurations | Where-Object { $_.deviceEnrollmentConfigurationType -eq 'singlePlatformRestriction' }

    # Sort by Priority (descending) then by DisplayName (ascending)
    $platformRestrictions = $platformRestrictions | Sort-Object @{Expression='priority';Descending=$true}, @{Expression='displayName';Ascending=$true}

    # Create the table data structure
    $tableData = @()
    foreach ($enrollmentRestriction in $platformRestrictions) {

        $tableData += [PSCustomObject]@{
            Platform = $enrollmentRestriction.platformType
            Priority = $enrollmentRestriction.priority
            Name = $enrollmentRestriction.displayName
            MDM = Get-BlockAllow $enrollmentRestriction.platformRestriction.platformBlocked
            MinVer = $enrollmentRestriction.platformRestriction.osMinimumVersion
            MaxVer = $enrollmentRestriction.platformRestriction.osMaximumVersion
            PersonallyOwned = Get-BlockAllow $enrollmentRestriction.platformRestriction.personalDeviceEnrollmentBlocked
            BlockedManufacturers = $enrollmentRestriction.platformRestriction.blockedManufacturers | Join-String -Separator ', '
            Scope = Get-RoleScopeTag $enrollmentRestriction.roleScopeTagId
            AssignedTo = $enrollmentRestriction.assignments | ConvertTo-Json
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

            $tableData += [PSCustomObject]@{
                Platform = $defaultPlatform.DisplayName
                Priority = 'Default'
                Name = 'All users'
                MDM = Get-BlockAllow $restriction.platformBlocked
                MinVer = $restriction.osMinimumVersion
                MaxVer = $restriction.osMaximumVersion
                PersonallyOwned = Get-BlockAllow $restriction.personalDeviceEnrollmentBlocked
                BlockedManufacturers = $restriction.blockedManufacturers | Join-String -Separator ', '
                Scope = ''
                AssignedTo = 'All devices'
            }
        }
    }
    Add-ZtTenantInfo -Name "ConfigDeviceEnrollmentRestriction" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
