<#
.SYNOPSIS
    Guest access is limited to approved tenants
#>

function Test-Assessment-21822 {
    [ZtTest(
        Category = 'Access control',
        ImplementationCost = 'High',
        Pillar = 'Identity',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 21822,
        Title = 'Guest access is limited to approved tenants',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Guest access is limited to approved tenants"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = Invoke-ZtGraphRequest -RelativeUri "legacy/policies" -ApiVersion beta
    $b2BManagementPolicyObject = $result | Where-Object -FilterScript { $_.Type -eq "B2BManagementPolicy" }
    $b2BManagementPolicyDefinition = $b2BManagementPolicyObject.definition
    $b2BManagementPolicy = ( $b2BManagementPolicyDefinition | ConvertFrom-Json).B2BManagementPolicy
    $allowedDomains = $b2BManagementPolicy.InvitationsAllowedAndBlockedDomainsPolicy.AllowedDomains
    $allBlockedDomains = $b2BManagementPolicy.InvitationsAllowedAndBlockedDomainsPolicy.BlockedDomains

    $passed = $allowedDomains.Count -gt 0

    if ($passed) {
        $testResultMarkdown = "Guest access is limited to approved tenants.`n"
    }
    else {
        $testResultMarkdown = "Guest access is not limited to approved tenants.`n"
    }

    # Create markdown table for domain display
    $testResultMarkdown += "`n`n## [Collaboration restrictions](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/)`n`n"

    $testResultMarkdown += "The tenant is configured to: "
    if ($passed) {
        $testResultMarkdown += "**Allow invitations only to the specified domains (most restrictive)** ✅`n"
    }
    else {
        if ($allBlockedDomains.Count -gt 0) {
            $testResultMarkdown += "**Deny invitations to the specified domains** ❌`n"
        }
        else {
            $testResultMarkdown += "**Allow invitations to be sent to any domain (most inclusive)** ❌`n"
        }
    }

    if ($allowedDomains.Count -gt 0 -or $allBlockedDomains.Count -gt 0) {
        $testResultMarkdown += "| Domain | Status |`n"
        $testResultMarkdown += "| :--- | :--- |`n"

        foreach ($domain in $allowedDomains) {
            $testResultMarkdown += "| $domain | ✅ Allowed |`n"
        }

        foreach ($domain in $allBlockedDomains) {
            $testResultMarkdown += "| $domain | ❌ Blocked |`n"
        }
    }



    Add-ZtTestResultDetail -TestId '21822' -Title "Guest access is limited to approved tenants" `
        -Status $passed -Result $testResultMarkdown
}
