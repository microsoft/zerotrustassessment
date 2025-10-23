
<#
.SYNOPSIS
    Add Device overview information to tenant info.
#>

function Add-ZtDeviceOverview {
    [CmdletBinding()]
    param(
        $Database
    )

    function Get-DeviceOwnership {
        [CmdletBinding()]
        param(
            $Database
        )
        $sql = @"
select deviceOwnership, count(*) count
from Device
where accountEnabled and "isManaged"
group by deviceOwnership
order by deviceOwnership
"@

        $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

        $corporate = ($results | Where-Object { $_.deviceOwnership -eq 'Company' } | Select-Object -ExpandProperty count) ?? 0
        $personal = ($results | Where-Object { $_.deviceOwnership -eq 'Personal' } | Select-Object -ExpandProperty count) ?? 0

        @{
            "corporateCount" = $corporate
            "personalCount"  = $personal
        }
    }

    function Get-WindowsJoinSummary {
        [CmdletBinding()]
        param(
            $Database
        )
        $sql = @"
select operatingSystem, trustType,  isCompliant, count(*) count
from Device
where operatingSystem = 'Windows' and trustType is not null
group by operatingSystem, trustType, isCompliant
order by operatingSystem, trustType, isCompliant
"@

        # Example output:
        # trustType   isCompliant   cnt
        # AzureAd     false          19
        # AzureAd     true           83
        # ServerAd    false         455
        # Workplace   true           12
        # Workplace   false          34

        $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

        # Get count of all AzureAd
        $entraJoined = ($results | Where-Object { $_.trustType -eq 'AzureAd' } | Measure-Object -Property count -Sum).Sum ?? 0
        $hybridJoined = ($results | Where-Object { $_.trustType -eq 'ServerAd' } | Measure-Object -Property count -Sum).Sum ?? 0
        $entraRegistered = ($results | Where-Object { $_.trustType -eq 'Workplace' } | Measure-Object -Property count -Sum).Sum ?? 0

        $entraJoinedCompliant = ($results | Where-Object { $_.trustType -eq 'AzureAd' -and $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
        $hybridJoinedCompliant = ($results | Where-Object { $_.trustType -eq 'ServerAd' -and $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
        $registeredCompliant = ($results | Where-Object { $_.trustType -eq 'Workplace' -and $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum

        # Non-compliant counts
        $entraJoinedNoncompliant = ($results | Where-Object { $_.trustType -eq 'AzureAd' -and $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
        $hybridJoinedNoncompliant = ($results | Where-Object { $_.trustType -eq 'ServerAd' -and $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
        $registeredNoncompliant = ($results | Where-Object { $_.trustType -eq 'Workplace' -and $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum

        # now get unmanaged where isCompliant is null
        $entraJoinedUnmanaged = ($results | Where-Object { $_.trustType -eq 'AzureAd' -and $null -eq $_.isCompliant } | Measure-Object -Property count -Sum).Sum
        $hybridJoinedUnmanaged = ($results | Where-Object { $_.trustType -eq 'ServerAd' -and $null -eq $_.isCompliant } | Measure-Object -Property count -Sum).Sum
        $registeredUnmanaged = ($results | Where-Object { $_.trustType -eq 'Workplace' -and $null -eq $_.isCompliant } | Measure-Object -Property count -Sum).Sum

        $nodes = @(
            @{
                "source" = "Windows"
                "target" = "Entra joined"
                "value"  = $entraJoined
            },
            @{
                "source" = "Windows"
                "target" = "Entra hybrid joined"
                "value"  = $hybridJoined
            },
            @{
                "source" = "Windows"
                "target" = "Entra registered"
                "value"  = $entraRegistered
            },
            @{
                "source" = "Entra joined"
                "target" = "Compliant"
                "value"  = $entraJoinedCompliant
            },
            @{
                "source" = "Entra joined"
                "target" = "Non-compliant"
                "value"  = $entraJoinedNoncompliant
            },
            @{
                "source" = "Entra joined"
                "target" = "Unmanaged"
                "value"  = $entraJoinedUnmanaged
            },
            @{
                "source" = "Entra hybrid joined"
                "target" = "Compliant"
                "value"  = $hybridJoinedCompliant
            },
            @{
                "source" = "Entra hybrid joined"
                "target" = "Non-compliant"
                "value"  = $hybridJoinedNoncompliant
            },
            @{
                "source" = "Entra hybrid joined"
                "target" = "Unmanaged"
                "value"  = $hybridJoinedUnmanaged
            },
            @{
                "source" = "Entra registered"
                "target" = "Compliant"
                "value"  = $registeredCompliant
            },
            @{
                "source" = "Entra registered"
                "target" = "Non-compliant"
                "value"  = $registeredNoncompliant
            },
            @{
                "source" = "Entra registered"
                "target" = "Unmanaged"
                "value"  = $registeredUnmanaged
            }
        )

        @{
            "description"       = "Windows devices by join type and compliance status."
            "nodes"             = $nodes
            "totalDevices"      = $results | Measure-Object -Property count -Sum | Select-Object -ExpandProperty Sum
            "entrajoined"       = $entraJoined
            "entrahybridjoined" = $hybridJoined
            "entrareigstered"   = $entraRegistered
        }
    }

    function Get-MobileSummary {
        [CmdletBinding()]
        param(
            $Database
        )
        $sql = @"
select operatingSystem, deviceOwnership, isCompliant, count(*) count
from Device
where operatingSystem != 'Windows' and isCompliant is not null
group by operatingSystem, deviceOwnership, isCompliant
order by operatingSystem, deviceOwnership, isCompliant
"@

        # Example output:
        # operatingSystem       deviceOwnership     isCompliant   cnt
        # Android               Company             false          19
        # Android               Company             true           83
        # AndroidEnterprise     Personal            false         455
        # AndroidForWork        Company             true           12
        # IPhone                Company             false          34
        # iOS                   Company             true           56

        $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

        # Get Android devices
        $androidCompanyDevices = $results | Where-Object { $_.operatingSystem -like 'Android*' -and $_.deviceOwnership -eq 'Company' }
        $androidPersonalDevices = $results | Where-Object { $_.operatingSystem -like 'Android*' -and $_.deviceOwnership -eq 'Personal' }

        # Get iOS devices
        $iosCompanyDevices = $results | Where-Object { $_.operatingSystem -in @('iOS', 'IPhone') -and $_.deviceOwnership -eq 'Company' }
        $iosPersonalDevices = $results | Where-Object { $_.operatingSystem -in @('iOS', 'IPhone') -and $_.deviceOwnership -eq 'Personal' }

        $androidCompany = ($androidCompanyDevices | Measure-Object -Property count -Sum).Sum ?? 0
        $androidPersonal = ($androidPersonalDevices | Measure-Object -Property count -Sum).Sum ?? 0

        $iosCompany = ($iosCompanyDevices | Measure-Object -Property count -Sum).Sum ?? 0
        $iosPersonal = ($iosPersonalDevices | Measure-Object -Property count -Sum).Sum ?? 0

        $androidCompanyCompliant = ($androidCompanyDevices | Where-Object { $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
        $androidPersonalCompliant = ($androidPersonalDevices | Where-Object { $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
        $iosCompanyCompliant = ($iosCompanyDevices | Where-Object { $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
        $iosPersonalCompliant = ($iosPersonalDevices | Where-Object { $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum

        $androidCompanyNoncompliant = ($androidCompanyDevices | Where-Object { $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
        $androidPersonalNoncompliant = ($androidPersonalDevices | Where-Object { $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
        $iosCompanyNoncompliant = ($iosCompanyDevices | Where-Object { $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
        $iosPersonalNoncompliant = ($iosPersonalDevices | Where-Object { $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum

        $androidTotal = $androidCompany + $androidPersonal
        $iosTotal = $iosCompany + $iosPersonal

        $nodes = @(
            # Level 1: Mobile devices to platforms
            @{
                "source" = "Mobile devices"
                "target" = "Android"
                "value"  = $androidTotal
            },
            @{
                "source" = "Mobile devices"
                "target" = "iOS"
                "value"  = $iosTotal
            },
            # Level 2: Platforms to ownership types
            @{
                "source" = "Android"
                "target" = "Android (Company)"
                "value"  = $androidCompany
            },
            @{
                "source" = "Android"
                "target" = "Android (Personal)"
                "value"  = $androidPersonal
            },
            @{
                "source" = "iOS"
                "target" = "iOS (Company)"
                "value"  = $iosCompany
            },
            @{
                "source" = "iOS"
                "target" = "iOS (Personal)"
                "value"  = $iosPersonal
            },
            # Level 3: Ownership types to compliance status
            @{
                "source" = "Android (Company)"
                "target" = "Compliant"
                "value"  = $androidCompanyCompliant
            },
            @{
                "source" = "Android (Company)"
                "target" = "Non-compliant"
                "value"  = $androidCompanyNoncompliant
            },
            @{
                "source" = "Android (Personal)"
                "target" = "Compliant"
                "value"  = $androidPersonalCompliant
            },
            @{
                "source" = "Android (Personal)"
                "target" = "Non-compliant"
                "value"  = $androidPersonalNoncompliant
            },
            @{
                "source" = "iOS (Company)"
                "target" = "Compliant"
                "value"  = $iosCompanyCompliant
            },
            @{
                "source" = "iOS (Company)"
                "target" = "Non-compliant"
                "value"  = $iosCompanyNoncompliant
            },
            @{
                "source" = "iOS (Personal)"
                "target" = "Compliant"
                "value"  = $iosPersonalCompliant
            },
            @{
                "source" = "iOS (Personal)"
                "target" = "Non-compliant"
                "value"  = $iosPersonalNoncompliant
            }
        )

        @{
            "description"       = "Mobile devices by compliance status."
            "nodes"             = $nodes
            "totalDevices"      = $results | Measure-Object -Property count -Sum | Select-Object -ExpandProperty Sum
        }
    }

    $activity = "Getting mobile device summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $windowsJoinSummary = Get-WindowsJoinSummary -Database $Database
    $deviceOwnership = Get-DeviceOwnership -Database $Database
    $mobileSummary = Get-MobileSummary -Database $Database
    $managedDevices = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDeviceOverview' -ApiVersion 'beta'
    $deviceCompliance = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/deviceCompliancePolicyDeviceStateSummary' -ApiVersion 'beta'

    # Append Desktop, Mobile and Total count
    $managedDevicesDesktopCount = $managedDevices.deviceOperatingSystemSummary.windowsCount + $managedDevices.deviceOperatingSystemSummary.macOSCount
    $managedDevicesMobileCount = $managedDevices.deviceOperatingSystemSummary.iOSCount + $managedDevices.deviceOperatingSystemSummary.androidCount
    $totalCount = $managedDevicesDesktopCount + $managedDevicesMobileCount

    if ($totalCount -gt 0) {
        $managedDevices | Add-Member -MemberType NoteProperty -Name desktopCount -Value $managedDevicesDesktopCount
        $managedDevices | Add-Member -MemberType NoteProperty -Name mobileCount -Value $managedDevicesMobileCount
        $managedDevices | Add-Member -MemberType NoteProperty -Name totalCount -Value $totalCount
    }
    else {
        $managedDevices = $null
    }

    $deviceOverview = [PSCustomObject]@{
        WindowsJoinSummary = $windowsJoinSummary
        ManagedDevices     = $managedDevices
        MobileSummary      = $mobileSummary
        DeviceCompliance   = $deviceCompliance
        DeviceOwnership    = $deviceOwnership
    }

    Add-ZtTenantInfo -Name "DeviceOverview" -Value $deviceOverview

    Write-ZtProgress -Activity $activity -Status "Completed"
}
