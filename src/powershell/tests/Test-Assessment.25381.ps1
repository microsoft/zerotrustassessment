<#
.SYNOPSIS
    Validates that traffic forwarding profiles are enabled in Global Secure Access.

.DESCRIPTION
    This test checks if traffic forwarding profiles for Microsoft 365, Private Access,
    and Internet Access are enabled to ensure network traffic is routed through
    Global Secure Access for security policy enforcement.

.NOTES
    Test ID: 25381
    Category: Access control
    Required API: networkAccess/forwardingProfiles (beta)
#>

function Test-Assessment-25381 {
    [ZtTest(
        Category = 'Access control',
        ImplementationCost = 'Medium',
        MinimumLicense = ('P2'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25381,
        Title = 'Network traffic is routed through Global Secure Access for security policy enforcement',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking traffic forwarding profiles configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting traffic forwarding profiles'

    # Query all traffic forwarding profiles
    $forwardingProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/forwardingProfiles' -ApiVersion beta

    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $m365Profile = $null
    $privateProfile = $null
    $internetProfile = $null
    #endregion Data Collection

    #region Assessment Logic
    if ($null -eq $forwardingProfiles -or $forwardingProfiles.Count -eq 0) {
        # No profiles found - fail
        $passed = $false
        $testResultMarkdown = "❌ No traffic forwarding profiles found. Global Secure Access is not configured.`n`n%TestResult%"
    }
    else {
        # Categorize profiles by traffic type
        foreach ($profile in $forwardingProfiles) {
            switch ($profile.trafficForwardingType) {
                'm365' { $m365Profile = $profile }
                'private' { $privateProfile = $profile }
                'internet' { $internetProfile = $profile }
            }
        }

        # Count enabled and disabled profiles
        $enabledProfiles = @()
        $disabledProfiles = @()

        if ($m365Profile) {
            if ($m365Profile.state -eq 'enabled') {
                $enabledProfiles += $m365Profile
            }
            else {
                $disabledProfiles += $m365Profile
            }
        }

        if ($privateProfile) {
            if ($privateProfile.state -eq 'enabled') {
                $enabledProfiles += $privateProfile
            }
            else {
                $disabledProfiles += $privateProfile
            }
        }

        if ($internetProfile) {
            if ($internetProfile.state -eq 'enabled') {
                $enabledProfiles += $internetProfile
            }
            else {
                $disabledProfiles += $internetProfile
            }
        }

        # Determine pass/fail/warning status
        $totalProfiles = $enabledProfiles.Count + $disabledProfiles.Count

        if ($disabledProfiles.Count -eq 0) {
            # All profiles enabled - pass
            $passed = $true
            $testResultMarkdown = "✅ All traffic forwarding profiles are enabled. Network traffic is being captured and protected by Microsoft's Security Service Edge.`n`n%TestResult%"
        }
        elseif ($enabledProfiles.Count -eq 0) {
            # All profiles disabled - fail
            $passed = $false
            $testResultMarkdown = "❌ All traffic forwarding profiles are disabled. Global Secure Access is not protecting any network traffic.`n`n%TestResult%"
        }
        else {
            # Some enabled, some disabled - warning (fail)
            $passed = $false
            $testResultMarkdown = "⚠️ Some traffic forwarding profiles are disabled. Only partial network traffic is protected.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $mdInfo = ''

    if ($forwardingProfiles -and $forwardingProfiles.Count -gt 0) {
        $reportTitle = 'Traffic Forwarding Profiles'
        $tableRows = ""

        $mdInfo += "`n## $reportTitle`n`n"
        $mdInfo += "[Open Traffic Forwarding Profiles in Entra Portal](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/ForwardingProfile.ReactView)`n`n"

        # Summary of unprotected traffic types
        if ($disabledProfiles.Count -gt 0) {
            $unprotectedTypes = $disabledProfiles | ForEach-Object {
                switch ($_.trafficForwardingType) {
                    'm365' { 'Microsoft 365' }
                    'private' { 'Private Access' }
                    'internet' { 'Internet Access' }
                }
            }
            $mdInfo += "**⚠️ Unprotected Traffic Types:** $($unprotectedTypes -join ', ')`n`n"
        }

        $formatTemplate = @'
| Traffic Type | Name | State |
| :----------- | :--- | :---- |
{0}

'@

        # Build table rows for all profiles
        # Microsoft 365 Profile
        if ($m365Profile) {
            $statusIcon = if ($m365Profile.state -eq 'enabled') { '✅' } else { '❌' }
            $tableRows += "| Microsoft 365 | $(Get-SafeMarkdown $m365Profile.name) | $statusIcon $($m365Profile.state) |`n"
        }
        else {
            $tableRows += "| Microsoft 365 | Not found | ❌ Not configured |`n"
        }

        # Private Access Profile
        if ($privateProfile) {
            $statusIcon = if ($privateProfile.state -eq 'enabled') { '✅' } else { '❌' }
            $tableRows += "| Private Access | $(Get-SafeMarkdown $privateProfile.name) | $statusIcon $($privateProfile.state) |`n"
        }
        else {
            $tableRows += "| Private Access | Not found | ❌ Not configured |`n"
        }

        # Internet Access Profile
        if ($internetProfile) {
            $statusIcon = if ($internetProfile.state -eq 'enabled') { '✅' } else { '❌' }
            $tableRows += "| Internet Access | $(Get-SafeMarkdown $internetProfile.name) | $statusIcon $($internetProfile.state) |`n"
        }
        else {
            $tableRows += "| Internet Access | Not found | ❌ Not configured |`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25381'
        Title  = 'Network traffic is routed through Global Secure Access for security policy enforcement'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
