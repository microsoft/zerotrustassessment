<#
.SYNOPSIS
    Checks if Microsoft Rights Management Services (RMS) is allowed in Cross-Tenant Access Policies (XTAP).

.DESCRIPTION
    This test verifies that the Microsoft Rights Management Services (RMS) application (App ID: 00000012-0000-0000-c000-000000000000)
    is allowed in both Inbound and Outbound Cross-Tenant Access Policies.
    It checks the Default policy and any Partner-specific policies.

    RMS is required for decrypting content shared across tenants (e.g., encrypted emails, MIP labels).
    Blocking it prevents users from opening protected content.

.NOTES
    Test ID: 35002
    Pillar: Data
    Risk Level: High
    Graph Scopes: Policy.Read.All, CrossTenantInformation.ReadBasic.All
#>

function Test-Assessment-35002 {
    [ZtTest(
        Category = 'Entra',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35002,
        Title = 'Cross-Tenant Access Policy (XTAP) RMS Inbound/Outbound Settings',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions
    function Get-RmsAccessStatus {
        param (
            $Settings
        )

        $rmsAppId = "00000012-0000-0000-c000-000000000000"
        $allApps = "AllApplications"

        if ($null -eq $Settings -or $null -eq $Settings.applications) {
            return "Inherited"
        }

        $accessType = $Settings.applications.accessType
        # Handle targets being an array or single object or null
        $targets = @()
        if ($Settings.applications.targets) {
            $targets = $Settings.applications.targets | ForEach-Object { $_.target }
        }

        if ($accessType -eq "allowed") {
            # In "Allowed" mode, only listed apps are allowed.
            if ($targets -contains $allApps -or $targets -contains $rmsAppId) {
                return "Allowed"
            }
            return "Blocked (Implicit)"
        }
        elseif ($accessType -eq "blocked") {
            # In "Blocked" mode, listed apps are blocked.
            if ($targets -contains $allApps -or $targets -contains $rmsAppId) {
                return "Blocked (Explicit)"
            }
            return "Allowed (Implicit)"
        }

        return "Unknown"
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Cross-Tenant Access Policy (XTAP) RMS Settings'
    Write-ZtProgress -Activity $activity -Status 'Getting Default Policy'

    $defaultPolicy = $null
    $partners = @()
    $errorMsg = $null

    try {
        # 1. Get Default Policy
        $defaultPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/crossTenantAccessPolicy/default' -ApiVersion v1.0 -ErrorAction Stop

        # 2. Get Partner Policies
        Write-ZtProgress -Activity $activity -Status 'Getting Partner Policies'
        $partners = Invoke-ZtGraphRequest -RelativeUri 'policies/crossTenantAccessPolicy/partners' -ApiVersion v1.0 -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying Cross-Tenant Access Policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $xtapResults = @()
    $hasFailure = $false

    if ($errorMsg) {
        $passed = $false
    }
    else {
        # Check Default Inbound
        if ($defaultPolicy) {
            $inboundStatus = Get-RmsAccessStatus -Settings $defaultPolicy.b2bCollaborationInbound
            if ($inboundStatus -notlike "Allowed*") { $hasFailure = $true }

            $xtapResults += [PSCustomObject]@{
                Policy    = "Default"
                Direction = "Inbound"
                Status    = $inboundStatus
                Details   = "B2B Collaboration"
            }

            # Check Default Outbound
            $outboundStatus = Get-RmsAccessStatus -Settings $defaultPolicy.b2bCollaborationOutbound
            if ($outboundStatus -notlike "Allowed*") { $hasFailure = $true }

            $xtapResults += [PSCustomObject]@{
                Policy    = "Default"
                Direction = "Outbound"
                Status    = $outboundStatus
                Details   = "B2B Collaboration"
            }
        }

        # Check Partners
        foreach ($partner in $partners) {
            $tenantId = $partner.tenantId

            # Check Inbound
            if ($partner.b2bCollaborationInbound) {
                $pInboundStatus = Get-RmsAccessStatus -Settings $partner.b2bCollaborationInbound
                if ($pInboundStatus -ne "Inherited") {
                    if ($pInboundStatus -notlike "Allowed*") { $hasFailure = $true }

                    $xtapResults += [PSCustomObject]@{
                        Policy    = "Partner ($tenantId)"
                        Direction = "Inbound"
                        Status    = $pInboundStatus
                        Details   = "Explicit Override"
                    }
                }
            }

            # Check Outbound
            if ($partner.b2bCollaborationOutbound) {
                $pOutboundStatus = Get-RmsAccessStatus -Settings $partner.b2bCollaborationOutbound
                if ($pOutboundStatus -ne "Inherited") {
                    if ($pOutboundStatus -notlike "Allowed*") { $hasFailure = $true }

                    $xtapResults += [PSCustomObject]@{
                        Policy    = "Partner ($tenantId)"
                        Direction = "Outbound"
                        Status    = $pOutboundStatus
                        Details   = "Explicit Override"
                    }
                }
            }
        }

        $passed = -not $hasFailure
    }
    #endregion Assessment Logic

    #region Report Generation
    $rmsAppId = "00000012-0000-0000-c000-000000000000"

    if ($errorMsg) {
        $testResultMarkdown = "### Investigate`n`n"
        $testResultMarkdown += "Cross-tenant access policy settings cannot be determined or RMS is not explicitly configured.`n`n"
        $testResultMarkdown += "Please check the console output for error details."
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ RMS application is allowed (or not restricted) in cross-tenant access policy settings for both inbound and outbound access.`n`n"
        }
        else {
            $testResultMarkdown = "❌ RMS application is explicitly blocked in cross-tenant access policy inbound or outbound settings.`n`n"
        }

        $testResultMarkdown += "### Cross-Tenant Access Policy (XTAP) RMS Settings`n`n"
        $testResultMarkdown += "| Policy | Direction | Status | Details |`n"
        $testResultMarkdown += "|:---|:---|:---|:---|`n"

        foreach ($result in $xtapResults) {
            $icon = if ($result.Status -like "Allowed*") { "✅" } else { "❌" }
            $testResultMarkdown += "| $($result.Policy) | $($result.Direction) | $icon $($result.Status) | $($result.Details) |`n"
        }
        $testResultMarkdown += "`n`n"

        if (-not $passed) {
            $testResultMarkdown += "⚠️ **Risk:** Blocking RMS prevents users from opening encrypted content (emails, documents) shared between tenants.`n"
            $testResultMarkdown += "Please review the blocked policies and add 'Microsoft Rights Management Services' (App ID: $rmsAppId) to the allowed applications list.`n"
        }
    }
    #endregion Report Generation

    $testResultDetail = @{
        TestId             = '35002'
        Title              = 'Cross-Tenant Access Policy (XTAP) RMS Inbound/Outbound Settings'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @testResultDetail
}
