<#
.SYNOPSIS
    Validates that Entra Private Access applications enforce least-privilege
    using granular network segments and Custom Security Attributes (CSA).

.DESCRIPTION
    This test evaluates Private Access applications to ensure segmentation
    follows least-privilege principles and supports attribute-based
    Conditional Access targeting.

.NOTES
    Test ID: 25395
    Category: Global Secure Access
    Required APIs: applications (beta), servicePrincipals (beta), conditionalAccess/policies (beta)
#>

function Test-Assessment-25395 {

    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'High',
        MinimumLicense = 'Entra_Premium_Private_Access',
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = 'Workforce',
        TestId = 25395,
        Title = 'Private Access application segments enforce least-privilege access',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    # Active Directory well-known ports
    $AD_WELL_KNOWN_PORTS = @('53','88','135','389','445','464','636','3268','3269')

    #region Helper Functions

    function Test-IsBroadCidr {
        <#
        .SYNOPSIS
            Checks if a CIDR range is overly permissive (/16 or broader).
        .DESCRIPTION
            CIDR ranges with prefix length <= 16 are treated as overly permissive.
            This includes /16 itself (65,536 IPs) and any broader ranges such as /15, /14, etc.
        .OUTPUTS
            System.Boolean
            True  - CIDR prefix length <= 16
            False - CIDR prefix length > 16 or invalid format
        #>
        param([string]$Cidr)
        if ($Cidr -match '/(\d+)$') { return ([int]$matches[1] -le 16) }
        return $false
    }

    function Test-IsBroadIpRange {
        <#
        .SYNOPSIS
            Checks if an IP range spans more than 256 addresses.
        .OUTPUTS
            System.Boolean - True if range exceeds 256 addresses, false otherwise.
        #>
        param([string]$Range)
        if ($Range -match '^([\d\.]+)-([\d\.]+)$') {
            $start = [System.Net.IPAddress]::Parse($matches[1]).GetAddressBytes()
            $end   = [System.Net.IPAddress]::Parse($matches[2]).GetAddressBytes()
            [array]::Reverse($start)
            [array]::Reverse($end)
            return (([BitConverter]::ToUInt32($end,0) - [BitConverter]::ToUInt32($start,0) + 1) -gt 256)
        }
        return $false
    }

    function Test-IsBroadPortRange {
        <#
        .SYNOPSIS
            Checks if a port range is overly broad (>10 ports or fully open).
        .OUTPUTS
            System.Boolean - True if port range is considered too broad, false otherwise.
        #>
        param([string]$Port)

        # Maximum number of ports allowed in a range before it is considered "broad".
        $BroadPortRangeThreshold = 10

        if ($Port -eq '1-65535') { return $true }
        if ($Port -match '^(\d+)-(\d+)$' -and (([int]$matches[2] - [int]$matches[1] + 1) -gt $BroadPortRangeThreshold)) { return $true }
        return $false
    }

    function Test-IsAdRpcException {
        <#
        .SYNOPSIS
            Checks if a port range is a valid Active Directory RPC ephemeral port exception.
        .OUTPUTS
            System.Boolean - True if port is a valid AD RPC exception, false otherwise.
        #>
        param([string]$AppName, [string]$Port)
        if ($AppName -match 'Active Directory|Domain Controller|AD DS') {
            if ($Port -in @('49152-65535','1025-5000')) { return $true }
        }
        return $false
    }

    function Test-IsAdWellKnownPort {
        <#
        .SYNOPSIS
            Checks if a port is a well-known Active Directory port.
        .OUTPUTS
            System.Boolean - True if port is a valid AD well-known port, false otherwise.
        #>
        param([string]$Port)
        if ($Port -match '^(\d+)-(\d+)$') {
            return ($matches[1] -eq $matches[2] -and $AD_WELL_KNOWN_PORTS -contains $matches[1])
        }
        return ($AD_WELL_KNOWN_PORTS -contains $Port)
    }

    function Test-ContainsAdWellKnownPort {
        <#
        .SYNOPSIS
            Checks if a port range contains any well-known Active Directory ports.
        .DESCRIPTION
            Evaluates whether a port range (e.g., '50-500') includes any of the
            well-known AD ports (53, 88, 135, 389, 445, 464, 636, 3268, 3269).
        .OUTPUTS
            System.Boolean - True if range contains AD ports, false otherwise.
        #>
        param([string]$Port)
        if ($Port -match '^(\d+)-(\d+)$') {
            $start = [int]$matches[1]
            $end = [int]$matches[2]
            foreach ($adPort in $AD_WELL_KNOWN_PORTS) {
                if ([int]$adPort -ge $start -and [int]$adPort -le $end) {
                    return $true
                }
            }
        }
        return $false
    }

    #endregion Helper Functions

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating Private Access application segmentation'
    Write-ZtProgress -Activity $activity -Status 'Querying applications'

    # Query Q1: List all Private Access enterprise applications
    $apps = Invoke-ZtGraphRequest -RelativeUri "applications?`$filter=(tags/any(t:t eq 'PrivateAccessNonWebApplication') or tags/any(t:t eq 'NetworkAccessQuickAccessApplication'))&`$select=id,displayName,appId,tags" -ApiVersion beta

    # Query Q2: Retrieve service principals with Custom Security Attributes
    $servicePrincipals = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals?`$filter=(tags/any(t:t eq 'PrivateAccessNonWebApplication') or tags/any(t:t eq 'NetworkAccessQuickAccessApplication'))&`$select=id,appId,displayName,customSecurityAttributes&`$count=true" -ApiVersion beta -ConsistencyLevel eventual

    # Query Q3: Retrieve enabled Conditional Access policies
    $caPolicies     = $null
    $filterPolicies = @()

    if ($null -ne $apps -and $apps.Count -gt 0) {

        Write-ZtProgress -Activity $activity -Status 'Checking Conditional Access policies'

        $allCAPolicies = Get-ZtConditionalAccessPolicy
        $caPolicies    = $allCAPolicies | Where-Object { $_.state -eq 'enabled' }

        if ($caPolicies) {
            $filterPolicies = $caPolicies | Where-Object {
                $_.conditions.applications.applicationFilter
            }
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Initialize evaluation containers
    $passed             = $false
    $customStatus       = $null
    $testResultMarkdown = ''
    $broadAccessApps    = @()
    $appsWithoutCSA     = @()
    $segmentFindings    = @()
    $appResults         = @()
    # Step 1: Check if any per-app Private Access applications exist
    if ($null -ne $apps -and $apps.Count -gt 0) {

        Write-ZtProgress -Activity $activity -Status 'Evaluating application segments'

        foreach ($app in $apps) {

            # Query Q4: Retrieve application segments for the current app
            $segments = Invoke-ZtGraphRequest -RelativeUri "applications/$($app.id)/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments" -ApiVersion beta

            $hasBroadSegment = $false
            $hasWildcardDns  = $false
            $hasBroadPorts   = $false
            $segmentSummary  = @()

            if (-not $segments -or $segments.Count -eq 0) {
                $segmentSummary = @('No segments configured')
            }

            foreach ($segment in $segments) {

                # Step 2: Evaluate segment destination granularity
                $issues = @()

                $segmentSummary += "$($segment.destinationHost):$($segment.ports -join ',')"

                switch ($segment.destinationType) {
                    'dnsSuffix' {
                        $hasWildcardDns = $true
                        $issues += 'Wildcard DNS'
                    }
                    'ipRangeCidr' {
                        if (Test-IsBroadCidr $segment.destinationHost) {
                            $hasBroadSegment = $true
                            $issues += 'Broad CIDR'
                        }
                    }
                    'ipRange' {
                        if (Test-IsBroadIpRange $segment.destinationHost) {
                            $hasBroadSegment = $true
                            $issues += 'Broad IP range'
                        }
                    }
                }

                # Step 3: Evaluate port breadth with AD RPC exceptions
                foreach ($port in $segment.ports) {
                    if (Test-IsBroadPortRange $port) {
                        # Check if this is a valid AD RPC exception or exact AD well-known port
                        if (-not (Test-IsAdRpcException -AppName $app.displayName -Port $port) `
                            -and -not (Test-IsAdWellKnownPort $port)) {
                            $hasBroadPorts = $true
                            $issues += 'Broad port range'

                            # Additionally flag if the broad range contains AD well-known ports
                            if (Test-ContainsAdWellKnownPort $port) {
                                $issues += 'Broad range overlaps AD ports'
                            }
                        }
                    }
                }

                # Step 4: Flag dual-protocol usage combined with broad scope
                if ($segment.protocol -eq 'tcp,udp' -and $issues.Count -gt 0) {
                    $hasBroadPorts = $true
                    $issues += 'Dual protocol with broad scope'
                }

                if ($issues.Count -gt 0) {
                    $segmentFindings += [PSCustomObject]@{
                        AppName     = $app.displayName
                        AppId       = $app.appId
                        SegmentId   = $segment.id
                        Issue       = ($issues -join ', ')
                        Destination = $segment.destinationHost
                        Ports       = ($segment.ports -join ', ')
                    }
                }
            }

            # Step 5: Identify apps with overly broad access
            if ($hasBroadSegment -or $hasWildcardDns -or $hasBroadPorts) {
                $broadAccessApps += $app
            }

            # Step 6: Check CSA presence for the app
            $sp = $servicePrincipals | Where-Object { $_.appId -eq $app.appId }
            if (-not $sp.customSecurityAttributes) {
                $appsWithoutCSA += $app
            }

            # Determine per-app status including Manual Review when filterPolicies exist
            $appStatus = if (-not $sp.customSecurityAttributes) {
                'Fail – Missing CSA'
            } elseif ($hasBroadSegment -or $hasWildcardDns -or $hasBroadPorts) {
                'Fail – Broad segment'
            } elseif ($filterPolicies.Count -gt 0) {
                'Manual Review'
            } else {
                'Pass'
            }

            $appResults += [PSCustomObject]@{
                AppName      = $app.displayName
                AppObjectId  = $app.id
                AppId        = $app.appId
                SegmentType  = if ($segments) { ($segments.destinationType | Select-Object -Unique) -join ', ' } else { 'None' }
                SegmentScope = ($segmentSummary -join ' | ')
                HasCSA       = [bool]$sp.customSecurityAttributes
                Status       = $appStatus
            }


        }
    }

    # Step 7: Determine overall test result (Pass / Fail / Investigate)

    if (-not $apps -or $apps.Count -eq 0) {

        $customStatus = 'Investigate'
        $testResultMarkdown =
            "⚠️ No per-app Private Access applications configured. Please review the documentation on how to configure Private Access applications with granular network segments.`n`n%TestResult%"

    }
    elseif ($broadAccessApps.Count -eq 0 -and $appsWithoutCSA.Count -eq 0) {

        if ($filterPolicies.Count -gt 0) {

            # Pass conditions met but filterPolicies exist - requires manual review
            $customStatus = 'Investigate'
            $testResultMarkdown =
                "⚠️ Private Access applications exist with appropriate segmentation and CSAs assigned. CA policies use applicationFilter targeting. Manual review required to verify CA policy coverage for these apps.`n`n%TestResult%"

        }
        else {

            $passed = $true
            $testResultMarkdown =
                "✅ All Private Access applications are configured with granular network segments and are protected by Conditional Access policies using Custom Security Attributes, enforcing least-privilege access.`n`n%TestResult%"

        }

    }
    else {

        $passed = $false
        $testResultMarkdown =
            "❌ One or more Private Access applications have overly broad network segments or lack Custom Security Attribute-based Conditional Access policies, potentially allowing excessive network access.`n`n%TestResult%"

    }

    #endregion Assessment Logic

    #region Report Generation

    $mdInfo  = "`n## Summary`n`n"
    $mdInfo += "| Metric | Value |`n|---|---|`n"
    $mdInfo += "| Total Private Access apps | $($apps.Count) |`n"
    $mdInfo += "| Apps with broad segments | $($broadAccessApps.Count) |`n"
    $mdInfo += "| Apps with CSA assigned | $($apps.Count - $appsWithoutCSA.Count) |`n"
    $mdInfo += "| Apps without CSA | $($appsWithoutCSA.Count) |`n"
    $mdInfo += "| CA policies using applicationFilter | $($filterPolicies.Count) |`n`n"

    if ($appResults.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
## [Application details](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/EnterpriseApplicationListBladeV3/fromNav/globalSecureAccess/applicationType/GlobalSecureAccessApplication)

| App name | Segment type | Segment scope | Has CSAs | Status |
|---|---|---|---|---|
{0}

'@
        foreach ($r in $appResults) {
            $appLink = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/overview/appId/$($r.AppId)"
            $linkedAppName = "[{0}]({1})" -f (Get-SafeMarkdown $r.AppName), $appLink
            $hasCSAText = if ($r.HasCSA) {'Yes'} else {'No'}
            $tableRows += "| $linkedAppName | $($r.SegmentType) | $($r.SegmentScope) | $hasCSAText | $($r.Status) |`n"
        }
        $mdInfo += $formatTemplate -f $tableRows
    }


    if ($segmentFindings.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
## Segment findings

| App name | Issue | Destination | Ports | Recommendation |
|---|---|---|---|---|
{0}

'@
        foreach ($f in $segmentFindings) {
            $appLink = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/overview/appId/$($f.AppId)"
            $linkedAppName = "[{0}]({1})" -f (Get-SafeMarkdown $f.AppName), $appLink
            $tableRows += "| $linkedAppName | $($f.Issue) | $($f.Destination) | $($f.Ports) | Narrow destination and ports |`n"
        }
        $mdInfo += $formatTemplate -f $tableRows
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation
    $params = @{
        TestId = '25395'
        Title  = 'Private Access application segments enforce least-privilege access'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if status is 'Investigate'
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
