
<#
.SYNOPSIS
    Add Windows enrollment restriction used in Devices config view.
#>

function Add-ZtDeviceEnrollmentRestriction {

    $activity = "Getting Device enrollment restriction summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $deviceEnrollmentConfigurations = Invoke-ZtGraphRequest -RelativeUri 'DeviceManagement/DeviceEnrollmentConfigurations' -QueryParameters @{ '$expand' = 'assignments' } -ApiVersion 'beta'

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
                Name = 'windowsMobileRestriction'
                DisplayName = 'Windows Mobile'
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

            Write-Host "Prop: $propName"
            Write-Host $json
            $platformBlockAllow = 'Allowed'
            if($restriction.platformBlocked -eq 'true'){
                $platformBlockAllow = 'Blocked'
            }
            $personallyOwnedBlockAllow = 'Allowed'
            if($restriction.personalDeviceEnrollmentBlocked -eq 'true'){
                $personallyOwnedBlockAllow = 'Blocked'
            }

            $tableData += [PSCustomObject]@{
                Platform = $defaultPlatform.DisplayName
                Priority = $defaultPlatformRestriction.priority
                Name = 'Default'
                MDM = $platformBlockAllow
                MinVer = $restriction.osMinimumVersion
                MaxVer = $restriction.osMaximumVersion
                PersonallyOwned = $personallyOwnedBlockAllow
                BlockedManufacturers = $restriction.blockedManufacturers | Join-String -Separator ', '
                Scope = ''
                AssignedTo = ''
            }
        }
    }
    Add-ZtTenantInfo -Name "ConfigDeviceEnrollmentRestriction" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
