<#
.SYNOPSIS
    Add Device overview information to tenant info.
#>

function Add-ZtDeviceOverview {
    [CmdletBinding()]
    param(
        $Database
    )

    Write-ZtProgress -Activity 'Getting device overview' -Status 'Processing'

    $deviceSummaryRows = Invoke-DatabaseQuery -Database $Database -Sql @"
select operatingSystem, count(*) count
from Device
group by operatingSystem
order by operatingSystem
"@

    $windowsCount = ($deviceSummaryRows | Where-Object { $_.operatingSystem -eq 'Windows' } | Measure-Object -Property count -Sum).Sum
    $macOSCount = ($deviceSummaryRows | Where-Object { $_.operatingSystem -in @('MacMDM', 'macOS') } | Measure-Object -Property count -Sum).Sum
    $iosCount = ($deviceSummaryRows | Where-Object { $_.operatingSystem -in @('iOS', 'IPhone', 'iPadOS') } | Measure-Object -Property count -Sum).Sum
    $androidCount = ($deviceSummaryRows | Where-Object { $_.operatingSystem -like 'Android*' } | Measure-Object -Property count -Sum).Sum
    $linuxCount = ($deviceSummaryRows | Where-Object { $_.operatingSystem -eq 'Linux' } | Measure-Object -Property count -Sum).Sum
    $discoveredDeviceTotal = ($deviceSummaryRows | Measure-Object -Property count -Sum).Sum
    if ($null -eq $windowsCount) { $windowsCount = 0 }
    if ($null -eq $macOSCount) { $macOSCount = 0 }
    if ($null -eq $iosCount) { $iosCount = 0 }
    if ($null -eq $androidCount) { $androidCount = 0 }
    if ($null -eq $linuxCount) { $linuxCount = 0 }
    if ($null -eq $discoveredDeviceTotal) { $discoveredDeviceTotal = 0 }

    $mdeSensorInstalledOperatingSystemSummary = $null
    $mdeCoverageQuery = "let Platforms = datatable(Platform:string, PlatformOrder:int) ['Windows', 1, 'macOS', 2, 'iOS/iPadOS', 3, 'Android', 4, 'Linux', 5]; let Coverage = DeviceInfo | where Timestamp > ago(30d) | summarize arg_max(Timestamp, *) by DeviceId | where isempty(MergedToDeviceId) | where OnboardingStatus =~ 'Onboarded' and SensorHealthState =~ 'Active' and isnotempty(AadDeviceId) | extend NormalizedOS=tolower(OSPlatform) | extend Platform=case(NormalizedOS startswith 'windows', 'Windows', NormalizedOS startswith 'mac', 'macOS', NormalizedOS startswith 'ios' or NormalizedOS startswith 'ipados', 'iOS/iPadOS', NormalizedOS startswith 'android', 'Android', NormalizedOS startswith 'linux', 'Linux', 'Other') | where Platform != 'Other' | summarize arg_max(Timestamp, Platform) by AadDeviceId=tolower(AadDeviceId) | summarize MdeSensorInstalledCount=count() by Platform; Platforms | join kind=leftouter Coverage on Platform | project Platform, MdeSensorInstalledCount=coalesce(MdeSensorInstalledCount, 0), PlatformOrder | order by PlatformOrder asc | project-away PlatformOrder"
    try {
        $requestBody = @{ Query = $mdeCoverageQuery; Timespan = 'P30D' } | ConvertTo-Json -Compress
        $mdeCoverageResponse = Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -ApiVersion 'v1.0' -Method POST -Body $requestBody -ErrorAction Stop
        $mdeCoverageRows = @()
        if ($null -ne $mdeCoverageResponse -and $null -ne $mdeCoverageResponse.results) {
            $mdeCoverageRows = @($mdeCoverageResponse.results)
        }
        if ($mdeCoverageRows.Count -gt 0) {
            $mdeSensorInstalledOperatingSystemSummary = [PSCustomObject]@{
                windowsCount = [long](($mdeCoverageRows | Where-Object Platform -eq 'Windows' | Select-Object -First 1).MdeSensorInstalledCount)
                macOSCount   = [long](($mdeCoverageRows | Where-Object Platform -eq 'macOS' | Select-Object -First 1).MdeSensorInstalledCount)
                iosCount     = [long](($mdeCoverageRows | Where-Object Platform -eq 'iOS/iPadOS' | Select-Object -First 1).MdeSensorInstalledCount)
                androidCount = [long](($mdeCoverageRows | Where-Object Platform -eq 'Android' | Select-Object -First 1).MdeSensorInstalledCount)
                linuxCount   = [long](($mdeCoverageRows | Where-Object Platform -eq 'Linux' | Select-Object -First 1).MdeSensorInstalledCount)
            }

            foreach ($platformCoverage in @(
                @{ Platform = 'Windows'; Installed = $mdeSensorInstalledOperatingSystemSummary.windowsCount; Total = $windowsCount },
                @{ Platform = 'macOS'; Installed = $mdeSensorInstalledOperatingSystemSummary.macOSCount; Total = $macOSCount },
                @{ Platform = 'iOS/iPadOS'; Installed = $mdeSensorInstalledOperatingSystemSummary.iosCount; Total = $iosCount },
                @{ Platform = 'Android'; Installed = $mdeSensorInstalledOperatingSystemSummary.androidCount; Total = $androidCount },
                @{ Platform = 'Linux'; Installed = $mdeSensorInstalledOperatingSystemSummary.linuxCount; Total = $linuxCount }
            )) {
                if ([long] $platformCoverage.Installed -gt [long] $platformCoverage.Total) {
                    Write-PSFMessage "MDE sensor coverage is inconsistent for $($platformCoverage.Platform): installed count $($platformCoverage.Installed) exceeds total device count $($platformCoverage.Total)." -Level Warning -Tag TenantInfo
                }
            }
        }
        else {
            Write-PSFMessage 'Advanced hunting returned no result set for MDE sensor coverage.' -Level Warning -Tag TenantInfo
        }
    }
    catch {
        Write-PSFMessage "Failed to retrieve MDE sensor coverage from advanced hunting: $_" -Level Warning -Tag TenantInfo
    }

    $deviceSummary = [PSCustomObject]@{
        description = 'Total devices and Microsoft Defender for Endpoint sensor coverage by OS.'
        deviceOperatingSystemSummary = [PSCustomObject]@{
            windowsCount = $windowsCount
            macOSCount   = $macOSCount
            iosCount     = $iosCount
            androidCount = $androidCount
            linuxCount   = $linuxCount
        }
        totalDevices = $discoveredDeviceTotal
    }
    if ($null -ne $mdeSensorInstalledOperatingSystemSummary) {
        $deviceSummary | Add-Member -MemberType NoteProperty -Name mdeSensorInstalledOperatingSystemSummary -Value $mdeSensorInstalledOperatingSystemSummary
    }

    $desktopRows = Invoke-DatabaseQuery -Database $Database -Sql @"
select operatingSystem, trustType, isCompliant, count(*) count
from Device
where operatingSystem in ('Windows', 'MacMDM') and trustType is not null
group by operatingSystem, trustType, isCompliant
order by operatingSystem, trustType, isCompliant
"@

    $windowsRows = @($desktopRows | Where-Object { $_.operatingSystem -eq 'Windows' })
    $macRows = @($desktopRows | Where-Object { $_.operatingSystem -eq 'MacMDM' })

    $windowsTotal = ($windowsRows | Measure-Object -Property count -Sum).Sum
    $macTotal = ($macRows | Measure-Object -Property count -Sum).Sum
    $windowsEntraJoined = ($windowsRows | Where-Object { $_.trustType -eq 'AzureAd' } | Measure-Object -Property count -Sum).Sum
    $windowsHybridJoined = ($windowsRows | Where-Object { $_.trustType -eq 'ServerAd' } | Measure-Object -Property count -Sum).Sum
    $windowsEntraRegistered = ($windowsRows | Where-Object { $_.trustType -eq 'Workplace' } | Measure-Object -Property count -Sum).Sum
    $entraJoinedCompliant = ($windowsRows | Where-Object { $_.trustType -eq 'AzureAd' -and $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
    $hybridJoinedCompliant = ($windowsRows | Where-Object { $_.trustType -eq 'ServerAd' -and $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
    $registeredCompliant = ($windowsRows | Where-Object { $_.trustType -eq 'Workplace' -and $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
    $entraJoinedNoncompliant = ($windowsRows | Where-Object { $_.trustType -eq 'AzureAd' -and $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
    $hybridJoinedNoncompliant = ($windowsRows | Where-Object { $_.trustType -eq 'ServerAd' -and $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
    $registeredNoncompliant = ($windowsRows | Where-Object { $_.trustType -eq 'Workplace' -and $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
    $macCompliant = ($macRows | Where-Object { $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
    $macNoncompliant = ($macRows | Where-Object { $_.isCompliant -eq $false } | Measure-Object -Property count -Sum).Sum
    if ($null -eq $windowsTotal) { $windowsTotal = 0 }
    if ($null -eq $macTotal) { $macTotal = 0 }
    if ($null -eq $windowsEntraJoined) { $windowsEntraJoined = 0 }
    if ($null -eq $windowsHybridJoined) { $windowsHybridJoined = 0 }
    if ($null -eq $windowsEntraRegistered) { $windowsEntraRegistered = 0 }
    if ($null -eq $entraJoinedCompliant) { $entraJoinedCompliant = 0 }
    if ($null -eq $hybridJoinedCompliant) { $hybridJoinedCompliant = 0 }
    if ($null -eq $registeredCompliant) { $registeredCompliant = 0 }
    if ($null -eq $entraJoinedNoncompliant) { $entraJoinedNoncompliant = 0 }
    if ($null -eq $hybridJoinedNoncompliant) { $hybridJoinedNoncompliant = 0 }
    if ($null -eq $registeredNoncompliant) { $registeredNoncompliant = 0 }
    if ($null -eq $macCompliant) { $macCompliant = 0 }
    if ($null -eq $macNoncompliant) { $macNoncompliant = 0 }

    $entraJoinedUnmanaged = $windowsEntraJoined - ($entraJoinedCompliant + $entraJoinedNoncompliant)
    $hybridJoinedUnmanaged = $windowsHybridJoined - ($hybridJoinedCompliant + $hybridJoinedNoncompliant)
    $registeredUnmanaged = $windowsEntraRegistered - ($registeredCompliant + $registeredNoncompliant)
    $macUnmanaged = $macTotal - ($macCompliant + $macNoncompliant)

    $desktopNodes = [System.Collections.Generic.List[object]]::new()
    foreach ($link in @(
        @{ source = 'Desktop devices'; target = 'Windows'; value = $windowsTotal },
        @{ source = 'Desktop devices'; target = 'macOS'; value = $macTotal },
        @{ source = 'Windows'; target = 'Entra joined'; value = $windowsEntraJoined },
        @{ source = 'Windows'; target = 'Entra registered'; value = $windowsEntraRegistered },
        @{ source = 'Windows'; target = 'Entra hybrid joined'; value = $windowsHybridJoined },
        @{ source = 'Entra joined'; target = 'Compliant'; value = $entraJoinedCompliant },
        @{ source = 'Entra joined'; target = 'Non-compliant'; value = $entraJoinedNoncompliant },
        @{ source = 'Entra joined'; target = 'Unmanaged'; value = $entraJoinedUnmanaged },
        @{ source = 'Entra hybrid joined'; target = 'Compliant'; value = $hybridJoinedCompliant },
        @{ source = 'Entra hybrid joined'; target = 'Non-compliant'; value = $hybridJoinedNoncompliant },
        @{ source = 'Entra hybrid joined'; target = 'Unmanaged'; value = $hybridJoinedUnmanaged },
        @{ source = 'Entra registered'; target = 'Compliant'; value = $registeredCompliant },
        @{ source = 'Entra registered'; target = 'Non-compliant'; value = $registeredNoncompliant },
        @{ source = 'Entra registered'; target = 'Unmanaged'; value = $registeredUnmanaged },
        @{ source = 'macOS'; target = 'Compliant'; value = $macCompliant },
        @{ source = 'macOS'; target = 'Non-compliant'; value = $macNoncompliant },
        @{ source = 'macOS'; target = 'Unmanaged'; value = $macUnmanaged }
    )) {
        if ($link.value -gt 0) {
            $desktopNodes.Add([PSCustomObject]$link)
        }
    }

    $desktopDevicesSummary = [PSCustomObject]@{
        description       = 'Desktop devices (Windows and macOS) by join type and compliance status.'
        nodes             = $desktopNodes
        totalDevices      = $windowsTotal + $macTotal
        entrajoined       = $windowsEntraJoined
        entrahybridjoined = $windowsHybridJoined
        entrareigstered   = $windowsEntraRegistered
    }

    $mobileRows = Invoke-DatabaseQuery -Database $Database -Sql @"
select operatingSystem, isCompliant, count(*) count
from Device
where operatingSystem like 'Android%' or operatingSystem in ('iOS', 'IPhone', 'iPadOS')
group by operatingSystem, isCompliant
order by operatingSystem, isCompliant
"@

    $androidRows = @($mobileRows | Where-Object { $_.operatingSystem -like 'Android*' })
    $iosRows = @($mobileRows | Where-Object { $_.operatingSystem -in @('iOS', 'IPhone', 'iPadOS') })
    $androidTotal = ($androidRows | Measure-Object -Property count -Sum).Sum
    $iosTotal = ($iosRows | Measure-Object -Property count -Sum).Sum
    $androidCompliant = ($androidRows | Where-Object { $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
    $iosCompliant = ($iosRows | Where-Object { $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
    if ($null -eq $androidTotal) { $androidTotal = 0 }
    if ($null -eq $iosTotal) { $iosTotal = 0 }
    if ($null -eq $androidCompliant) { $androidCompliant = 0 }
    if ($null -eq $iosCompliant) { $iosCompliant = 0 }
    $androidNoncompliant = [Math]::Max(0, $androidTotal - $androidCompliant)
    $iosNoncompliant = [Math]::Max(0, $iosTotal - $iosCompliant)

    $mobileNodes = [System.Collections.Generic.List[object]]::new()
    foreach ($link in @(
        @{ source = 'Mobile devices'; target = 'Android'; value = $androidTotal },
        @{ source = 'Mobile devices'; target = 'iOS'; value = $iosTotal },
        @{ source = 'Android'; target = 'Compliant'; value = $androidCompliant },
        @{ source = 'Android'; target = 'Non-compliant'; value = $androidNoncompliant },
        @{ source = 'iOS'; target = 'Compliant'; value = $iosCompliant },
        @{ source = 'iOS'; target = 'Non-compliant'; value = $iosNoncompliant }
    )) {
        if ($link.value -gt 0) {
            $mobileNodes.Add([PSCustomObject]$link)
        }
    }

    $mobileSummary = [PSCustomObject]@{
        description  = 'Mobile devices by platform and compliance status.'
        nodes        = $mobileNodes
        totalDevices = $androidTotal + $iosTotal
    }

    $ownershipRows = Invoke-DatabaseQuery -Database $Database -Sql @"
select deviceOwnership, count(*) count
from Device
where accountEnabled and "isManaged"
group by deviceOwnership
order by deviceOwnership
"@
    $corporate = ($ownershipRows | Where-Object { $_.deviceOwnership -eq 'Company' } | Select-Object -ExpandProperty count)
    $personal = ($ownershipRows | Where-Object { $_.deviceOwnership -eq 'Personal' } | Select-Object -ExpandProperty count)
    if ($null -eq $corporate) { $corporate = 0 }
    if ($null -eq $personal) { $personal = 0 }
    $deviceOwnership = [PSCustomObject]@{
        corporateCount = $corporate
        personalCount  = $personal
    }

    $complianceRows = Invoke-DatabaseQuery -Database $Database -Sql @"
select isCompliant, count(*) count
from Device
group by isCompliant
order by isCompliant
"@
    $compliantCount = ($complianceRows | Where-Object { $_.isCompliant -eq $true } | Measure-Object -Property count -Sum).Sum
    $totalComplianceCount = ($complianceRows | Measure-Object -Property count -Sum).Sum
    if ($null -eq $compliantCount) { $compliantCount = 0 }
    if ($null -eq $totalComplianceCount) { $totalComplianceCount = 0 }
    $nonCompliantCount = [Math]::Max(0, $totalComplianceCount - $compliantCount)
    if (($compliantCount + $nonCompliantCount) -le 0 -and $discoveredDeviceTotal -gt 0) {
        $nonCompliantCount = $discoveredDeviceTotal
    }
    $deviceCompliance = [PSCustomObject]@{
        '@odata.context'         = $null
        id                       = $null
        inGracePeriodCount       = 0
        configManagerCount       = 0
        unknownDeviceCount       = 0
        notApplicableDeviceCount = 0
        compliantDeviceCount     = $compliantCount
        remediatedDeviceCount    = 0
        nonCompliantDeviceCount  = $nonCompliantCount
        errorDeviceCount         = 0
        conflictDeviceCount      = 0
    }

    $managedSummaryRow = Invoke-DatabaseQuery -Database $Database -Sql @"
select
    sum(case when operatingSystem = 'Windows' then 1 else 0 end) as windowsCount,
    sum(case when operatingSystem in ('MacMDM', 'macOS') then 1 else 0 end) as macOSCount,
    sum(case when operatingSystem in ('iOS', 'IPhone') then 1 else 0 end) as iOSCount,
    sum(case when operatingSystem like 'Android%' then 1 else 0 end) as androidCount,
    sum(case when operatingSystem = 'Linux' then 1 else 0 end) as linuxCount,
    count(*) as totalCount
from Device
where accountEnabled and "isManaged"
"@

    $fallbackWindows = $managedSummaryRow.windowsCount -as [int]
    $fallbackMacOS = $managedSummaryRow.macOSCount -as [int]
    $fallbackIOS = $managedSummaryRow.iOSCount -as [int]
    $fallbackAndroid = $managedSummaryRow.androidCount -as [int]
    $fallbackLinux = $managedSummaryRow.linuxCount -as [int]
    if ($null -eq $fallbackWindows) { $fallbackWindows = 0 }
    if ($null -eq $fallbackMacOS) { $fallbackMacOS = 0 }
    if ($null -eq $fallbackIOS) { $fallbackIOS = 0 }
    if ($null -eq $fallbackAndroid) { $fallbackAndroid = 0 }
    if ($null -eq $fallbackLinux) { $fallbackLinux = 0 }
    $fallbackManagedDevices = [PSCustomObject]@{
        deviceOperatingSystemSummary = [PSCustomObject]@{
            windowsCount = $fallbackWindows
            macOSCount   = $fallbackMacOS
            iosCount     = $fallbackIOS
            androidCount = $fallbackAndroid
            linuxCount   = $fallbackLinux
        }
        enrolledDeviceCount = $fallbackWindows + $fallbackMacOS + $fallbackIOS + $fallbackAndroid
        desktopCount        = $fallbackWindows + $fallbackMacOS
        mobileCount         = $fallbackIOS + $fallbackAndroid
        totalCount          = $fallbackWindows + $fallbackMacOS + $fallbackIOS + $fallbackAndroid
    }

    if (Get-ZtLicense Intune) {
        Write-PSFMessage 'Intune license found. Using Intune API for device details.' -Level Debug -Tag License
        try {
            $managedDevices = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDeviceOverview' -ApiVersion 'beta'
            $managedDesktopCount = $managedDevices.deviceOperatingSystemSummary.windowsCount + $managedDevices.deviceOperatingSystemSummary.macOSCount
            $managedMobileCount = $managedDevices.deviceOperatingSystemSummary.iOSCount + $managedDevices.deviceOperatingSystemSummary.androidCount
            $managedTotalCount = $managedDesktopCount + $managedMobileCount
            if ($managedTotalCount -gt 0) {
                $managedDevices | Add-Member -MemberType NoteProperty -Name desktopCount -Value $managedDesktopCount -Force
                $managedDevices | Add-Member -MemberType NoteProperty -Name mobileCount -Value $managedMobileCount -Force
                $managedDevices | Add-Member -MemberType NoteProperty -Name totalCount -Value $managedTotalCount -Force
            }
            else {
                $managedDevices = $fallbackManagedDevices
            }
        }
        catch {
            Write-PSFMessage 'Failed to retrieve Intune managed device overview. Falling back to Entra device data.' -Level Warning -Tag License
            $managedDevices = $fallbackManagedDevices
        }
    }
    else {
        Write-PSFMessage 'Intune license not found. Using Entra device data for device details.' -Level Debug -Tag License
        $managedDevices = $fallbackManagedDevices
    }

    # Preserve null when Defender/TVM data is unavailable so the report can show no data.
    $huntingQuery = @'
let OperationalControls = DeviceTvmSecureConfigurationAssessmentKB
| where ConfigurationName in~ ('Turn on Microsoft Defender Antivirus', 'Turn on real-time protection')
| distinct ConfigurationId;
let ProtectedMdeDevices = DeviceTvmSecureConfigurationAssessment
| where Timestamp > ago(7d)
| join kind=inner OperationalControls on ConfigurationId
| summarize arg_max(Timestamp, IsApplicable, IsCompliant) by DeviceId, ConfigurationId
| where IsApplicable == true
| summarize ApplicableControls=count(), InconclusiveOrNonCompliantControls=countif(IsCompliant == false or isnull(IsCompliant)) by DeviceId
| where ApplicableControls > 0 and InconclusiveOrNonCompliantControls == 0
| project DeviceId;
DeviceInfo
| where Timestamp > ago(30d)
| summarize arg_max(Timestamp, AadDeviceId) by DeviceId
| where isnotempty(AadDeviceId)
| join kind=leftsemi ProtectedMdeDevices on DeviceId
| summarize by AadDeviceId=tolower(AadDeviceId)
| summarize ProtectedDeviceCount=count()
'@

    $protectedDeviceCount = $null
    try {
        $huntingBody = @{ query = $huntingQuery; timespan = 'P30D' } | ConvertTo-Json -Compress
        $huntingResult = Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -ApiVersion beta -Method POST -Body $huntingBody -ErrorAction Stop
        $huntingRows = @()
        if ($null -ne $huntingResult -and $null -ne $huntingResult.results) {
            $huntingRows = @($huntingResult.results)
        }
        $hasProtectedDeviceCount = $huntingRows.Count -eq 1 -and
            $null -ne $huntingRows[0].PSObject.Properties['ProtectedDeviceCount']
        $parsedProtectedDeviceCount = 0L

        if (-not $hasProtectedDeviceCount -or
            -not [long]::TryParse([string]$huntingRows[0].ProtectedDeviceCount, [ref]$parsedProtectedDeviceCount) -or
            $parsedProtectedDeviceCount -lt 0) {
            Write-PSFMessage "Advanced Hunting antivirus protection query returned an invalid result shape or count (row count: $($huntingRows.Count))." -Level Warning -Tag Devices
        }
        else {
            $protectedDeviceCount = $parsedProtectedDeviceCount
            if ($protectedDeviceCount -eq 0) {
                Write-PSFMessage 'Advanced Hunting antivirus protection query returned zero protected devices. Verify that the tenant exposes the expected Defender Antivirus controls in DeviceTvmSecureConfigurationAssessmentKB.' -Level Warning -Tag Devices
            }
            else {
                Write-PSFMessage "Advanced Hunting antivirus protection query completed with $protectedDeviceCount protected devices." -Level Debug -Tag Devices
            }
        }
    }
    catch {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Unable to retrieve Defender antivirus protection counts from Advanced Hunting (HTTP $httpStatus): $($_.Exception.Message)" -Level Warning -Tag Devices
    }

    $deviceAntivirusProtection = [PSCustomObject]@{
        protectedDeviceCount = $protectedDeviceCount
    }

    $deviceOverview = [PSCustomObject]@{
        DeviceSummary             = $deviceSummary
        DesktopDevicesSummary     = $desktopDevicesSummary
        ManagedDevices            = $managedDevices
        MobileSummary             = $mobileSummary
        DeviceCompliance          = $deviceCompliance
        DeviceOwnership           = $deviceOwnership
        DeviceAntivirusProtection = $deviceAntivirusProtection
    }

    Add-ZtTenantInfo -Name 'DeviceOverview' -Value $deviceOverview

    Write-ZtProgress -Activity 'Getting device overview' -Status 'Completed'
}
