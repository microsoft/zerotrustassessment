<#
.SYNOPSIS
    Guest access is limited to approved tenants
#>

function Test-Assessment-21822{
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
    $b2BManagementPolicyObject = $result | Where-Object -FilterScript {$_.Type -eq "B2BManagementPolicy"}
    $b2BManagementPolicyDefinition = $b2BManagementPolicyObject.definition
    $b2BManagementPolicy = ( $b2BManagementPolicyDefinition | ConvertFrom-Json).B2BManagementPolicy
    $allowedDomains = $b2BManagementPolicy.InvitationsAllowedAndBlockedDomainsPolicy.AllowedDomains
    $allBlockedDomains = $b2BManagementPolicy.InvitationsAllowedAndBlockedDomainsPolicy.BlockedDomains

    $passed = $allowedDomains.Count -gt 0

    # Create markdown table for domain display
    $domainTable = ""
    $domainTable = "`n`n## [Collaboration restrictions](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/CompanyRelationshipsMenuBlade/~/Settings/menuId/)`n`n"
    if ($allowedDomains.Count -gt 0 -or $allBlockedDomains.Count -gt 0) {
        $domainTable += "| Domain | Status |`n"
        $domainTable += "| :--- | :--- |`n"

        foreach ($domain in $allowedDomains) {
            $domainTable += "| $domain | ✅ Allowed |`n"
        }

        foreach ($domain in $allBlockedDomains) {
            $domainTable += "| $domain | ❌ Blocked |`n"
        }
    }

    if ($passed) {
        $testResultMarkdown = "Allow invitations only to the specified domains (most restrictive) ✅$domainTable"
    }
    elseif ($allBlockedDomains.Count -gt 0) {
        $testResultMarkdown = "Deny invitations to the specified domains ❌$domainTable"
    }
    else {
        $testResultMarkdown = "Allow invitations to be sent to any domain (most inclusive) ❌$domainTable"
    }

    Add-ZtTestResultDetail -TestId '21822' -Title "Guest access is limited to approved tenants" `
        -Status $passed -Result $testResultMarkdown
}
