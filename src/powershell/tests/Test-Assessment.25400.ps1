<#
.SYNOPSIS
    Validates that Port 53 is published or private DNS is configured for Private Access applications.

.DESCRIPTION
    This test checks whether DNS resolution for internal domains is properly configured in
    Global Secure Access Private Access. When Private Access is enabled but neither port 53
    (DNS) is published nor private DNS suffixes are configured, DNS queries for internal
    domain names cannot be routed through the tunnel. This causes:
    - FQDN-based application segments to fail
    - DNS leakage to local networks (potential information disclosure)
    - Possible bypass of Conditional Access and security policies

    The test verifies that at least one application segment either:
    - Uses destinationType 'dnsSuffix' (private DNS configured), OR
    - Publishes port 53 with UDP or TCP protocol to an internal DNS server

.NOTES
    Test ID: 25400
    Category: Private Access
    Required API: networkAccess/forwardingProfiles (beta), applications (beta), applications/{id}/onPremisesPublishing/segmentsConfiguration (beta)
#>

function Test-Assessment-25400 {
    [ZtTest(
        Category = 'Private Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('AAD_PREMIUM', 'Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'Low',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25400,
        Title = 'Is Port 53 published and private DNS is not used',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking DNS configuration for Private Access applications'
    Write-ZtProgress -Activity $activity -Status 'Querying Private Access forwarding profile'

    # Query 1: Check if Private Access forwarding profile is enabled
    $forwardingProfiles = @()
    $privateProfile = $null
    $errorMsgQ1 = $null

    try {
        $forwardingProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/forwardingProfiles' -Filter "trafficForwardingType eq 'private'" -ApiVersion beta
        if ($forwardingProfiles -and $forwardingProfiles.Count -gt 0) {
            # Prefer an enabled forwarding profile instead of assuming the first one is correct
            $enabledForwardingProfiles = $forwardingProfiles | Where-Object { $_.state -eq 'enabled' }
            if ($enabledForwardingProfiles -and $enabledForwardingProfiles.Count -gt 0) {
                $privateProfile = $enabledForwardingProfiles[0]
            }
        }
    }
    catch {
        $errorMsgQ1 = $_
        Write-PSFMessage "Failed to retrieve Private Access forwarding profile: $errorMsgQ1" -Tag Test -Level Warning
    }

    # Normalize enabled check
    $isPrivateAccessEnabled = ($privateProfile -and $privateProfile.state -eq 'enabled')

    # Query 2 & 3: Get Private Access applications and their segments (only if Private Access is enabled)
    $privateAccessApps = @()
    $allSegments = [System.Collections.Generic.List[object]]::new()
    $hasDnsSuffix = $false
    $hasPort53 = $false
    $errorMsgQ2 = $null
    $segmentQueryFailures = 0

    if (-not $errorMsgQ1 -and $isPrivateAccessEnabled) {
        Write-ZtProgress -Activity $activity -Status 'Querying Private Access applications'

        try {
            $privateAccessApps = Invoke-ZtGraphRequest `
                -RelativeUri 'applications' `
                -Select 'id,displayName,tags' `
                -Filter "(tags/any(c:c eq 'PrivateAccessNonWebApplication') or tags/any(c:c eq 'NetworkAccessQuickAccessApplication'))" `
                -ApiVersion beta
        }
        catch {
            $errorMsgQ2 = $_
            Write-PSFMessage "Failed to retrieve Private Access applications: $errorMsgQ2" -Tag Test -Level Warning
        }

        # Query 3: Get application segments for each application
        if (-not $errorMsgQ2 -and $privateAccessApps -and $privateAccessApps.Count -gt 0) {
            Write-ZtProgress -Activity $activity -Status 'Analyzing application segments for DNS configuration'

            $segmentQueryFailures = 0
            foreach ($app in $privateAccessApps) {
                try {
                    $segments = Invoke-ZtGraphRequest `
                        -RelativeUri "applications/$($app.id)/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments" `
                        -ApiVersion beta

                    if ($null -ne $segments -and $segments.Count -gt 0) {
                        foreach ($segment in $segments) {
                            # Determine DNS resolution method
                            $dnsResolution = 'None'

                            # Check for dnsSuffix destination type with a valid destinationHost
                            if ($segment.destinationType -eq 'dnsSuffix' -and -not [string]::IsNullOrWhiteSpace($segment.destinationHost)) {
                                $dnsResolution = '✅ dnsSuffix'
                                $hasDnsSuffix = $true
                            }
                            # Check for port 53 with UDP or TCP protocol
                            elseif ($segment.ports -and $segment.protocol) {
                                # Parse ports field (format: "startPort-endPort" or "port")
                                # Handle both array and string formats
                                if ($segment.ports -is [System.Array]) {
                                    $portsArray = $segment.ports
                                }
                                else {
                                    $portsArray = $segment.ports -split ','
                                }

                                foreach ($portRange in $portsArray) {
                                    $portRange = $portRange.Trim()
                                    if ($portRange -match '^(\d+)-(\d+)$') {
                                        # Port range
                                        $startPort = [int]$Matches[1]
                                        $endPort = [int]$Matches[2]
                                        if (53 -ge $startPort -and 53 -le $endPort -and $segment.protocol -match 'udp|tcp') {
                                            $dnsResolution = '✅ Port 53'
                                            $hasPort53 = $true
                                            break
                                        }
                                    }
                                    elseif ($portRange -match '^\d+$') {
                                        # Single port
                                        if ([int]$portRange -eq 53 -and $segment.protocol -match 'udp|tcp') {
                                            $dnsResolution = '✅ Port 53'
                                            $hasPort53 = $true
                                            break
                                        }
                                    }
                                }
                            }

                            # Store segment information
                            $allSegments.Add([PSCustomObject]@{
                                ApplicationName  = $app.displayName
                                DestinationHost  = $segment.destinationHost
                                DestinationType  = $segment.destinationType
                                Ports           = $segment.ports
                                Protocol        = $segment.protocol
                                DnsResolution   = $dnsResolution
                            })
                        }
                    }
                }
                catch {
                    $segmentQueryFailures++
                    Write-PSFMessage "Failed to retrieve segments for application $($app.id): $_" -Tag Test -Level Warning
                }
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null

    if ($errorMsgQ1) {
        # API call failed - unable to determine status
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to retrieve Private Access forwarding profile due to API error or insufficient permissions.`n`n%TestResult%"
    }
    elseif (-not $isPrivateAccessEnabled) {
        # Private Access is not enabled - test is not applicable
        Write-PSFMessage 'Private Access forwarding profile is not enabled in this tenant.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'Private Access is not enabled in this tenant. This check is not applicable until Private Access is configured and enabled.'
        return
    }
    elseif ($errorMsgQ2) {
        # Failed to retrieve applications
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to retrieve Private Access applications due to API error.`n`n%TestResult%"
    }
    elseif (-not $privateAccessApps -or $privateAccessApps.Count -eq 0) {
        # No Private Access applications configured
        $passed = $false
        $testResultMarkdown = "❌ No Private Access applications are configured. DNS resolution cannot be established without application segments.`n`n%TestResult%"
    }
    elseif ($segmentQueryFailures -gt 0 -and $allSegments.Count -eq 0) {
        # All segment queries failed - cannot evaluate reliably
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to retrieve application segments for Private Access applications ($segmentQueryFailures of $($privateAccessApps.Count) apps failed). This may indicate API errors or insufficient permissions to read segment configurations.`n`n%TestResult%"
    }
    elseif ($hasDnsSuffix -or $hasPort53) {
        # Pass: DNS resolution is configured
        $passed = $true
        $testResultMarkdown = "✅ DNS resolution for private access resources is configured through Global Secure Access using private DNS suffixes or published DNS endpoints.`n`n%TestResult%"
    }
    else {
        # Fail: No DNS configuration found
        $passed = $false
        $testResultMarkdown = "❌ No private DNS suffix or port 53 application segment is configured for Private Access applications.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($allSegments.Count -gt 0) {
        $reportTitle = 'Private Access Application Segments'
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/QuickAccessMenuBlade/~/GlobalSecureAccess'

        # Build segments table
        $segmentsTable = "| Application name | Segment destination host | Destination type | Ports | Protocol | DNS resolution |`n"
        $segmentsTable += "| :--------------- | :----------------------- | :--------------- | :---- | :------- | :------------- |`n"

        foreach ($segment in ($allSegments | Sort-Object ApplicationName, DestinationHost)) {
            $appName = Get-SafeMarkdown -Text $segment.ApplicationName
            $destHost = Get-SafeMarkdown -Text $segment.DestinationHost
            $destType = if ($segment.DestinationType) { $segment.DestinationType } else { 'N/A' }
            $ports = if ($segment.Ports) {
                if ($segment.Ports -is [System.Array]) {
                    $segment.Ports -join ', '
                } else {
                    $segment.Ports
                }
            } else {
                'N/A'
            }
            $protocol = if ($segment.Protocol) { $segment.Protocol } else { 'N/A' }
            $dnsResolution = $segment.DnsResolution

            $segmentsTable += "| $appName | $destHost | $destType | $ports | $protocol | $dnsResolution |`n"
        }

        $formatTemplate = @"

#### [$reportTitle]($portalLink)

$segmentsTable
"@

        $mdInfo = $formatTemplate
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25400'
        Title  = 'Is Port 53 published and private DNS is not used'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
