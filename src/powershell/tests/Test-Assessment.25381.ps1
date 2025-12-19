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
        MinimumLicense = ('Entra_Suite', 'Entra_Premium_Private_Access', 'Entra_Premium_Internet_Access', 'P2'),
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
        # Categorize profiles by traffic type for reporting
        $m365Profile = $forwardingProfiles | Where-Object { $_.trafficForwardingType -eq 'm365' }
        $privateProfile = $forwardingProfiles | Where-Object { $_.trafficForwardingType -eq 'private' }
        $internetProfile = $forwardingProfiles | Where-Object { $_.trafficForwardingType -eq 'internet' }

        # Identify enabled and disabled profiles
        $enabledProfiles = $forwardingProfiles | Where-Object { $_.state -eq 'enabled' }
        $disabledProfiles = $forwardingProfiles | Where-Object { $_.state -ne 'enabled' }

        # Determine pass/fail/warning status

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

        # Define profile metadata for consistent reporting
        $profilesMetadata = @(
            @{ Type = 'm365'; Label = 'Microsoft 365'; Object = $m365Profile }
            @{ Type = 'private'; Label = 'Private Access'; Object = $privateProfile }
            @{ Type = 'internet'; Label = 'Internet Access'; Object = $internetProfile }
        )

        # Summary of unprotected traffic types (existing but disabled)
        $unprotectedLabels = $profilesMetadata | Where-Object { $_.Object -and $_.Object.state -ne 'enabled' } | Select-Object -ExpandProperty Label
        if ($unprotectedLabels) {
            $mdInfo += "**⚠️ Unprotected Traffic Types:** $($unprotectedLabels -join ', ')`n`n"
        }

        # Build table rows
        $tableRows = $profilesMetadata | ForEach-Object {
            $profile = $_.Object
            if ($profile) {
                $statusIcon = if ($profile.state -eq 'enabled') { '✅' } else { '❌' }
                "| $($_.Label) | $(Get-SafeMarkdown $profile.name) | $statusIcon $($profile.state) |"
            }
            else {
                "| $($_.Label) | Not found | ❌ Not configured |"
            }
        }

        $mdInfo += @'
| Traffic Type | Name | State |
| :----------- | :--- | :---- |
{0}

'@ -f ($tableRows -join "`n")
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
