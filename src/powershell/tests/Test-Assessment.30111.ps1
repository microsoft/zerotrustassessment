function Test-Assessment-30111 {
    [ZtTest(
        Category = 'Zero Trust Network Access (ZTNA)',
        ImplementationCost = 'Medium',
        MinimumLicense = ('AAD_PREMIUM_P1', 'Entra_Premium_Internet_Access', 'Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 30111,
        Title = 'Global Secure Access is enabled',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    # Check for required licensing
    if ( -not (Get-ZtLicense EntraIDP1) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return
    }

    $activity = "Checking if Global Secure Access forwarding profiles are configured and actively used"
    Write-ZtProgress -Activity $activity -Status "Querying Global Secure Access configuration"

    # Query 1: Get all traffic forwarding profiles
    try {
        $forwardingProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/forwardingProfiles' -ApiVersion 'beta'
    }
    catch {
        Write-PSFMessage -Level Warning -Message "Failed to retrieve Global Secure Access forwarding profiles: {0}" -StringValues $_.Exception.Message
        Add-ZtTestResultDetail -Details "Failed to retrieve Global Secure Access configuration from Microsoft Graph" -Remediation "Verify tenant has appropriate licenses and permissions to access networkAccess API"
        return
    }

    # Evaluate if forwarding profiles exist
    if (-not $forwardingProfiles -or $forwardingProfiles.Count -eq 0) {
        $passed = $false
        $testResultMarkdown = "❌ Global Secure Access is not configured. No forwarding profiles found."
        $details = "Global Secure Access must be configured with at least one traffic forwarding profile (Microsoft traffic, Internet access, or Private access)."
        $remediation = "Configure Global Secure Access by enabling and assigning at least one forwarding profile. See: https://learn.microsoft.com/en-us/entra/global-secure-access/concept-traffic-forwarding"
    }
    else {
        # Query 2: For each profile, check if it has user or remote network assignments
        $profilesWithAssignments = @()
        $profilesWithoutAssignments = @()

        foreach ($profile in $forwardingProfiles) {
            $profileId = $profile.id

            try {
                # Check user assignments
                $userAssignments = Invoke-ZtGraphRequest -RelativeUri "networkAccess/forwardingProfiles/$profileId/users" -ApiVersion 'beta' -ErrorAction SilentlyContinue

                # Check remote network assignments
                $remoteNetworkAssignments = Invoke-ZtGraphRequest -RelativeUri "networkAccess/forwardingProfiles/$profileId/remoteNetworks" -ApiVersion 'beta' -ErrorAction SilentlyContinue

                # Count total assignments
                $totalAssignments = 0
                if ($userAssignments) { $totalAssignments += @($userAssignments).Count }
                if ($remoteNetworkAssignments) { $totalAssignments += @($remoteNetworkAssignments).Count }

                if ($totalAssignments -gt 0) {
                    $profilesWithAssignments += [PSCustomObject]@{
                        Name                    = $profile.name
                        Type                    = $profile.type
                        State                   = $profile.state
                        UserAssignmentCount     = @($userAssignments).Count
                        RemoteNetworkCount      = @($remoteNetworkAssignments).Count
                        TotalAssignments        = $totalAssignments
                        LastModifiedDateTime    = $profile.lastModifiedDateTime
                    }
                }
                else {
                    $profilesWithoutAssignments += [PSCustomObject]@{
                        Name                = $profile.name
                        Type                = $profile.type
                        State               = $profile.state
                        LastModifiedDateTime = $profile.lastModifiedDateTime
                    }
                }
            }
            catch {
                Write-PSFMessage -Level Warning -Message "Failed to retrieve assignments for profile {0}: {1}" -StringValues $profile.name, $_.Exception.Message
            }
        }

        # Determine test result
        if ($profilesWithAssignments.Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "✅ Global Secure Access is enabled with active forwarding profile configurations."
            $details = "Found $(@($profilesWithAssignments).Count) forwarding profile(s) with active assignments (users or remote networks)."
        }
        elseif ($profilesWithoutAssignments.Count -gt 0) {
            $passed = $false
            $testResultMarkdown = "⚠️ Global Secure Access forwarding profiles are configured but have no active user or remote network assignments."
            $details = "Found $(@($profilesWithoutAssignments).Count) profile(s) without assignments. Configuration is incomplete."
            $remediation = "Assign users or remote networks to the configured forwarding profiles. See: https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-manage-private-access-profile"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ Global Secure Access forwarding profiles exist but none have active assignments."
            $details = "All forwarding profiles are either disabled or have no user/remote network assignments."
            $remediation = "Enable Global Secure Access by assigning users to forwarding profiles. See: https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-get-started-with-global-secure-access"
        }
    }

    # Add result details with profile information
    if ($profilesWithAssignments) {
        $profileMarkdown = "## Active Forwarding Profiles`n`n"
        $profileMarkdown += "| Profile Name | State | Users | Remote Networks | Last Modified |`n"
        $profileMarkdown += "|---|---|---|---|---|`n"
        foreach ($profile in $profilesWithAssignments) {
            $profileMarkdown += "| $($profile.Name) | $($profile.State) | $($profile.UserAssignmentCount) | $($profile.RemoteNetworkCount) | $($profile.LastModifiedDateTime) |`n"
        }
        $details += "`n`n$profileMarkdown"
    }

    if ($profilesWithoutAssignments) {
        $inactiveMarkdown = "## Inactive Forwarding Profiles (No Assignments)`n`n"
        $inactiveMarkdown += "| Profile Name | State | Last Modified |`n"
        $inactiveMarkdown += "|---|---|---|`n"
        foreach ($profile in $profilesWithoutAssignments) {
            $inactiveMarkdown += "| $($profile.Name) | $($profile.State) | $($profile.LastModifiedDateTime) |`n"
        }
        $details += "`n`n$inactiveMarkdown"
    }

    # Portal link
    $portalLink = "[View Global Secure Access Configuration](https://entra.microsoft.com/#view/Microsoft_AAD_GlobalSecureAccess/GlobalSecureAccessBlade)"
    $details += "`n`n$portalLink"

    # Set test result
    Add-ZtTestResultDetail -Result $passed -Details $details -Remediation $remediation

    Write-PSFMessage '🟩 End' -Tag Test -Level VeryVerbose
}
