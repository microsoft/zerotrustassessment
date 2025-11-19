
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

    function Get-DesktopDevicesSummary {
        [CmdletBinding()]
        param(
            $Database
        )
        $sql = @"
select operatingSystem, trustType, isCompliant, count(*) count
from Device
where operatingSystem in ('Windows', 'MacMDM') and trustType is not null
group by operatingSystem, trustType, isCompliant
order by operatingSystem, trustType, isCompliant
"@

        # Example output:
        # operatingSystem trustType   isCompliant   cnt
        # Windows         AzureAd     false          19
        # Windows         AzureAd     true           83
        # Windows         ServerAd    false         455
        # Windows         Workplace   true           12
        # Windows         Workplace   false          34
        # MacMDM          AzureAd     false           2
        # MacMDM          AzureAd     true            5
        # MacMDM          Workplace   true            3

        $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

        # Get Windows devices
        $windowsResults = $results | Where-Object { $_.operatingSystem -eq 'Windows' }
        $windowsTotal = ($windowsResults | Measure-Object -Property count -Sum).Sum ?? 0

        # Get macOS devices
        $macOSResults = $results | Where-Object { $_.operatingSystem -eq 'MacMDM' }
        $macOSTotal = ($macOSResults | Measure-Object -Property count -Sum).Sum ?? 0

        # macOS compliance (goes directly to compliance status)
        $macOSCompliant = ($macOSResults | Where-Object { $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum ?? 0
        $macOSNoncompliant = ($macOSResults | Where-Object { $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum ?? 0
        $macOSUnmanaged = $macOSTotal - ($macOSCompliant + $macOSNoncompliant)

        # Windows join types
        $windowsEntraJoined = ($windowsResults | Where-Object { $_.trustType -eq 'AzureAd' } | Measure-Object -Property count -Sum).Sum ?? 0
        $windowsHybridJoined = ($windowsResults | Where-Object { $_.trustType -eq 'ServerAd' } | Measure-Object -Property count -Sum).Sum ?? 0
        $windowsEntraRegistered = ($windowsResults | Where-Object { $_.trustType -eq 'Workplace' } | Measure-Object -Property count -Sum).Sum ?? 0

        # Windows compliance by join type
        $entraJoinedCompliant = ($windowsResults | Where-Object { $_.trustType -eq 'AzureAd' -and $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
        $hybridJoinedCompliant = ($windowsResults | Where-Object { $_.trustType -eq 'ServerAd' -and $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
        $registeredCompliant = ($windowsResults | Where-Object { $_.trustType -eq 'Workplace' -and $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum

        # Windows non-compliant counts
        $entraJoinedNoncompliant = ($windowsResults | Where-Object { $_.trustType -eq 'AzureAd' -and $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
        $hybridJoinedNoncompliant = ($windowsResults | Where-Object { $_.trustType -eq 'ServerAd' -and $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
        $registeredNoncompliant = ($windowsResults | Where-Object { $_.trustType -eq 'Workplace' -and $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum

        # Windows unmanaged where isCompliant is null
        $entraJoinedUnmanaged = $windowsEntraJoined - ($entraJoinedCompliant + $entraJoinedNoncompliant)
        $hybridJoinedUnmanaged = $windowsHybridJoined - ($hybridJoinedCompliant + $hybridJoinedNoncompliant)
        $registeredUnmanaged = $windowsEntraRegistered - ($registeredCompliant + $registeredNoncompliant)

        $nodes = @(
            # Level 1: Desktop devices to OS
            @{
                "source" = "Desktop devices"
                "target" = "Windows"
                "value"  = $windowsTotal
            },
            @{
                "source" = "Desktop devices"
                "target" = "macOS"
                "value"  = $macOSTotal
            },
            # Level 2: Windows to join types
            @{
                "source" = "Windows"
                "target" = "Entra joined"
                "value"  = $windowsEntraJoined
            },
            @{
                "source" = "Windows"
                "target" = "Entra registered"
                "value"  = $windowsEntraRegistered
            },
            @{
                "source" = "Windows"
                "target" = "Entra hybrid joined"
                "value"  = $windowsHybridJoined
            },
            # Level 3: Windows join types to compliance
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
            },

            # Level 2: macOS directly to compliance (no join types)
            @{
                "source" = "macOS"
                "target" = "Compliant"
                "value"  = $macOSCompliant
            },
            @{
                "source" = "macOS"
                "target" = "Non-compliant"
                "value"  = $macOSNoncompliant
            },
            @{
                "source" = "macOS"
                "target" = "Unmanaged"
                "value"  = $macOSUnmanaged
            }
        )

        @{
            "description"       = "Desktop devices (Windows and macOS) by join type and compliance status."
            "nodes"             = $nodes
            "totalDevices"      = $windowsTotal + $macOSTotal
            "entrajoined"       = $windowsEntraJoined
            "entrahybridjoined" = $windowsHybridJoined
            "entrareigstered"   = $windowsEntraRegistered
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
            "description"  = "Mobile devices by compliance status."
            "nodes"        = $nodes
            "totalDevices" = $results | Measure-Object -Property count -Sum | Select-Object -ExpandProperty Sum
        }
    }

    $activity = "Getting mobile device summary"
    Write-ZtProgress -Activity $activity -Status "Processing"

    $desktopDevicesSummary = Get-DesktopDevicesSummary -Database $Database
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
        DesktopDevicesSummary = $desktopDevicesSummary
        ManagedDevices        = $managedDevices
        MobileSummary         = $mobileSummary
        DeviceCompliance      = $deviceCompliance
        DeviceOwnership       = $deviceOwnership
    }

    Add-ZtTenantInfo -Name "DeviceOverview" -Value $deviceOverview

    Write-ZtProgress -Activity $activity -Status "Completed"
}
