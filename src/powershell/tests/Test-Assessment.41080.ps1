<#
.SYNOPSIS
    Checks that Conditional Access App Control session policies are enabled for cloud apps.

.NOTES
    Test ID: 41080
    Workshop Task: SECOPS-080
    Pillar: SecOps
    Category: Identity threat protection
    Required permission: Policy.Read.All
#>

function Test-Assessment-41080 {

    [ZtTest(
        Category           = 'Identity threat protection',
        CompatibleLicense  = ('ADALLOM_S_STANDALONE&AAD_PREMIUM'),
        ImplementationCost = 'Medium',
        Pillar             = 'SecOps',
        RiskLevel          = 'High',
        Service            = ('Graph'),
        SfiPillar          = 'Protect identities and secrets',
        TenantType         = ('Workforce'),
        TestId             = 41080,
        Title              = 'Conditional Access App Control session policies are enforced for sensitive cloud apps',
        UserImpact         = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Conditional Access App Control session policies'
    Write-ZtProgress -Activity $activity -Status 'Querying enabled Conditional Access policies'

    try {
        $enabledPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta -Filter "state eq 'enabled'" -Select 'id,displayName,state,conditions,sessionControls' -ErrorAction Stop
    }
    catch {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Failed to retrieve Conditional Access policies (HTTP $httpStatus): $_" -Tag Test -Level Warning

        $resultMessage = if ($httpStatus -in @(401, 403)) {
            '⚠️ The Conditional Access policy collection could not be retrieved because the assessment account lacks Policy.Read.All permission. Grant the permission and re-run the assessment.'
        }
        else {
            '⚠️ The Conditional Access policy collection could not be retrieved because Microsoft Graph returned a transient or unexpected error. Verify connectivity and re-run the assessment.'
        }

        $params = @{
            TestId       = '41080'
            Title        = 'Conditional Access App Control session policies are enforced for sensitive cloud apps'
            Status       = $false
            Result       = $resultMessage
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $enabledPolicies = @($enabledPolicies)

    $policyResults = foreach ($policy in $enabledPolicies) {
        $targetApps = @($policy.conditions.applications.includeApplications | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $sessionControl = $policy.sessionControls.cloudAppSecurity
        $isEnabled = $null -ne $sessionControl -and $sessionControl.isEnabled -eq $true
        $isMatchingPolicy = $isEnabled -and $targetApps.Count -gt 0

        $knownTargets = @($targetApps | Where-Object { $_ -in @('All', 'Office365', 'MicrosoftAdminPortals') } | ForEach-Object {
            switch ($_) {
                'All'                   { 'All cloud apps' }
                'Office365'             { 'Office 365' }
                'MicrosoftAdminPortals' { 'Microsoft admin portals' }
            }
        })
        $selectedTargetCount = @($targetApps | Where-Object { $_ -notin @('All', 'Office365', 'MicrosoftAdminPortals') }).Count
        if ($selectedTargetCount -gt 0) {
            $selectedTargetLabel = if ($selectedTargetCount -eq 1) { '1 selected app' } else { "$selectedTargetCount selected apps" }
            $knownTargets += $selectedTargetLabel
        }

        $cloudAppSecurityType = if ($sessionControl.cloudAppSecurityType) { $sessionControl.cloudAppSecurityType } else { 'Not configured' }
        $rowStatus = if (-not $isMatchingPolicy) {
            'Fail'
        }
        elseif ($cloudAppSecurityType -eq 'unknownFutureValue') {
            'Investigate'
        }
        else {
            'Pass'
        }

        [PSCustomObject]@{
            PolicyDisplayName    = $policy.displayName
            PolicyId             = $policy.id
            State                = $policy.state
            TargetApps           = if ($knownTargets.Count -gt 0) { $knownTargets -join ', ' } else { 'None' }
            CloudAppSecurityType = $cloudAppSecurityType
            IsEnabled            = $isEnabled
            Matches              = $isMatchingPolicy
            RowStatus            = $rowStatus
        }
    }

    $policyResults = @($policyResults)
    $matchingPolicies = @($policyResults | Where-Object Matches)
    $knownMatchingPolicies = @($matchingPolicies | Where-Object CloudAppSecurityType -ne 'unknownFutureValue')

    $passed = $false
    $customStatus = $null
    if ($knownMatchingPolicies.Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ At least one enabled Conditional Access policy enforces Microsoft Defender for Cloud Apps session control via Conditional Access App Control.`n`n%TestResult%"
    }
    elseif ($matchingPolicies.Count -gt 0) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Conditional Access App Control is enabled, but every matching policy returned an unknown Cloud App Security type. Review the policies in Microsoft Entra.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No enabled Conditional Access policy has Defender for Cloud Apps session control enabled for a cloud app.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade'
    $policyUrlTemplate = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}'
    $maxDisplay = 10
    $displayPolicies = @($policyResults | Sort-Object -Property @{ Expression = { -not $_.Matches } }, PolicyDisplayName | Select-Object -First $maxDisplay)

    $tableRows = ''
    foreach ($policy in $displayPolicies) {
        $policyName = "[$(Get-SafeMarkdown -Text $policy.PolicyDisplayName)]($($policyUrlTemplate -f $policy.PolicyId))"
        $targetApps = Get-SafeMarkdown -Text $policy.TargetApps
        $securityType = Get-SafeMarkdown -Text $policy.CloudAppSecurityType
        $isEnabled = if ($policy.IsEnabled) { 'True' } else { 'False' }
        $status = switch ($policy.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $policyName | $($policy.State) | $targetApps | $securityType | $isEnabled | $status |`n"
    }

    if ($policyResults.Count -eq 0) {
        $tableRows = "| No enabled policies found | — | — | — | False | ❌ Fail |`n"
    }
    elseif ($policyResults.Count -gt $maxDisplay) {
        $remaining = $policyResults.Count - $maxDisplay
        $tableRows += "`n... and $remaining more. [Microsoft Entra > Conditional Access > Policies]($portalUrl)`n"
    }

    $formatTemplate = @'


## [Microsoft Entra > Conditional Access > Policies]({0})

| Policy display name | State | Target apps | Cloud App Security type | Is enabled | Status |
| :------------------ | :---- | :---------- | :---------------------- | :--------- | :----- |
{1}
'@

    $mdInfo = $formatTemplate -f $portalUrl, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41080'
        Title  = 'Conditional Access App Control session policies are enforced for sensitive cloud apps'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
