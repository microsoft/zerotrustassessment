<#
.SYNOPSIS
    Super user membership is configured for Azure Information Protection

.DESCRIPTION
    Evaluates whether the Azure Information Protection (AIP) super user feature is properly configured.

    The cmdlets require the AipService module (v3.0+) which is only supported on Windows PowerShell 5.1. A PowerShell 7 subprocess workaround is automatically employed if running under PowerShell Core.

.NOTES
    Test ID: 35011
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-35011 {
    [ZtTest(
        Category = 'Advanced Label Features',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce','External'),
        TestId = 35011,
        Title = 'Super user membership is configured for Azure Information Protection',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Azure Information Protection Super User Configuration'
    Write-ZtProgress -Activity $activity -Status 'Querying AIP super user settings'

    $superUserFeatureEnabled = $null
    $superUsers = @()
    $superUserObjects = @()
    $errorMsg = $null

    try {
        # Note: AipService must be authenticated in Connect-ZtAssessment first
        # This test only performs queries against the authenticated service

        # Query Q1: Check if super user feature is enabled
        $superUserFeatureRaw = Get-AipServiceSuperUserFeature -ErrorAction Stop
        $superUserFeatureEnabled = $superUserFeatureRaw.Value

        # Query Q2: Get list of configured super users
        $superUsers = Get-AipServiceSuperUser -ErrorAction Stop

        # Process superusers and create PSObjects with type classification
        foreach ($superUser in $superUsers) {
            # Split superuser on @ to extract the appId (for service principals) or email (for users)
            $userIdentifier = $superUser -split '@' | Select-Object -First 1

            # Check if the identifier is a GUID (service principal) or email/UPN (user)
            $parsedGuid = [Guid]::Empty
            $isGuid = [Guid]::TryParse($userIdentifier, [ref]$parsedGuid)
            $accountType = if ($isGuid) { 'Service Principal' } else { 'User' }

            # For users, display the full email; for service principals, will be updated with lookup result
            $displayName = if ($isGuid) { $userIdentifier } else { $superUser }
            $servicePrincipalName = $null
            $objectId = $null

            # If it's a service principal, lookup the display name via Graph API
            if ($isGuid) {
                try {
                    $spDetails = Invoke-ZtGraphRequest -RelativeUri 'servicePrincipals' -ApiVersion 'beta' -Filter "appId eq '$userIdentifier'" -Select 'id,displayName,appDisplayName,servicePrincipalNames' -ErrorAction SilentlyContinue

                    if ($spDetails) {
                        # Prefer appDisplayName, then displayName, then the GUID
                        $servicePrincipalName = $spDetails.appDisplayName
                        if (-not $servicePrincipalName) {
                            $servicePrincipalName = $spDetails.displayName
                        }

                        if ($servicePrincipalName) {
                            $displayName = $servicePrincipalName
                        }
                        else {
                            $displayName = $userIdentifier
                        }

                        # Capture the service principal's object ID
                        if ($spDetails.id) {
                            $objectId = $spDetails.id
                        }
                    }
                }
                catch {
                    Write-PSFMessage "Warning: Could not lookup service principal details for $userIdentifier : $_" -Tag Test -Level Warning
                }
            }

            $superUserObj = [PSCustomObject]@{
                DisplayName        = $displayName
                AccountType        = $accountType
                AppId              = $userIdentifier
                Id                 = $objectId
                IsServicePrincipal = $isGuid
            }

            $superUserObjects += $superUserObj
        }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying AIP Super User configuration: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $investigateFlag = $false
    $superUserCount = if ($superUsers) { @($superUsers).Count } else { 0 }

    if ($errorMsg) {
        $investigateFlag = $true
    }
    else {
        # Evaluation logic:
        # - Pass: Feature is DISABLED and count >= 1 (secure state with emergency access pre-configured)
        # - Fail: Feature is DISABLED and count = 0 (no emergency access capability)
        # - Fail: Feature is ENABLED and count = 0 (feature active but no members configured)
        # - Investigate: Feature is ENABLED and count >= 1 (feature actively in use)

        if ($superUserFeatureEnabled -eq "Disabled") {
            if ($superUserCount -ge 1) {
                $passed = $true
            }
            else {
                $passed = $false
            }
        }
        elseif ($superUserFeatureEnabled -eq "Enabled") {
            if ($superUserCount -ge 1) {
                $investigateFlag = $true
            }
            else {
                $passed = $false
            }
        }
    }
    #endregion Assessment Logic

    #region Report Generation

    $testResultMarkdown = ""
    $mdInfo = ""
    $customStatus = $null

    if ($investigateFlag) {
        if ($errorMsg) {
            $testResultMarkdown = "⚠️ Unable to determine super user configuration due to permissions or connection issues.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "⚠️ Super user feature is enabled with members configured (review accounts and consider using Azure PIM for just-in-time access instead of permanent enablement).`n`n%TestResult%"
        }
        $customStatus = 'Investigate'
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Super user feature is disabled with at least one member pre-configured for emergency access (review members to ensure they're still needed).`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Super user feature is disabled with no members configured, OR feature is enabled with no members.`n`n%TestResult%"
    }

    # Build detailed information section
    $mdInfo = "## Azure Information Protection Super User Configuration`n`n"

    if ($errorMsg) {
        # Show explicit "Unknown" values when an error occurred
        $mdInfo += "**Super User Feature:** Unknown (unable to query)`n`n"
        $mdInfo += "**Super Users Configured:** Unknown`n`n"
    }
    else {
        $mdInfo += "**Super User Feature:** $superUserFeatureEnabled`n`n"
        $mdInfo += "**Super Users Configured:** $superUserCount`n`n"
    }

    if (-not $errorMsg -and $superUserCount -gt 0) {
        $mdInfo += "| Super User Display | Account Type |`n"
        $mdInfo += "| :--- | :--- |`n"

        foreach ($superUserObj in $superUserObjects) {
            if ($superUserObj.IsServicePrincipal -and $superUserObj.Id) {
                # Only create portal link when we have a valid object ID
                $spPortalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($superUserObj.Id)/appId/$($superUserObj.AppId)"
                $displayText = "[$(Get-SafeMarkdown $superUserObj.DisplayName)]($spPortalLink)"
            }
            else {
                $displayText = Get-SafeMarkdown $superUserObj.DisplayName
            }
            $mdInfo += "| $displayText | $($superUserObj.AccountType) |`n"
        }

        $mdInfo += "`n"
    }

    $mdInfo += "**Note:** Super user configuration is not available through the Azure portal and must be managed via PowerShell using the AipService module.`n"

    # Replace placeholder with actual detailed info
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35011'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
