<#
.SYNOPSIS
    Browser data loss prevention is enabled for AI apps via Edge for Business

.DESCRIPTION
    Browser Data Loss Prevention (DLP) for cloud apps in Microsoft Edge for Business prevents users
    from uploading, downloading, copying, or pasting sensitive data to and from unmanaged cloud AI
    services (ChatGPT, Google Gemini, Claude, etc.) directly through the browser.

.NOTES
    Test ID: 35041
    Category: Data Security Posture Management
    Pillar: Data
    Required Module: ExchangeOnlineManagement
    Required Connection: Security & Compliance PowerShell
#>

function Test-Assessment-35041 {
    [ZtTest(
        Category = 'Data Security Posture Management',
        ImplementationCost = 'High',
        MinimumLicense = ('Microsoft 365 E5', 'Microsoft Purview PAYG'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35041,
        Title = 'Browser data loss prevention is enabled for AI apps via Edge for Business',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Browser DLP for AI Apps'
    Write-ZtProgress -Activity $activity -Status 'Getting DLP policies with Browser enforcement'

    $browserDlpPolicies = @()
    $browserDlpRules = @()

    try {
        # Q1: Find DLP policies with Browser enforcement plane (indicates Browser DLP configured)
        $browserDlpPolicies = @(Get-DlpCompliancePolicy -ErrorAction Stop | Where-Object { $_.EnforcementPlanes -contains 'Browser' })

        # Q2: Get DLP compliance rules for those Browser policies
        if ($browserDlpPolicies.Count -gt 0) {
            Write-ZtProgress -Activity $activity -Status 'Getting DLP rules for Browser policies'
            $browserDlpRules = @($browserDlpPolicies | ForEach-Object {
                Get-DlpComplianceRule -Policy $_.Identity -ErrorAction SilentlyContinue
            })
        }
    }
    catch {
        Write-PSFMessage "Failed to retrieve DLP policies: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $enabledBrowserPolicies = @()

    # Step 1: Discover Browser DLP Policies
    # If no Browser enforcement plane policies found → FAIL (Browser DLP not configured)
    if ($browserDlpPolicies.Count -eq 0) {
        $passed = $false
    }
    # Step 2: Verify Rules Exist
    # If no Browser DLP rules found → FAIL (policies exist but lack enforcement rules)
    elseif ($browserDlpRules.Count -eq 0) {
        $passed = $false
    }
    # Step 3: Check Enablement
    # If count ≥ 1 enabled browser DLP policy → PASS
    # If count = 0 or all policies disabled → FAIL
    else {
        $enabledBrowserPolicies = @($browserDlpPolicies | Where-Object { $_.Enabled -eq $true })
        if ($enabledBrowserPolicies.Count -ge 1) {
            $passed = $true
        }
        else {
            $passed = $false
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''
    $mdInfo = ''

    if ($passed) {
        $testResultMarkdown = "✅ Browser Data Loss Prevention for AI Apps is configured and enabled via at least one active DLP policy with Browser enforcement, preventing sensitive data from being uploaded to or copied from unmanaged AI services through Edge for Business.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Browser DLP for AI apps is not configured. Either no Browser DLP policies exist, policies exist but have no rules, or all Browser DLP policies are disabled.`n`n%TestResult%"
    }

    # Build detailed information section (always displayed)
    $mdInfo = "`n**Browser DLP Configuration Summary:**`n`n"
    $mdInfo += "* Browser DLP Policies Found: $($browserDlpPolicies.Count)`n"
    $mdInfo += "* Browser DLP Policies Enabled: $($enabledBrowserPolicies.Count)`n"
    $mdInfo += "* Browser DLP Rules: $($browserDlpRules.Count)`n`n"

    # Browser DLP Policies section
    if ($browserDlpPolicies.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
## [Discovered Policies](https://purview.microsoft.com/datalossprevention/policies)

| Policy Name | Enabled | Mode | EnforcementPlanes | PolicyCategory | CreatedBy | CreationTimeUtc | Rules Count |
|:---|:---|:---|:---|:---|:---|:---|:---|
{0}
'@
        foreach ($policy in $browserDlpPolicies | Sort-Object Name) {
            $policyName = Get-SafeMarkdown($policy.Name)
            $enabledStatus = if ($policy.Enabled) { 'True' } else { 'False' }
            $mode = if ($policy.Mode) { Get-SafeMarkdown($policy.Mode) } else { 'N/A' }
            $enforcementPlanes = if ($policy.EnforcementPlanes) {  (Get-SafeMarkdown(($policy.EnforcementPlanes -join ', '))) } else { 'N/A' }
            $policyCategory = if ($policy.PolicyCategory) { Get-SafeMarkdown($policy.PolicyCategory) } else { 'N/A' }
            $createdBy = if ($policy.CreatedBy) { Get-SafeMarkdown($policy.CreatedBy) } else { 'N/A' }
            $createdDate = if ($policy.CreationTimeUtc) { $policy.CreationTimeUtc.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { 'N/A' }
            $rulesCount = @($browserDlpRules | Where-Object { $_.ParentPolicyName -eq $policy.Name -or $_.Policy -eq $policy.Identity }).Count
            $tableRows += "| $policyName | $enabledStatus | $mode | $enforcementPlanes | $policyCategory | $createdBy | $createdDate | $rulesCount |`n"
        }
        $mdInfo += $formatTemplate -f $tableRows
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '35041'
        Title  = 'Browser data loss prevention is enabled for AI apps via Edge for Business'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
