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
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start Global Secure Access DC RDP protection evaluation' -Tag Test -Level VeryVerbose

    $activity = 'Checking domain controller RDP access protection'
    Write-ZtProgress -Activity $activity -Status 'Checking Microsoft Graph connection'

    #region Helper Functions

    # Check if a specific port is included in a list of port values (discrete or range)
    function Test-PortIncluded {
        param([string[]]$Ports, [int]$TargetPort)
        foreach ($portValue in $Ports) {
            if ($portValue -eq $TargetPort.ToString()) { return $true }
            if ($portValue -match '^(\d+)-(\d+)$' -and $TargetPort -ge [int]$Matches[1] -and $TargetPort -le [int]$Matches[2]) { return $true }
        }
        return $false
    }

    #endregion Helper Functions

    #region Data Collection

    # Q1: Get all Private Access apps
    Write-ZtProgress -Activity $activity -Status 'Retrieving Private Access applications'

    $privateAccessApps = $null

    if ($Database) {
        Write-PSFMessage 'Querying database for Private Access applications' -Tag Test -Level VeryVerbose
        try {
            $sql = @"
SELECT id, appId, displayName
FROM Application
WHERE list_contains(tags, 'PrivateAccessNonWebApplication')
"@
            $privateAccessApps = @(Invoke-DatabaseQuery -Database $Database -Sql $sql -AsCustomObject)
            Write-PSFMessage "Found $($privateAccessApps.Count) Private Access application(s) from database" -Tag Test -Level VeryVerbose
        }
        catch {
            Write-PSFMessage "Database query failed: $_" -Tag Test -Level Warning
            $privateAccessApps = $null
        }
    }


    if (-not $privateAccessApps) {
        Write-PSFMessage 'No Private Access applications found' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Private Access applications configured in this tenant.'
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
                    $ports = $segment.ports

                    # Check if port 88 is explicitly configured (must be discrete, not in a range)
                    # API returns ports as ranges even for single ports (e.g. '88-88'), so check both forms
                    if ($ports -contains '88' -or $ports -contains '88-88') {
                        $has88 = $true
                        $hostsWith88 += $segment.destinationHost
                    }

                    # Check if port 389 is explicitly configured (must be discrete, not in a range)
                    if ($ports -contains '389' -or $ports -contains '389-389') {
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
                $ports = $segment.ports
                $protocol = $segment.protocol

                # Check if this segment targets a DC host AND has RDP access (port 3389 over TCP)
                if ($dcHosts.ContainsKey($destinationHost) -and $protocol -match 'tcp' -and (Test-PortIncluded -Ports $ports -TargetPort 3389)) {
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

        $appType = 'DC RDP'
    }
    else {
        # Q2B: Fallback - no DC hosts identified, search for any general RDP apps
        # These require manual investigation to determine if they target domain controllers
        Write-ZtProgress -Activity $activity -Status 'No DC hosts found, searching for general RDP apps'

        foreach ($appId in $allAppSegments.Keys) {
            $appData = $allAppSegments[$appId]

            foreach ($segment in $appData.Segments) {
                $ports = $segment.ports
                $protocol = $segment.protocol

                if ($protocol -match 'tcp' -and (Test-PortIncluded -Ports $ports -TargetPort 3389)) {
                    $rdpApps += [PSCustomObject]@{
                        AppId = $appData.App.appId
                        AppName = $appData.App.displayName
                        DestinationHost = $segment.destinationHost
                        AppType = 'General RDP App'
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
        Write-PSFMessage 'No RDP applications found' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Private Access applications with RDP access (port 3389) were found.'
        return
    }

    # Q3: Get phishing-resistant MFA authentication strength
    Write-ZtProgress -Activity $activity -Status 'Retrieving phishing-resistant MFA authentication strength'

    $authStrength = Invoke-ZtGraphRequest -RelativeUri 'policies/authenticationStrengthPolicies' -QueryParameters @{
        '$filter' = "policyType eq 'builtIn' and displayName eq 'Phishing-resistant MFA'"
    } -ApiVersion beta

    if (-not $authStrength -or $authStrength.Count -eq 0) {
        Write-PSFMessage 'Phishing-resistant MFA authentication strength not found' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'Phishing-resistant MFA authentication strength policy not found.'
        return
    }

    $authStrengthId = $authStrength[0].id

    # Q4: Get CA policies using this authentication strength
    Write-ZtProgress -Activity $activity -Status 'Checking Conditional Access policies'

    $caPolicies = Invoke-ZtGraphRequest -RelativeUri "policies/authenticationStrengthPolicies/$authStrengthId/usage" -ApiVersion beta

    # The /usage response is { mfa: [...], none: [...] } with minimal policy stubs (no conditions/grantControls).
    # Collect IDs from both arrays, then fetch each full policy to get conditions and grantControls.
    $usagePolicyIds = @()
    if ($caPolicies.mfa)  { $usagePolicyIds += $caPolicies.mfa  | Select-Object -ExpandProperty id }
    if ($caPolicies.none) { $usagePolicyIds += $caPolicies.none | Select-Object -ExpandProperty id }
    $usagePolicyIds = $usagePolicyIds | Select-Object -Unique

    $enabledPolicies = @()
    foreach ($policyId in $usagePolicyIds) {
        try {
            $fullPolicy = Invoke-ZtGraphRequest -RelativeUri "policies/conditionalAccessPolicies/$policyId" -ApiVersion beta
            if ($fullPolicy -and $fullPolicy.state -eq 'enabled') {
                $enabledPolicies += $fullPolicy
            }
        }
        catch {
            Write-PSFMessage "Unable to fetch full details for CA policy $policyId : $_" -Tag Test -Level Warning
        }
    }

    Write-PSFMessage "Found $($enabledPolicies.Count) enabled CA policy/policies with phishing-resistant MFA" -Tag Test -Level VeryVerbose

    #endregion Data Collection

    #region Assessment Logic

    # Evaluate each RDP app for Conditional Access policy protection with phishing-resistant MFA
    $results = @()

    foreach ($rdpApp in $rdpApps) {
        $protected = $false
        $protectedBy = 'None'
        $authStrengthName = 'N/A'
        $status = 'Fail'
        $targetingMethod = 'None'
        $policyId = $null

        # Check if any enabled CA policy with phishing-resistant MFA targets this app
        foreach ($policy in $enabledPolicies) {
            $includeApps = $policy.conditions.applications.includeApplications
            $appFilter = $policy.conditions.applications.applicationFilter

            if ($includeApps -contains $rdpApp.AppId -or $includeApps -contains 'All') {
                $protected = $true
                $protectedBy = $policy.displayName
                $authStrengthName = 'Phishing-resistant MFA'
                $status = 'Pass'
                $targetingMethod = if ($includeApps -contains 'All') { 'All Apps' } else { 'Direct' }
                $policyId = $policy.id
                break
            }
            elseif ($appFilter) {
                $protected = $true
                $protectedBy = $policy.displayName
                $authStrengthName = 'Phishing-resistant MFA'
                $status = 'Investigate'
                $targetingMethod = 'Filter (Custom Security Attributes)'
                $policyId = $policy.id
                break
            }
        }

        # General RDP apps without protection need investigation (cannot confirm if they target DCs)
        if (-not $protected -and $rdpApp.AppType -eq 'General RDP App') {
            $status = 'Investigate'
        }

        $results += [PSCustomObject]@{
            AppName         = $rdpApp.AppName
            AppId           = $rdpApp.AppId
            DestinationHost = $rdpApp.DestinationHost
            AppType         = $rdpApp.AppType
            ProtectedBy     = $protectedBy
            AuthStrength    = $authStrengthName
            Status          = $status
            TargetingMethod = $targetingMethod
            PolicyId        = $policyId
        }
    }

    # Determine overall test status
    $passed = $false
    $customStatus = $null
    $testResultMarkdown = ''

    if ($appType -eq 'DC RDP') {
        $failedApps = $results | Where-Object { $_.Status -eq 'Fail' }
        $investigateApps = $results | Where-Object { $_.Status -eq 'Investigate' }

        if ($failedApps.Count -gt 0) {
            $testResultMarkdown = "❌ RDP access (port 3389) to identified domain controller hosts is not protected by a Conditional Access policy requiring phishing-resistant authentication.`n`n%TestResult%"
        }
        elseif ($investigateApps.Count -gt 0) {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ A Conditional Access policy requiring phishing-resistant authentication targets applications via custom security attributes - manual verification required to confirm the domain controller RDP application has the required attribute assigned (Global Admin cannot read custom security attributes by default).`n`n%TestResult%"
        }
        else {
            $passed = $true
            $testResultMarkdown = "✅ RDP access (port 3389) to identified domain controller hosts is protected by a Conditional Access policy requiring phishing-resistant authentication (FIDO2, Windows Hello for Business, or Certificate-based MFA).`n`n%TestResult%"
        }
    }
    else {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ No domain controller hosts identified, but RDP-enabled Private Access applications (port 3389) were found - manual verification recommended to confirm these are not domain controllers and to ensure appropriate protection.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $privateAccessLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/EnterpriseApplicationListBladeV3/fromNav/globalSecureAccess/applicationType/GlobalSecureAccessApplication'
    $caPoliciesLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'

    # Build DC Hosts section
    $dcHostsSection = ''
    if ($dcHosts.Count -gt 0) {
        $dcHostRows = ''
        foreach ($dcHost in $dcHosts.Keys) {
            $info = $dcHosts[$dcHost]
            $rdpFound = if ($info.RdpAppFound) { 'Yes' } else { 'No' }
            $dcHostRows += "| $(Get-SafeMarkdown $dcHost) | $(Get-SafeMarkdown $info.SourceApp) | $($info.Ports) | $rdpFound | $(Get-SafeMarkdown $info.RdpAppName) |`n"
        }

        $dcHostsSection = @"

## [Identified domain controller hosts]($privateAccessLink)

| DC host (FQDN/IP) | Source application | Ports configured | RDP app found | RDP app name |
| :--- | :--- | :--- | :--- | :--- |
$dcHostRows
"@
    }

    # Build RDP Apps section
    $rdpAppRows = ''
    foreach ($result in $results) {
        $policyCell = if ($result.ProtectedBy -ne 'None' -and $result.PolicyId) {
            "[$(Get-SafeMarkdown $result.ProtectedBy)](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($result.PolicyId))"
        } else { $result.ProtectedBy }

        $statusIcon = switch ($result.Status) {
            'Pass' { '✅' }
            'Fail' { '❌' }
            'Investigate' { '⚠️' }
        }

        $rdpAppRows += "| $(Get-SafeMarkdown $result.AppName) | $(Get-SafeMarkdown $result.AppId) | $(Get-SafeMarkdown $result.DestinationHost) | $(Get-SafeMarkdown $result.AppType) | $policyCell | $($result.AuthStrength) | $statusIcon $($result.Status) |`n"
    }

    $rdpAppsSection = @"

## [Private Access RDP applications requiring protection]($privateAccessLink)

| Application name | App ID | Target host | App type | Protected by CA policy | Authentication strength | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
$rdpAppRows
"@

    # Build CA Policies section
    $caPoliciesSection = ''
    if ($enabledPolicies.Count -gt 0) {
        $policyRows = ''
        foreach ($policy in $enabledPolicies) {
            $policyNameLink = "[$(Get-SafeMarkdown $policy.displayName)](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id))"
            $policyState = Get-FormattedPolicyState $policy.state
            $includeApps = $policy.conditions.applications.includeApplications
            $appFilter = $policy.conditions.applications.applicationFilter

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
                foreach ($aid in $includeApps) {
                    $matchedApp = $results | Where-Object { $_.AppId -eq $aid } | Select-Object -First 1
                    if ($matchedApp) { $appNames += $matchedApp.AppName }
                }
                $targetApps = if ($appNames.Count -gt 0) { ($appNames | Sort-Object -Unique) -join ', ' } else { "$($includeApps.Count) application(s)" }
                $targetingMethod = 'Direct'
            }

            $policyRows += "| $policyNameLink | $policyState | $(Get-SafeMarkdown $targetApps) | $targetingMethod |`n"
        }

        $caPoliciesSection = @"

## [Conditional Access policies requiring phishing-resistant MFA]($caPoliciesLink)

| Policy name | State | Target applications | Targeting method |
| :--- | :--- | :--- | :--- |
$policyRows
"@
    }

    # Combine sections using format template
    $formatTemplate = @'
{0}{1}{2}
'@

    $mdInfo = $formatTemplate -f $dcHostsSection, $rdpAppsSection, $caPoliciesSection
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '25398'
        Title  = 'Domain controller RDP access is protected by phishing-resistant authentication through Global Secure Access'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
