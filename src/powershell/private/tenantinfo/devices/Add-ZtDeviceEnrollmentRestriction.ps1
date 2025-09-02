
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

    Add-ZtTenantInfo -Name "ConfigDeviceEnrollmentRestriction" -Value $tableData

    Write-ZtProgress -Activity $activity -Status "Completed"
}
