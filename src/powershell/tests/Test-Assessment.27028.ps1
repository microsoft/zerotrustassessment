<#
.SYNOPSIS
    A web content filtering policy governs Copilot Studio agent traffic through the baseline profile

.DESCRIPTION
    Evaluates whether the Global Secure Access baseline profile is enabled and linked to an enabled,
    administrator-configured web content filtering policy. The baseline profile is the only supported
    enforcement path for Copilot Studio agent traffic, so without such a policy an agent's HTTP node
    action or connector can reach web destinations the organization intended to block.

.NOTES
    Test ID: 27028
    Pillar: Network
    Risk Level: High
    SFI Pillar: Protect networks
    Required API: networkAccess/filteringProfiles (beta)
#>

function Test-Assessment-27028 {
    [ZtTest(
        Category = 'AI Gateway',
        ImplementationCost = 'Medium',
        Service = ('Graph'),
        CompatibleLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27028,
        Title = 'A web content filtering policy governs Copilot Studio agent traffic through the baseline profile',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    # The baseline profile is identified by its fixed priority and is the only profile supported for agent traffic.
    [int]$baselineProfilePriority = 65000
    # Allow-all placeholder policy that ships with every tenant; it isn't an administrator-configured restriction.
    [string]$defaultPolicyName = 'All websites'

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Evaluating web content filtering on the Global Secure Access baseline profile'
    Write-ZtProgress -Activity $activity -Status 'Querying filtering profiles'

    # Q1: Get the baseline profile and its linked policies
    $filteringProfiles = @()
    $errorMsg = $null
    $httpStatusCode = $null

    try {
        $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{
            '$filter' = "priority eq $baselineProfilePriority"
            '$select' = 'id,name,state,priority'
            '$expand' = 'policies($select=id,state;$expand=policy($select=id,name,version))'
        } -ApiVersion beta -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        $httpStatusCode = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Failed to retrieve filtering profiles (HTTP $httpStatusCode): $errorMsg" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null
    $testResultMarkdown = ''
    $baselineState = 'Not found'
    $enabledPolicyNames = @()

    if ($httpStatusCode -eq 404) {
        # The filtering profile resource is unavailable, so the required enforcement path is absent: same outcome as an empty result.
        Write-PSFMessage 'Global Secure Access filtering profiles are not available in this tenant.' -Tag Test -Level Verbose
    }

    if ($errorMsg -and $httpStatusCode -ne 404) {
        $customStatus = 'Investigate'
        $testResultMarkdown = if ($httpStatusCode -in 401, 403) {
            '⚠️ Unable to read the Global Secure Access baseline profile due to insufficient permissions. Grant the **NetworkAccess.Read.All** Microsoft Graph permission and assign the **Global Secure Access Administrator** or **Security Reader** role, then rerun the assessment.'
        }
        else {
            '⚠️ Unable to retrieve the Global Secure Access filtering profiles due to an API error. Please rerun the assessment.'
        }
    }
    else {
        $baselineProfile = $filteringProfiles | Where-Object { $_.priority -eq $baselineProfilePriority } | Select-Object -First 1

        if ($baselineProfile) {
            $baselineState = $baselineProfile.state
            $enabledPolicyNames = @($baselineProfile.policies | Where-Object {
                    $_.'@odata.type' -eq '#microsoft.graph.networkaccess.filteringPolicyLink' -and
                    $_.state -eq 'enabled' -and
                    $_.policy.name -and
                    $_.policy.name -ne $defaultPolicyName
                } | ForEach-Object { $_.policy.name })
        }

        $passed = $baselineState -eq 'enabled' -and $enabledPolicyNames.Count -gt 0

        if ($passed) {
            $testResultMarkdown = "✅ The Global Secure Access baseline profile is enabled and linked to an administrator-configured web content filtering policy that governs Copilot Studio agent traffic.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ The Global Secure Access baseline profile isn't enabled or lacks an enabled administrator-configured web content filtering policy, leaving Copilot Studio agent web traffic unrestricted by that policy.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if (-not $customStatus) {
        $baselineStateDisplay = if ($baselineState -eq 'enabled') { '✅ Enabled' } else { "❌ $baselineState" }
        $policyNamesDisplay = if ($enabledPolicyNames.Count -gt 0) {
            ($enabledPolicyNames | Sort-Object -Unique | ForEach-Object { Get-SafeMarkdown $_ }) -join ', '
        }
        else {
            'None'
        }
        $statusDisplay = if ($passed) { '✅ Pass' } else { '❌ Fail' }

        $formatTemplate = @'
## [Global Secure Access Security Profiles]({0})

| Baseline profile state | Enabled web content filtering policy name(s) | Status |
| :--------------------- | :------------------------------------------- | :----- |
{1}
'@

        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/FilteringPolicyProfiles.ReactView'
        $tableRows = "| $baselineStateDisplay | $policyNamesDisplay | $statusDisplay |`n"
        $mdInfo = $formatTemplate -f $portalLink, $tableRows
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '27028'
        Title  = 'A web content filtering policy governs Copilot Studio agent traffic through the baseline profile'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
