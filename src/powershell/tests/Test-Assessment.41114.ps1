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
        Add-ZtTestResultDetail -SkippedBecause NotSupported -Result 'This test is not applicable to the USGov or USGovDoD environments.'
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

    Write-ZtProgress -Activity $activity -Status 'Retrieving Teams ZAP protection policy'
    $teamsProtectionPolicy = $null
    $q2Error = $null
    try {
        # Q2: Retrieve Teams ZAP policy state.
        $teamsProtectionPolicy = Get-TeamsProtectionPolicy -ErrorAction Stop | Select-Object Name, ZapEnabled
    }
    catch {
        $q2Error = $_
        Write-PSFMessage "Q2: Failed to retrieve Teams protection policy: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Retrieving Teams ZAP exception rule'
    $teamsProtectionPolicyRule = $null
    $q2rError = $null
    try {
        # Q2b: Retrieve Teams ZAP exception rule. Null return is expected when no exceptions are configured
        # (the default). A populated ExceptIf* property means some recipients are excluded from ZAP.
        $teamsProtectionPolicyRule = Get-TeamsProtectionPolicyRule -ErrorAction Stop |
            Select-Object Name, TeamsProtectionPolicy, ExceptIfSentTo, ExceptIfSentToMemberOf, ExceptIfRecipientDomainIs
    }
    catch {
        $q2rError = $_
        Write-PSFMessage "Q2b: Failed to retrieve Teams protection policy rule: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Retrieving Safe Links policies'
    $safeLinksPolicies = $null
    $q3Error = $null
    try {
        # Q3: Retrieve all Safe Links policies; IsBuiltInProtection identifies the Microsoft-managed
        # Built-in Protection preset that applies to users not covered by a Standard/Strict/custom policy.
        $safeLinksPolicies = @(Get-SafeLinksPolicy -ErrorAction Stop | Select-Object Identity, IsBuiltInProtection, IsDefault, EnableSafeLinksForTeams)
    }
    catch {
        $q3Error = $_
        Write-PSFMessage "Q3: Failed to retrieve Safe Links policies: $_" -Tag Test -Level Warning
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

    # Control rows: Setting (friendly portal label with link), Value (✅/❌/⚠️ string), RowResult
    $controlRows = [System.Collections.Generic.List[PSCustomObject]]::new()

    # For each query: $qNUnknown = data could not be fetched; $qNEnabled = control is on.
    # Verdict flags and the single controlRows.Add are resolved from those two booleans.

    $q1PortalLink = 'https://security.microsoft.com/safeattachmentv2'
    $q2PortalLink = 'https://security.microsoft.com/securitysettings/teamsProtectionPolicy'
    $q3PortalLink = 'https://security.microsoft.com/safelinksv2'
    $q4PortalLink = 'https://security.microsoft.com/securitysettings/userSubmission'

    # --- Q1: Safe Attachments for SharePoint, OneDrive, and Teams ---
    $q1Unknown = $q1Error -or $null -eq $safeAttachmentPolicy -or $null -eq $safeAttachmentPolicy.EnableATPForSPOTeamsODB
    $q1Enabled = -not $q1Unknown -and $safeAttachmentPolicy.EnableATPForSPOTeamsODB -eq $true
    if ($q1Unknown) { $anyInvestigate = $true } elseif (-not $q1Enabled) { $anyFail = $true }
    $controlRows.Add([PSCustomObject]@{
        Setting   = "[Safe Attachments for SharePoint, OneDrive, and Microsoft Teams]($q1PortalLink)"
        Value     = if ($q1Unknown) { '⚠️ Query error — verify in portal' } elseif ($q1Enabled) { '✅ Yes' } else { '❌ No' }
        RowResult = if ($q1Unknown) { '⚠️ Investigate' } elseif ($q1Enabled) { '✅ Pass' } else { '❌ Fail' }
    })

    # --- Q2: ZAP for Teams ---
    $q2Unknown = $q2Error -or $null -eq $teamsProtectionPolicy -or $null -eq $teamsProtectionPolicy.ZapEnabled
    $q2Enabled = -not $q2Unknown -and $teamsProtectionPolicy.ZapEnabled -eq $true
    if ($q2Unknown) { $anyInvestigate = $true } elseif (-not $q2Enabled) { $anyFail = $true }
    $controlRows.Add([PSCustomObject]@{
        Setting   = "[ZAP for Teams]($q2PortalLink)"
        Value     = if ($q2Unknown) { '⚠️ Query error — verify in portal' } elseif ($q2Enabled) { '✅ Yes' } else { '❌ No' }
        RowResult = if ($q2Unknown) { '⚠️ Investigate' } elseif ($q2Enabled) { '✅ Pass' } else { '❌ Fail' }
    })

    # --- Q2b: ZAP for Teams — exception scope ---
    # Null rule = no exceptions = all users covered (healthy default); add a row only when
    # the rule exists with at least one populated ExceptIf* property, or on query error.
    $q2rHasExceptions = (-not $q2rError) -and ($null -ne $teamsProtectionPolicyRule) -and (
        $teamsProtectionPolicyRule.ExceptIfSentTo -or
        $teamsProtectionPolicyRule.ExceptIfSentToMemberOf -or
        $teamsProtectionPolicyRule.ExceptIfRecipientDomainIs
    )
    if ($q2rError) {
        $anyInvestigate = $true
        $controlRows.Add([PSCustomObject]@{
            Setting   = "[ZAP for Teams — exception scope]($q2PortalLink)"
            Value     = '⚠️ Query error — verify in portal'
            RowResult = '⚠️ Investigate'
        })
    }
    elseif ($q2rHasExceptions) {
        $anyInvestigate = $true
        $controlRows.Add([PSCustomObject]@{
            Setting   = "[ZAP for Teams — exception scope]($q2PortalLink)"
            Value     = '⚠️ Exceptions configured'
            RowResult = '⚠️ Investigate — exceptions reduce ZAP coverage'
        })
    }

    # --- Q3: Safe Links for Teams — pass if at least one policy has Teams enabled ---
    $q3Unknown = $q3Error -or $null -eq $safeLinksPolicies -or $safeLinksPolicies.Count -eq 0 -or
                 (-not ($safeLinksPolicies | Where-Object { $null -ne $_.EnableSafeLinksForTeams }))
    $q3Enabled = -not $q3Unknown -and [bool]($safeLinksPolicies | Where-Object { $_.EnableSafeLinksForTeams -eq $true })
    if ($q3Unknown) { $anyInvestigate = $true } elseif (-not $q3Enabled) { $anyFail = $true }
    $controlRows.Add([PSCustomObject]@{
        Setting   = "[Safe Links for Teams]($q3PortalLink)"
        Value     = if ($q3Unknown) { '⚠️ Query error — verify in portal' } elseif ($q3Enabled) { '✅ Yes' } else { '❌ No' }
        RowResult = if ($q3Unknown) { '⚠️ Investigate' } elseif ($q3Enabled) { '✅ Pass' } else { '❌ Fail' }
    })

    # --- Q4: Monitor reported items in Microsoft Teams ---
    $q4Unknown = $q4Error -or $null -eq $reportSubmissionPolicy -or $null -eq $reportSubmissionPolicy.ReportChatMessageEnabled
    $q4Enabled = -not $q4Unknown -and $reportSubmissionPolicy.ReportChatMessageEnabled -eq $true
    if ($q4Unknown) { $anyInvestigate = $true } elseif (-not $q4Enabled) { $anyFail = $true }
    $controlRows.Add([PSCustomObject]@{
        Setting   = "[Monitor reported items in Microsoft Teams]($q4PortalLink)"
        Value     = if ($q4Unknown) { '⚠️ Query error — verify in portal' } elseif ($q4Enabled) { '✅ Yes' } else { '❌ No' }
        RowResult = if ($q4Unknown) { '⚠️ Investigate' } elseif ($q4Enabled) { '✅ Pass' } else { '❌ Fail' }
    })

    # Final verdict: Fail takes priority over Investigate.
    $passed       = $false
    $customStatus = $null
    if ($anyFail) {
        $testResultMarkdown = "❌ One or more Teams protection controls are disabled, leaving report monitoring, link scanning, file detonation, or post-delivery quarantine coverage incomplete.`n`n%TestResult%"
    }
    elseif ($anyInvestigate) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ A required policy is missing, an exception scope may exclude too many recipients, or the tenant cloud/licensing needs manual confirmation.`n`n%TestResult%"
    }
    else {
        $passed             = $true
        $testResultMarkdown = "✅ Microsoft Teams protection is configured for messages, links, and attachments: Safe Attachments, Safe Links for Teams, ZAP for Teams, and Defender submission monitoring for Teams reports are enabled.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($row in $controlRows) {
        $tableRows += "| $($row.Setting) | $($row.Value) | $($row.RowResult) |`n"
    }

    $formatTemplate = @'
| Setting | Enabled | Status |
| :------ | :------ | :----- |
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
