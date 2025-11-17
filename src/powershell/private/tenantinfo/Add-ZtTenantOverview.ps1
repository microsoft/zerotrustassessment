
<#
.SYNOPSIS
    Add overall tenant info pulled from graph.
#>

function Add-ZtTenantOverview {
    [CmdletBinding()]
    param()

    $activity = "Getting tenant overview"
    Write-ZtProgress -Activity $activity -Status "Processing"

    # Get count of users (excluding guests)

    $userCount = Invoke-ZtGraphRequest -RelativeUri 'users/$count' -Filter "userType ne 'Guest'" -OutputType PSObject
    # Get count of guest users
    $guestCount = Invoke-ZtGraphRequest -RelativeUri 'users/$count' -Filter "userType eq 'Guest'" -OutputType PSObject

    $groupCount = Invoke-ZtGraphRequest -RelativeUri 'groups/$count' -OutputType PSObject
    $applicationCount = Invoke-ZtGraphRequest -RelativeUri 'applications/$count' -OutputType PSObject
    $deviceCount = Invoke-ZtGraphRequest -RelativeUri 'devices/$count' -OutputType PSObject

    if (Get-ZtLicense Intune) {
        $managedDevices = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDeviceOverview' -ApiVersion 'beta'
    }

    $tenantOverview = [PSCustomObject]@{
        UserCount          = $userCount -as [int] ?? 0
        GuestCount         = $guestCount -as [int] ?? 0
        GroupCount         = $groupCount -as [int] ?? 0
        ApplicationCount   = $applicationCount -as [int] ?? 0
        DeviceCount        = $deviceCount -as [int] ?? 0
        ManagedDeviceCount = $managedDevices.enrolledDeviceCount -as [int] ?? 0
    }

    Add-ZtTenantInfo -Name "TenantOverview" -Value $tenantOverview

    Write-ZtProgress -Activity $activity -Status "Completed"
}
