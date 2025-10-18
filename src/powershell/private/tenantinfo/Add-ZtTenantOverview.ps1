
<#
.SYNOPSIS
    Add overall tenant info pulled from graph.
#>

function Add-ZtTenantOverview {
    [CmdletBinding()]
    param()

    $activity = "Getting tenant overview"
    Write-ZtProgress -Activity $activity -Status "Processing"

    # Get total count of users in the tenant
    $userCount = Invoke-ZtGraphRequest -RelativeUri 'users/$count'
    $groupCount = Invoke-ZtGraphRequest -RelativeUri 'groups/$count'
    $applicationCount = Invoke-ZtGraphRequest -RelativeUri 'applications/$count'
    $deviceCount = Invoke-ZtGraphRequest -RelativeUri 'devices/$count'
    $managedDevices = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDeviceOverview' -ApiVersion 'beta'

    $tenantOverview = [PSCustomObject]@{
        UserCount        = $userCount -as [int] ?? 0
        GroupCount       = $groupCount -as [int] ?? 0
        ApplicationCount = $applicationCount -as [int] ?? 0
        DeviceCount      = $deviceCount -as [int] ?? 0
        ManagedDeviceCount = $managedDevices.enrolledDeviceCount -as [int] ?? 0
    }

    Add-ZtTenantInfo -Name "TenantOverview" -Value $tenantOverview

    Write-ZtProgress -Activity $activity -Status "Completed"
}
