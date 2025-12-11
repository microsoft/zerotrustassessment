<#
.SYNOPSIS
    Checks that Private DNS is configured for internal name resolution in Entra Private Access (Quick Access)
.DESCRIPTION
    Verifies that a Quick Access application exists, Private DNS resolution is enabled on the Quick Access onPremisesPublishing settings, and that DNS suffix segments are configured for internal domains.

.NOTES
    Test ID: 25399
    Category: Private Access
    Required API: applications (beta), applications/{appId}/onPremisesPublishing, applications/{appId}/onPremisesPublishing/segmentsConfiguration
#>

function Test-Assessment-25399 {
    [ZtTest(
        Category = 'Private Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce','External'),
        TestId = '25399',
        Title = 'Private DNS is configured for internal name resolution',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Private DNS configuration for Quick Access (Entra Private Access)'
    Write-ZtProgress -Activity $activity -Status 'Querying Quick Access application'

    # Query 1: Find Quick Access application
    $quickAccessApp = Invoke-ZtGraphRequest -RelativeUri "applications" -Filter "tags/any(c:c eq 'NetworkAccessQuickAccessApplication')" -ApiVersion beta
    #endregion Data Collection

    #region Assessment Logic
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $appDnsResolutionEnabled = $false
    $appDnsSuffixes = @()
    $appHasValidSegments = $false
    $appDisplayName = $null
    $appId = $null

    # Check if Quick Access application exists
    if (-not $quickAccessApp -or $quickAccessApp.Count -eq 0) {
        $testResultMarkdown = "❌ No Quick Access application found with 'NetworkAccessQuickAccessApplication' tag."
        $passed = $false
    }
    else {
        # Get the Quick Access application
        $app = $quickAccessApp
        $appId = $app.id
        $appDisplayName = $app.displayName

        Write-ZtProgress -Activity $activity -Status "Getting onPremisesPublishing for application $($appDisplayName)"
        # Query 2: Get onPremisesPublishing settings
        $onPrem = Invoke-ZtGraphRequest -RelativeUri "applications/$($appId)/onPremisesPublishing" -ApiVersion beta

        # Check if DNS Resolution is enabled
        if ($null -ne $onPrem -and $onPrem.isDnsResolutionEnabled -eq $true) {
            $appDnsResolutionEnabled = $true
        }
        elseif ($null -eq $onPrem) {
            Write-PSFMessage "Failed to retrieve onPremisesPublishing settings for application $appId" -Level Warning
        }

        # Query 3: Get segmentsConfiguration and extract dns suffixes
        Write-ZtProgress -Activity $activity -Status "Getting segments configuration for DNS suffixes in $appDisplayName"
        $segments = Invoke-ZtGraphRequest -RelativeUri "applications/$($appId)/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments" -ApiVersion beta

        # Check if at least one segment has recommended settings (destinationType equals dnsSuffix and destinationHost has a value)
        if ($null -ne $segments -and $segments.Count -gt 0) {
            foreach ($seg in $segments) {
                if ($seg.destinationType -eq 'dnsSuffix' -and $seg.destinationHost) {
                    $appDnsSuffixes += $seg.destinationHost
                }
            }
            # Get unique suffixes
            $appDnsSuffixes = $appDnsSuffixes | Sort-Object -Unique

            # At least one valid segment found
            if ($appDnsSuffixes.Count -gt 0) {
                $appHasValidSegments = $true
            }
        }

        # Determine pass/fail per spec: ALL assessments must pass
        if ($appDnsResolutionEnabled -and $appHasValidSegments) {
            $passed = $true
            $testResultMarkdown = "✅ Private DNS is configured for internal name resolution in Entra Private Access.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ Private DNS is not configured or DNS suffixes are missing.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $mdInfo = ''

    if ($null -ne $appDisplayName) {
        # Determine status for each component
        $dnsResolutionStatus = if ($appDnsResolutionEnabled) { "🟢 True" } else { "🔴 False" }
        $dnsSuffixValue = if ($appHasValidSegments) { $([string]::Join(', ', $appDnsSuffixes)) } else { "None" }
        $appStatus = if ($appDnsResolutionEnabled -and $appHasValidSegments) { "✅ Pass" } else { "❌ Fail" }

        # Build results table
        $mdInfo += "| Quick Access application | DNS resolution enabled | DNS suffixes | Status |`n"
        $mdInfo += "|--------------------------|------------------------|--------------|--------|`n"
        $mdInfo += "| $appDisplayName | $dnsResolutionStatus | $dnsSuffixValue | $appStatus |`n"
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25399'
        Title  = 'Private DNS is configured for internal name resolution'
        Status = $passed
        Result = $testResultMarkdown
    }
    # Add test result details
    Add-ZtTestResultDetail @params

}
