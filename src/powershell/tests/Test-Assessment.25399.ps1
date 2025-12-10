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

    # Q1: Find Quick Access application(s)
    $quickAccessApps = Invoke-ZtGraphRequest -RelativeUri "applications" -Filter "tags/any(c:c eq 'NetworkAccessQuickAccessApplication')" -ApiVersion beta

    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $appResults = @()
    $allAppsPass = $true
    #endregion Data Collection

    #region Assessment Logic
    # Assessment Logic 1: Check if Quick Access application exists
    if (-not $quickAccessApps -or $quickAccessApps.Count -eq 0) {
        $testResultMarkdown = "❌ No Quick Access application found with 'NetworkAccessQuickAccessApplication' tag."
        $passed = $false
    }
    else {
        # Process each Quick Access application
        foreach ($app in $quickAccessApps) {
            $appId = $app.id
            $appDisplayName = $app.displayName
            $appDnsResolutionEnabled = $false
            $appDnsSuffixes = @()
            $appAllSegmentsValid = $true

            Write-ZtProgress -Activity $activity -Status "Getting onPremisesPublishing for application $($appDisplayName)"
            # Q2: Get onPremisesPublishing settings
            $onPrem = Invoke-ZtGraphRequest -RelativeUri "applications/$($appId)/onPremisesPublishing" -ApiVersion beta

            # Assessment Logic 2: Check if DNS Resolution is enabled
            if ($null -ne $onPrem -and $onPrem.isDnsResolutionEnabled -eq $true) {
                $appDnsResolutionEnabled = $true
            }
            elseif ($null -eq $onPrem) {
                Write-PSFMessage "Failed to retrieve onPremisesPublishing settings for application $appId" -Level Warning
            }

            # Q3: Get segmentsConfiguration and extract dns suffixes
            Write-ZtProgress -Activity $activity -Status "Getting segments configuration for DNS suffixes in $appDisplayName"
            $segments = Invoke-ZtGraphRequest -RelativeUri "applications/$($appId)/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments" -ApiVersion 'beta'

            # Assessment Logic 3: Check if ALL segments have recommended settings (dnsSuffix type with destinationHost value)
            if ($null -ne $segments -and $segments.Count -gt 0) {
                foreach ($seg in $segments) {
                    if ($seg.destinationType -eq 'dnsSuffix' -and $seg.destinationHost) {
                        $appDnsSuffixes += $seg.destinationHost
                    }
                    else {
                        # At least one segment does not meet recommended settings
                        $appAllSegmentsValid = $false
                    }
                }
                # unique
                $appDnsSuffixes = $appDnsSuffixes | Sort-Object -Unique
            }
            else {
                # No segments found - treat as invalid
                $appAllSegmentsValid = $false
            }

            # Determine status for each component
            $dnsResolutionStatus = if ($appDnsResolutionEnabled) { "✅ Pass" } else { "❌ Fail" }
            $dnsSuffixStatus = if ($appDnsSuffixes.Count -gt 0 -and $appAllSegmentsValid) { "✅ Pass" } else { "❌ Fail" }
            $dnsSuffixValue = if ($appDnsSuffixes.Count -gt 0) { $([string]::Join(', ', $appDnsSuffixes)) } else { "None" }

            # Check if this app passes
            $appPassed = $appDnsResolutionEnabled -and $appDnsSuffixes.Count -gt 0 -and $appAllSegmentsValid

            # Store app result
            $appResults += [PSCustomObject]@{
                DisplayName = $appDisplayName
                Id = $appId
                DnsResolutionEnabled = $appDnsResolutionEnabled
                DnsSuffixes = $appDnsSuffixes
                AllSegmentsValid = $appAllSegmentsValid
                Passed = $appPassed
            }

            # Track overall pass status
            if (-not $appPassed) {
                $allAppsPass = $false
            }
        }

        # Build results table
        $testResultMarkdown += "| Quick Access application | DNS resolution enabled | DNS suffixes | All segments valid | Status |`n"
        $testResultMarkdown += "|--------------------------|------------------------|--------------|-------------------|--------|`n"
        foreach ($result in $appResults) {
            $dnsResolutionStatus = if ($result.DnsResolutionEnabled) { "✅ Pass" } else { "❌ Fail" }
            $dnsSuffixValue = if ($result.DnsSuffixes.Count -gt 0) { $([string]::Join(', ', $result.DnsSuffixes)) } else { "None" }
            $segmentsStatus = if ($result.AllSegmentsValid) { "✅ Pass" } else { "❌ Fail" }
            $appStatus = if ($result.Passed) { "✅ Pass" } else { "❌ Fail" }
            $testResultMarkdown += "| $($result.DisplayName) | $dnsResolutionStatus | $dnsSuffixValue | $segmentsStatus | $appStatus |`n"
        }
        $testResultMarkdown += "`n"

        # Determine pass/fail per spec: ALL apps must pass
        if ($allAppsPass -and $appResults.Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "✅ All Quick Access applications have Private DNS configured correctly.`n`n" + $testResultMarkdown
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ One or more Quick Access applications do not have Private DNS configured correctly.`n`n" + $testResultMarkdown
        }
    }
    #endregion Assessment Logic

    $params = @{
        TestId = '25399'
        Title  = 'Private DNS is configured for internal name resolution'
        Status = $passed
        Result = $testResultMarkdown
    }
    # Add test result details
    Add-ZtTestResultDetail @params

}
