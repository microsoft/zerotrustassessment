<#
.SYNOPSIS
    Domain controller RDP access is protected by phishing-resistant authentication through Global Secure Access
.DESCRIPTION
    Verifies that Private Access applications providing RDP access to domain controllers require phishing-resistant
    MFA (FIDO2, Windows Hello for Business, or certificate-based authentication) via Conditional Access policies.
#>

function Test-Assessment-25398 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('AAD_PREMIUM', 'Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 25398,
        Title = 'Domain controller RDP access is protected by phishing-resistant authentication through Global Secure Access',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start Global Secure Access DC RDP protection evaluation' -Tag Test -Level VeryVerbose

    $activity = 'Checking domain controller RDP access protection'
    Write-ZtProgress -Activity $activity -Status 'Checking Microsoft Graph connection'

    #region Data Collection

    # Q1: Get all Private Access apps
    Write-ZtProgress -Activity $activity -Status 'Retrieving Private Access applications'

    $privateAccessApps = Invoke-ZtGraphRequest -RelativeUri 'applications' -QueryParameters @{
        '$filter' = "tags/any(t:t eq 'PrivateAccessNonWebApplication')"
        '$count' = 'true'
        '$select' = 'id,appId,displayName,tags'
    } -ConsistencyLevel 'eventual'

    if (-not $privateAccessApps) {
        Write-PSFMessage "No Private Access applications found." -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported -Result "No Private Access applications configured in this tenant."
        return
    }

    Write-PSFMessage "Found $($privateAccessApps.Count) Private Access application(s)" -Tag Test -Level VeryVerbose

    # Initialize tracking collections
    $dcHosts = @{}  # Key: destinationHost, Value: @{SourceApp, Ports, RdpAppFound, RdpAppName}
    $allAppSegments = @{}  # Key: appId, Value: @{App, Segments}

    # Q2A: Retrieve segments for each app and identify DC hosts
    # DC hosts are identified by having BOTH port 88 (Kerberos) AND port 389 (LDAP) explicitly configured
    Write-ZtProgress -Activity $activity -Status 'Analyzing application segments for DC indicators'

    foreach ($app in $privateAccessApps) {
        Write-ZtProgress -Activity $activity -Status "Checking segments for $($app.displayName)"

        try {
            $segmentsUri = "applications/$($app.id)/onPremisesPublishing/segmentsConfiguration/microsoft.graph.ipSegmentConfiguration/applicationSegments"
            $segments = Invoke-ZtGraphRequest -RelativeUri $segmentsUri -ApiVersion beta

            if ($segments) {
                $allAppSegments[$app.appId] = @{
                    App = $app
                    Segments = $segments
                }

                # Check for DC indicators: ports 88 (Kerberos) AND 389 (LDAP) as discrete values
                # Note: -contains operator matches exact strings, so '88' won't match ranges like '50-100'
                $has88 = $false
                $has389 = $false
                $hostsWith88 = @()
                $hostsWith389 = @()

                foreach ($segment in $segments) {
                    $ports = $segment.port

                    # Check if port 88 is explicitly configured (must be discrete, not in a range)
                    if ($ports -contains '88') {
                        $has88 = $true
                        $hostsWith88 += $segment.destinationHost
                    }

                    # Check if port 389 is explicitly configured (must be discrete, not in a range)
                    if ($ports -contains '389') {
                        $has389 = $true
                        $hostsWith389 += $segment.destinationHost
                    }
                }

                # If both port 88 AND port 389 are found, mark hosts with both as likely domain controllers
                if ($has88 -and $has389) {
                    # Find hosts that have both ports configured
                    $commonHosts = $hostsWith88 | Where-Object { $hostsWith389 -contains $_ }
                    foreach ($dcHost in $commonHosts) {
                        if (-not $dcHosts.ContainsKey($dcHost)) {
                            $dcHosts[$dcHost] = @{
                                SourceApp = $app.displayName
                                Ports = '88, 389'
                                RdpAppFound = $false
                                RdpAppName = 'None'
                            }
                        }
                    }
                }
            }
        }
        catch {
            Write-PSFMessage "Unable to retrieve segments for $($app.displayName): $_" -Tag Test -Level Warning
        }
    }

    Write-PSFMessage "Identified $($dcHosts.Count) likely DC host(s)" -Tag Test -Level VeryVerbose

    # Q2A/Q2B: Identify RDP applications (port 3389 over TCP)
    $rdpApps = @()
    $appType = ''

    if ($dcHosts.Count -gt 0) {
        # Q2A: DC hosts identified - search for RDP apps targeting those specific DC hosts
        Write-ZtProgress -Activity $activity -Status 'Searching for RDP apps targeting DC hosts'

        foreach ($appId in $allAppSegments.Keys) {
            $appData = $allAppSegments[$appId]

            foreach ($segment in $appData.Segments) {
                $destinationHost = $segment.destinationHost
                $ports = $segment.port
                $protocol = $segment.protocol

                # Check if this segment targets a DC host AND has RDP access (port 3389 over TCP)
                if ($dcHosts.ContainsKey($destinationHost) -and $protocol -eq 'tcp') {
                    $hasRdp = $false

                    # Check for port 3389 (discrete value or within a port range)
                    foreach ($portValue in $ports) {
                        # Check discrete port 3389
                        if ($portValue -eq '3389') {
                            $hasRdp = $true
                            break
                        }
                        # Check if 3389 is within a port range (e.g., '1-5000' or '3000-4000')
                        if ($portValue -match '^(\d+)-(\d+)$') {
                            $start = [int]$Matches[1]
                            $end = [int]$Matches[2]
                            if (3389 -ge $start -and 3389 -le $end) {
                                $hasRdp = $true
                                break
                            }
                        }
                    }

                    if ($hasRdp) {
                        $rdpApps += [PSCustomObject]@{
                            AppId = $appData.App.appId
                            AppName = $appData.App.displayName
                            DestinationHost = $destinationHost
                            AppType = 'DC RDP App'
                        }

                        # Update DC host info
                        $dcHosts[$destinationHost].RdpAppFound = $true
                        $dcHosts[$destinationHost].RdpAppName = $appData.App.displayName
                    }
                }
            }
        }

        $appType = 'DC RDP'
    }
    else {
        # Q2B: Fallback - no DC hosts identified, search for any general RDP apps
        # These require manual investigation to determine if they target domain controllers
        Write-ZtProgress -Activity $activity -Status 'No DC hosts found, searching for general RDP apps'

        foreach ($appId in $allAppSegments.Keys) {
            $appData = $allAppSegments[$appId]

            foreach ($segment in $appData.Segments) {
                $ports = $segment.port
                $protocol = $segment.protocol

                if ($protocol -eq 'tcp') {
                    $hasRdp = $false

                    # Check for port 3389 (discrete value or within a port range)
                    foreach ($portValue in $ports) {
                        # Check discrete port 3389
                        if ($portValue -eq '3389') {
                            $hasRdp = $true
                            break
                        }
                        # Check if 3389 is within a port range
                        if ($portValue -match '^(\d+)-(\d+)$') {
                            $start = [int]$Matches[1]
                            $end = [int]$Matches[2]
                            if (3389 -ge $start -and 3389 -le $end) {
                                $hasRdp = $true
                                break
                            }
                        }
                    }

                    if ($hasRdp) {
                        $rdpApps += [PSCustomObject]@{
                            AppId = $appData.App.appId
                            AppName = $appData.App.displayName
                            DestinationHost = $segment.destinationHost
                            AppType = 'General RDP App'
                        }
                    }
                }
            }
        }

        $appType = 'General RDP'
    }

    # Remove duplicates based on AppId and DestinationHost combination
    # An app may have multiple segments targeting the same host; we only need one entry per app-host pair
    $rdpApps = $rdpApps | Group-Object -Property AppId, DestinationHost | ForEach-Object { $_.Group | Select-Object -First 1 }

    Write-PSFMessage "Found $($rdpApps.Count) RDP application(s)" -Tag Test -Level VeryVerbose

    if ($rdpApps.Count -eq 0) {
        Write-PSFMessage "No RDP applications found" -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported -Result "No Private Access applications with RDP access (port 3389) were found."
        return
    }

    # Q3: Get phishing-resistant MFA authentication strength
    Write-ZtProgress -Activity $activity -Status 'Retrieving phishing-resistant MFA authentication strength'

    $authStrength = Invoke-ZtGraphRequest -RelativeUri 'policies/authenticationStrengthPolicies' -QueryParameters @{
        '$filter' = "policyType eq 'builtIn' and displayName eq 'Phishing-resistant MFA'"
    } -ApiVersion 'beta'

    if (-not $authStrength -or $authStrength.Count -eq 0) {
        Write-PSFMessage "Phishing-resistant MFA authentication strength not found" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported -Result "Phishing-resistant MFA authentication strength policy not found."
        return
    }

    $authStrengthId = $authStrength[0].id

    # Q4: Get CA policies using this authentication strength
    Write-ZtProgress -Activity $activity -Status 'Checking Conditional Access policies'

    $caPolicies = Invoke-ZtGraphRequest -RelativeUri "policies/authenticationStrengthPolicies/$authStrengthId/usage" -ApiVersion 'beta'

    # Filter for enabled policies only
    $enabledPolicies = $caPolicies | Where-Object { $_.state -eq 'enabled' }

    Write-PSFMessage "Found $($enabledPolicies.Count) enabled CA policy/policies with phishing-resistant MFA" -Tag Test -Level VeryVerbose

    #endregion Data Collection

    #region Assessment Logic

    # Evaluate each RDP app for Conditional Access policy protection with phishing-resistant MFA
    $results = @()

    foreach ($rdpApp in $rdpApps) {
        # Initialize status variables
        $protected = $false
        $protectedBy = 'None'
        $authStrengthName = 'N/A'
        $status = 'Fail'  # Default to Fail for DC RDP apps
        $targetingMethod = 'None'

        # Check if any enabled CA policy with phishing-resistant MFA targets this app
        foreach ($policy in $enabledPolicies) {
            $includeApps = $policy.conditions.applications.includeApplications
            $appFilter = $policy.conditions.applications.applicationFilter

            # Check if policy targets this app directly or via 'All'
            if ($includeApps -contains $rdpApp.AppId -or $includeApps -contains 'All') {
                $protected = $true
                $protectedBy = $policy.displayName
                $authStrengthName = 'Phishing-resistant MFA'
                $status = 'Pass'
                $targetingMethod = if ($includeApps -contains 'All') { 'All Apps' } else { 'Direct' }
                break
            }
            # Check if policy uses custom security attributes (requires manual verification)
            elseif ($appFilter) {
                $protected = $true
                $protectedBy = $policy.displayName
                $authStrengthName = 'Phishing-resistant MFA'
                $status = 'Investigate'  # Cannot verify attribute assignment without CustomSecAttributeAssignment.Read.All
                $targetingMethod = 'Filter (Custom Security Attributes)'
                break
            }
        }

        # Special handling for General RDP apps: mark as Investigate if not protected
        # (Cannot confirm if these target DCs without additional context)
        if (-not $protected -and $rdpApp.AppType -eq 'General RDP App') {
            $status = 'Investigate'
        }

        $results += [PSCustomObject]@{
            AppName = $rdpApp.AppName
            AppId = $rdpApp.AppId
            DestinationHost = $rdpApp.DestinationHost
            AppType = $rdpApp.AppType
            ProtectedBy = $protectedBy
            AuthStrength = $authStrengthName
            Status = $status
            TargetingMethod = $targetingMethod
            PolicyId = if ($protected) { ($enabledPolicies | Where-Object { $_.displayName -eq $protectedBy }).id } else { $null }
        }
    }

    # Determine overall test status based on individual app results
    $passed = $false
    $testResultMarkdown = ''

    if ($appType -eq 'DC RDP') {
        # DC RDP apps found - evaluate protection status
        $passedApps = $results | Where-Object { $_.Status -eq 'Pass' }
        $investigateApps = $results | Where-Object { $_.Status -eq 'Investigate' }
        $failedApps = $results | Where-Object { $_.Status -eq 'Fail' }

        # Pass: All DC RDP apps are protected by CA policies with phishing-resistant MFA
        if ($passedApps.Count -gt 0 -and $failedApps.Count -eq 0 -and $investigateApps.Count -eq 0) {
            $passed = $true
            $testResultMarkdown = "✅ RDP access (port 3389) to identified domain controller hosts is protected by a Conditional Access policy requiring phishing-resistant authentication (FIDO2, Windows Hello for Business, or Certificate-based MFA).`n`n%TestResult%"
        }
        # Investigate: CA policy targets apps via custom security attributes (cannot verify without additional permissions)
        elseif ($investigateApps.Count -gt 0) {
            $testResultMarkdown = "⚠️ A Conditional Access policy requiring phishing-resistant authentication targets applications via custom security attributes - manual verification required to confirm the domain controller RDP application has the required attribute assigned (Global Admin cannot read custom security attributes by default).`n`n%TestResult%"
        }
        # Fail: DC RDP apps exist but are not protected by CA policies with phishing-resistant MFA
        else {
            $testResultMarkdown = "❌ RDP access (port 3389) to identified domain controller hosts is not protected by a Conditional Access policy requiring phishing-resistant authentication.`n`n%TestResult%"
        }
    }
    else {
        # Investigate: General RDP apps found but no DC hosts identified (manual verification needed)
        $testResultMarkdown = "⚠️ No domain controller hosts identified, but RDP-enabled Private Access applications (port 3389) were found - manual verification recommended to confirm these are not domain controllers and to ensure appropriate protection.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $mdInfo = ''

    # Table 1: Identified DC Hosts (if any)
    if ($dcHosts.Count -gt 0) {
        $mdInfo += "`n## [Identified domain controller hosts](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/PrivateApplications.ReactView)`n`n"
        $mdInfo += "| DC host (FQDN/IP) | Source application | Ports configured | RDP app found | RDP app name |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($dcHost in $dcHosts.Keys) {
            $info = $dcHosts[$dcHost]
            $rdpFound = if ($info.RdpAppFound) { 'Yes' } else { 'No' }
            $hostSafe = Get-SafeMarkdown -Text $dcHost
            $sourceSafe = Get-SafeMarkdown -Text $info.SourceApp
            $rdpAppSafe = Get-SafeMarkdown -Text $info.RdpAppName

            $mdInfo += "| $hostSafe | $sourceSafe | $($info.Ports) | $rdpFound | $rdpAppSafe |`n"
        }
    }

    # Table 2: RDP Applications
    $mdInfo += "`n## [Private Access RDP applications requiring protection](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/PrivateApplications.ReactView)`n`n"
    $mdInfo += "| Application name | App ID | Target host | App type | Protected by CA policy | Authentication strength | Status |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

    foreach ($result in $results) {
        $appNameSafe = Get-SafeMarkdown -Text $result.AppName
        $appIdSafe = Get-SafeMarkdown -Text $result.AppId
        $hostSafe = Get-SafeMarkdown -Text $result.DestinationHost
        $appTypeSafe = Get-SafeMarkdown -Text $result.AppType

        $policyLink = if ($result.ProtectedBy -ne 'None' -and $result.PolicyId) {
            "[$($result.ProtectedBy)](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($result.PolicyId))"
        } else {
            $result.ProtectedBy
        }

        $statusIcon = switch ($result.Status) {
            'Pass' { '✅' }
            'Fail' { '❌' }
            'Investigate' { '⚠️' }
            default { '' }
        }

        $mdInfo += "| $appNameSafe | $appIdSafe | $hostSafe | $appTypeSafe | $policyLink | $($result.AuthStrength) | $statusIcon $($result.Status) |`n"
    }

    # Table 3: CA Policies
    if ($enabledPolicies.Count -gt 0) {
        $mdInfo += "`n## [Conditional Access policies requiring phishing-resistant MFA](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies)`n`n"
        $mdInfo += "| Policy name | State | Target applications | Targeting method |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $enabledPolicies) {
            $policyNameLink = "[$($policy.displayName)](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id))"

            $includeApps = $policy.conditions.applications.includeApplications
            $appFilter = $policy.conditions.applications.applicationFilter

            $targetApps = ''
            $targetingMethod = ''

            if ($includeApps -contains 'All') {
                $targetApps = 'All applications'
                $targetingMethod = 'All Apps'
            }
            elseif ($appFilter) {
                $targetApps = 'Via custom security attributes'
                $targetingMethod = 'Filter'
            }
            else {
                $appNames = @()
                foreach ($appId in $includeApps) {
                    $matchedApp = $results | Where-Object { $_.AppId -eq $appId } | Select-Object -First 1
                    if ($matchedApp) {
                        $appNames += $matchedApp.AppName
                    }
                }
                $targetApps = if ($appNames.Count -gt 0) { ($appNames | Sort-Object -Unique) -join ', ' } else { "$($includeApps.Count) application(s)" }
                $targetingMethod = 'Direct'
            }

            $targetAppsSafe = Get-SafeMarkdown -Text $targetApps

            $mdInfo += "| $policyNameLink | $($policy.state) | $targetAppsSafe | $targetingMethod |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '25398'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
