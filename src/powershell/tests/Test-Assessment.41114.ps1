<#
.SYNOPSIS
    Checks that Microsoft Teams protection policies are configured to block malicious messages, links, and attachments.

.NOTES
    Test ID: 41114
    Workshop Task: SECOPS-114
    Pillar: SecOps
    Category: Email and collaboration security
    Required role: Security Reader
#>

function Test-Assessment-41114 {
    [ZtTest(
        Category = 'Email and collaboration security',
        CompatibleLicense = ('ATP_ENTERPRISE'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph','ExchangeOnline'),
        SfiPillar = 'Protect tenants and isolate production systems',
        TenantType = ('Workforce'),
        TestId = 41114,
        Title = 'Microsoft Teams protection policies are configured to block malicious messages, links, and attachments',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $mgEnv = (Get-MgContext).Environment
    if ($mgEnv -eq 'USGov' -or $mgEnv -eq 'USGovDoD') {
        Write-PSFMessage 'This test is not applicable to the USGov or USGovDoD environments.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'This test is not applicable to the USGov or USGovDoD environments.'
        return
    }

    $activity = 'Checking Microsoft Teams protection policies in Microsoft Defender for Office 365'
    Write-ZtProgress -Activity $activity -Status 'Retrieving Safe Attachments policy for SharePoint, OneDrive, and Teams'
    $safeAttachmentPolicy = $null
    $q1Error = $null
    try {
        # Q1: Retrieve Safe Attachments policy for SharePoint, OneDrive, and Teams.
        $safeAttachmentPolicy = Get-AtpPolicyForO365 -ErrorAction Stop | Select-Object Name, EnableATPForSPOTeamsODB
    }
    catch {
        $q1Error = $_
        Write-PSFMessage "Q1: Failed to retrieve Safe Attachments policy: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Retrieving Teams protection policy'
    $teamsProtectionPolicy = $null
    $q2Error = $null
    try {
        # Q2a: Retrieve Teams protection policy (ZAP and quarantine settings).
        $teamsProtectionPolicy = @(Get-TeamsProtectionPolicy -ErrorAction Stop | Select-Object Name, ZapEnabled)
    }
    catch {
        $q2Error = $_
        Write-PSFMessage "Q2: Failed to retrieve Teams protection policy: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Retrieving Teams protection policy rule'
    $teamsProtectionPolicyRule = $null
    $q2rError = $null
    try {
        # Q2b: Retrieve Teams protection rule
        $teamsProtectionPolicyRule = @(Get-TeamsProtectionPolicyRule -ErrorAction Stop |
            Select-Object Name, TeamsProtectionPolicy, State, ExceptIfSentTo, ExceptIfSentToMemberOf, ExceptIfRecipientDomainIs)
    }
    catch {
        $q2rError = $_
        Write-PSFMessage "Q2r: Failed to retrieve Teams protection policy rule: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Retrieving Safe Links policies'
    $safeLinksPolicies = $null
    try {
        # Q3a: Retrieve all Safe Links policies; IsBuiltInProtection identifies the Microsoft-managed
        # Built-in Protection preset that applies to users not covered by a Standard/Strict/custom policy.
        $safeLinksPolicies = @(Get-SafeLinksPolicy -ErrorAction Stop | Select-Object Identity, IsBuiltInProtection, IsDefault, EnableSafeLinksForTeams)
    }
    catch {
        Write-PSFMessage "Q3: Failed to retrieve Safe Links policies: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Retrieving Safe Links rules'
    $safeLinksRules = $null
    $q3rError = $null
    try {
        # Q3b: Retrieve Safe Links rules; only enabled rules determine which policies are in scope.
        $safeLinksRules = @(Get-SafeLinksRule -ErrorAction Stop | Select-Object Name, SafeLinksPolicy, State)
    }
    catch {
        $q3rError = $_
        Write-PSFMessage "Q3r: Failed to retrieve Safe Links rules: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Retrieving Defender submission policy'
    $reportSubmissionPolicy = $null
    $q4Error = $null
    try {
        # Q4: Retrieve Teams user-reporting configuration from the Defender submission policy.
        $reportSubmissionPolicy = Get-ReportSubmissionPolicy -ErrorAction Stop | Select-Object Identity, ReportChatMessageEnabled
    }
    catch {
        $q4Error = $_
        Write-PSFMessage "Q4: Failed to retrieve report submission policy: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $anyFail        = $false
    $anyInvestigate = $false

    $controlRows = [System.Collections.Generic.List[PSCustomObject]]::new()

    $q1PortalLink = 'https://security.microsoft.com/safeattachmentv2'
    $q2PortalLink = 'https://security.microsoft.com/securitysettings/teamsProtectionPolicy'
    $q3PortalLink = 'https://security.microsoft.com/safelinksv2'
    $q4PortalLink = 'https://security.microsoft.com/securitysettings/userSubmission'

    # --- Q1: Safe Attachments for SharePoint, OneDrive, and Teams (tenant-wide) ---
    $q1Unknown = $q1Error -or $null -eq $safeAttachmentPolicy -or $null -eq $safeAttachmentPolicy.EnableATPForSPOTeamsODB
    $q1Enabled = -not $q1Unknown -and $safeAttachmentPolicy.EnableATPForSPOTeamsODB -eq $true
    if ($q1Unknown) { $anyInvestigate = $true } elseif (-not $q1Enabled) { $anyFail = $true }
    $controlRows.Add([PSCustomObject]@{
        Setting        = "[Safe Attachments for SharePoint, OneDrive, and Microsoft Teams]($q1PortalLink)"
        Policy         = ''
        AppliedViaRule = ''
        Enabled        = if ($q1Unknown) { '⚠️ Unknown' } elseif ($q1Enabled) { '✅ Yes' } else { '❌ No' }
        Status         = if ($q1Unknown) { '⚠️ Investigate' } elseif ($q1Enabled) { '✅ Pass' } else { '❌ Fail' }
    })

    # --- Q2: ZAP for Teams — the organization-wide policy determines ZAP state. ---
    # The optional Teams Protection rule only narrows coverage through exclusions.
    $q2PolicyAnomaly = $q2Error -or $null -eq $teamsProtectionPolicy -or $teamsProtectionPolicy.Count -ne 1
    if ($q2PolicyAnomaly) {
        $anyInvestigate = $true
        $controlRows.Add([PSCustomObject]@{
            Setting        = "[ZAP for Teams]($q2PortalLink)"
            Policy         = ''
            AppliedViaRule = ''
            Enabled        = '⚠️ Unknown'
            Status         = '⚠️ Investigate — could not retrieve the organization-wide Teams Protection policy'
        })
    }
    else {
        $organizationTeamsPolicy = $teamsProtectionPolicy[0]
        $zapUnknown = $null -eq $organizationTeamsPolicy.ZapEnabled
        $zapEnabled = -not $zapUnknown -and $organizationTeamsPolicy.ZapEnabled -eq $true
        if ($zapUnknown) {
            $anyInvestigate = $true
            $zapStatus = '⚠️ Investigate — ZapEnabled value is ambiguous'
        }
        elseif (-not $zapEnabled) {
            $anyFail = $true
            $zapStatus = '❌ Fail'
        }
        else {
            $zapStatus = '✅ Pass'
        }

        $enabledTeamsRule = $null
        if ($q2rError) {
            if (-not $anyFail) {
                $anyInvestigate = $true
                $zapStatus = '⚠️ Investigate — could not retrieve Teams Protection rules to check exclusions'
            }
        }
        else {
            $teamsProtectionRule = $teamsProtectionPolicyRule | Select-Object -First 1
            if ($teamsProtectionRule.State -eq 'Enabled') {
                $enabledTeamsRule = $teamsProtectionRule
                $hasExceptions = $teamsProtectionRule.ExceptIfSentTo -or
                    $teamsProtectionRule.ExceptIfSentToMemberOf -or
                    $teamsProtectionRule.ExceptIfRecipientDomainIs
            }

            if ($hasExceptions -and -not $anyFail) {
                $anyInvestigate = $true
                $zapStatus = "⚠️ Investigate — exceptions exist and they reduce ZAP coverage"
            }
        }

        $controlRows.Add([PSCustomObject]@{
            Setting        = "[ZAP for Teams]($q2PortalLink)"
            Policy         = $organizationTeamsPolicy.Name
            AppliedViaRule = $enabledTeamsRule.Name
            Enabled        = if ($zapUnknown) { '⚠️ Unknown' } elseif ($zapEnabled) { '✅ Yes' } else { '❌ No' }
            Status         = $zapStatus
        })
    }

    # --- Q3: Safe Links for Teams — evaluated per enabled Safe Links rule/policy ---
    # Build lookup: policy Identity → policy object.
    $safeLinksPolicyByIdentity = @{}
    if ($safeLinksPolicies) {
        foreach ($p in $safeLinksPolicies) {
            $safeLinksPolicyByIdentity[$p.Identity] = $p
        }
    }

    # Zero or null $safeLinksPolicies is a retrieval/permission anomaly: every MDO P1 tenant has at
    # least Built-in Protection, so an empty result should not silently become a Fail verdict.
    $q3PolicyAnomaly = $null -eq $safeLinksPolicies -or $safeLinksPolicies.Count -eq 0

    if ($q3rError -or $q3PolicyAnomaly) {
        # Cannot determine which Safe Links rules or policies are active — Investigate.
        $anyInvestigate = $true
        $controlRows.Add([PSCustomObject]@{
            Setting        = "[Safe Links for Teams]($q3PortalLink)"
            Policy         = ''
            AppliedViaRule = ''
            Enabled        = '⚠️ Unknown'
            Status         = '⚠️ Investigate — could not retrieve Safe Links rules or policies'
        })
    }
    else {
        $enabledSafeLinksRules = @($safeLinksRules | Where-Object { $_.State -eq 'Enabled' })
        # Built-in Protection covers recipients not matched by an enabled custom rule, so it is
        # always effective and must be reported alongside enabled-rule-referenced policies.
        $builtInSafeLinksPolicy = $safeLinksPolicies | Where-Object { $_.IsBuiltInProtection -eq $true } | Select-Object -First 1
        if ($null -eq $builtInSafeLinksPolicy) {
            $anyInvestigate = $true
            $controlRows.Add([PSCustomObject]@{
                Setting        = "[Safe Links for Teams]($q3PortalLink)"
                Policy         = ''
                AppliedViaRule = ''
                Enabled        = '⚠️ Unknown'
                Status         = '⚠️ Investigate — Built-in Protection policy not found'
            })
        }
        else {
            $teamsUnknown = $null -eq $builtInSafeLinksPolicy.EnableSafeLinksForTeams
            $teamsEnabled = -not $teamsUnknown -and $builtInSafeLinksPolicy.EnableSafeLinksForTeams -eq $true
            if ($teamsUnknown) { $anyInvestigate = $true } elseif (-not $teamsEnabled) { $anyFail = $true }
            $controlRows.Add([PSCustomObject]@{
                Setting        = "[Safe Links for Teams]($q3PortalLink)"
                Policy         = "(Built-in) $($builtInSafeLinksPolicy.Identity)"
                AppliedViaRule = ''
                Enabled        = if ($teamsUnknown) { '⚠️ Unknown' } elseif ($teamsEnabled) { '✅ Yes' } else { '❌ No' }
                Status         = if ($teamsUnknown) { '⚠️ Investigate' } elseif ($teamsEnabled) { '✅ Pass' } else { '❌ Fail' }
            })
        }

        foreach ($rule in $enabledSafeLinksRules) {
            $policyIdentity = $rule.SafeLinksPolicy
            $policy         = $safeLinksPolicyByIdentity[$policyIdentity]

            if ($null -eq $policy) {
                $anyInvestigate = $true
                $controlRows.Add([PSCustomObject]@{
                    Setting        = "[Safe Links for Teams]($q3PortalLink)"
                    Policy         = $policyIdentity
                    AppliedViaRule = $rule.Name
                    Enabled        = '⚠️ Unknown'
                    Status         = '⚠️ Investigate — referenced policy not found'
                })
                continue
            }

            $teamsUnknown = $null -eq $policy.EnableSafeLinksForTeams
            $teamsEnabled = -not $teamsUnknown -and $policy.EnableSafeLinksForTeams -eq $true
            if ($teamsUnknown) { $anyInvestigate = $true } elseif (-not $teamsEnabled) { $anyFail = $true }

            $controlRows.Add([PSCustomObject]@{
                Setting        = "[Safe Links for Teams]($q3PortalLink)"
                Policy         = $policyIdentity
                AppliedViaRule = $rule.Name
                Enabled        = if ($teamsUnknown) { '⚠️ Unknown' } elseif ($teamsEnabled) { '✅ Yes' } else { '❌ No' }
                Status         = if ($teamsUnknown) { '⚠️ Investigate' } elseif ($teamsEnabled) { '✅ Pass' } else { '❌ Fail' }
            })
        }
    }

    # --- Q4: Monitor reported items in Microsoft Teams (tenant-wide) ---
    $q4Unknown = $q4Error -or $null -eq $reportSubmissionPolicy -or $null -eq $reportSubmissionPolicy.ReportChatMessageEnabled
    $q4Enabled = -not $q4Unknown -and $reportSubmissionPolicy.ReportChatMessageEnabled -eq $true
    if ($q4Unknown) { $anyInvestigate = $true } elseif (-not $q4Enabled) { $anyFail = $true }
    $controlRows.Add([PSCustomObject]@{
        Setting        = "[Monitor reported items in Microsoft Teams]($q4PortalLink)"
        Policy         = ''
        AppliedViaRule = ''
        Enabled        = if ($q4Unknown) { '⚠️ Unknown' } elseif ($q4Enabled) { '✅ Yes' } else { '❌ No' }
        Status         = if ($q4Unknown) { '⚠️ Investigate' } elseif ($q4Enabled) { '✅ Pass' } else { '❌ Fail' }
    })

    # Final verdict — Fail takes priority over Investigate (spec ordering: Skipped → Fail → Investigate → Pass).
    $passed       = $false
    $customStatus = $null
    if ($anyFail) {
        $testResultMarkdown = "❌ One or more Teams protection controls is explicitly disabled, leaving report monitoring, link scanning, file detonation, or post-delivery quarantine coverage incomplete.`n`n%TestResult%"
    }
    elseif ($anyInvestigate) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ An enabled rule references a missing policy, an enabled Teams Protection rule has exceptions, or the tenant cloud/licensing needs manual confirmation.`n`n%TestResult%"
    }
    else {
        $passed             = $true
        $testResultMarkdown = "✅ Microsoft Teams protection is configured for messages, links, and attachments: Safe Attachments, Safe Links for Teams, ZAP for Teams, and Defender submission monitoring for Teams reports are enabled on every policy in use.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($row in $controlRows) {
        $policyMd         = if ($row.Policy) { Get-SafeMarkdown $row.Policy } else { '' }
        $appliedViaRuleMd = if ($row.AppliedViaRule) { Get-SafeMarkdown $row.AppliedViaRule } else { '' }
        $tableRows += "| $($row.Setting) | $policyMd | $appliedViaRuleMd | $($row.Enabled) | $($row.Status) |`n"
    }

    $formatTemplate = @'
| Setting | Policy | Applied via Rule | Enabled | Status |
| :------ | :----- | :--------------- | :------ | :----- |
{0}
'@

    $mdInfo             = $formatTemplate -f $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41114'
        Title  = 'Microsoft Teams protection policies are configured to block malicious messages, links, and attachments'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
