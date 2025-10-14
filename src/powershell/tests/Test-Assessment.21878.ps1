<#
.SYNOPSIS
    Assessment 21878 – Verifies that all entitlement management policies have expiration dates configured
#>

function Test-Assessment-21878 {
    [ZtTest(
        Category = 'Access control',
        ImplementationCost = 'Medium',
        Pillar = 'Identity',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce','External'),
        TestId = 21878,
        Title = 'All entitlement management policies have an expiration date',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking entitlement management assignment policies for expiration dates'
    Write-ZtProgress -Activity $activity -Status 'Getting assignment policies'

    # Query entitlement management assignment policies (do not use $select for properties not supported by API)
    $policies = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/entitlementManagement/assignmentPolicies' -ApiVersion v1.0

    $matchingPolicies    = @()
    $nonMatchingPolicies = @()

    foreach ($policy in $policies) {
        $expiration    = $policy.expiration
        $hasDuration   = ($expiration.duration) -and ($expiration.type -eq 'afterDuration')
        $hasEndDate    = ($expiration.endDateTime) -and ($expiration.type -eq 'afterDateTime')
        $meetsCriteria = ($hasDuration -or $hasEndDate)

        $detail = [PSCustomObject]@{
            PolicyId       = $policy.id
            DisplayName    = $policy.displayName
            ExpirationType = $expiration.type
            Duration       = $expiration.duration
            EndDateTime    = $expiration.endDateTime
            AccessPackageId= $policy.accessPackageId
            CatalogId      = $policy.catalogId
            CatalogName    = $policy.catalogName
            MeetsCriteria  = $meetsCriteria
        }

        if ($meetsCriteria) {
            $matchingPolicies += $detail
        } else {
            $nonMatchingPolicies += $detail
        }
    }

    function Get-PolicyPortalLink {
        param($policy)
        $catalogName = [uri]::EscapeDataString($policy.CatalogName)
        $entitlementName = [uri]::EscapeDataString($policy.DisplayName)
        return 'https://entra.microsoft.com/#view/Microsoft_Azure_ELMAdmin/EntitlementMenuBlade/~/policies/entitlementId/{0}/catalogId/{1}/catalogName/{2}/entitlementName/{3}' -f $policy.AccessPackageId, $policy.CatalogId, $catalogName, $entitlementName
    }

    $passed = ($nonMatchingPolicies | Measure-Object).Count -eq 0
    $testResultMarkdown = ''

    if ($passed) {
        $testResultMarkdown += '✅ All entitlement management policies have expiration dates configured.'
    } else {
        $testResultMarkdown += '❌ Not all entitlement management policies have expiration dates configured.'
    }

    if (-not $matchingPolicies) {
        $testResultMarkdown += "`nNo entitlement management policies were found with expiration dates configured."
    } else {
        $testResultMarkdown += "`n### Entitlement Management Assignment Policies with Expiration Dates`n"
        $testResultMarkdown += '| Name | Expiration Type | Duration / End DateTime |' + "`n"
        $testResultMarkdown += '| :--- | :--- | ---: |' + "`n"
        foreach ($item in $matchingPolicies) {
            $duration = if ($item.Duration) { $item.Duration } else { '' }
            $endDateTime = if ($item.EndDateTime) { Get-FormattedDate($item.EndDateTime) } else { '' }
            $portalLink = Get-PolicyPortalLink $item
            $testResultMarkdown += '| [{0}]({1}) | {2} | {3}{4} |' -f (Get-SafeMarkdown $item.DisplayName), $portalLink, $item.ExpirationType, $duration, $endDateTime
            $testResultMarkdown += "`n"
        }
    }

    if ($nonMatchingPolicies.Count -gt 0) {
        $testResultMarkdown += "`n#### Policies missing expiration:`n"
        $testResultMarkdown += '| Name | Expiration Type | Duration / End DateTime |' + "`n"
        $testResultMarkdown += '| :--- | :--- | ---: |' + "`n"
        foreach ($item in $nonMatchingPolicies) {
            $duration = if ($item.Duration) { $item.Duration } else { '' }
            $endDateTime = if ($item.EndDateTime) { $item.EndDateTime } else { '' }
            $portalLink = Get-PolicyPortalLink $item
            $testResultMarkdown += '| [{0}]({1}) | {2} | {3} | {4} |' -f (Get-SafeMarkdown $item.DisplayName), $portalLink, $item.ExpirationType, $duration, $endDateTime
            $testResultMarkdown += "`n"
        }
    }

    $params = @{
        TestId = '21878'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
