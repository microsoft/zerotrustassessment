<#
.SYNOPSIS

#>

function Test-Assessment-21803 {
    [ZtTest(
    	Category = 'Credential management',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21803,
    	Title = 'Migrate from legacy MFA and SSPR policies',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Migrate from legacy MFA and SSPR policies"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = Invoke-ZtGraphRequest -RelativeUri "policies/authenticationMethodsPolicy" -ApiVersion beta
    if ($null -eq $result) {
        Write-ZtProgress -Activity $activity -Status "Failed to retrieve policy"
        return
    }

    # Check if combined security information registration is enabled in the tenant
    if ($result.policyMigrationState -eq "migrationComplete") {
        $passed = $true
        $testResultMarkdown = "Combined registration is enabled.`n`n"
    }
    else {
        $passed = $false
        $testResultMarkdown = "Combined registration is not enabled.`n`n"
    }

    $params = @{
        TestId             = '21803'
        Title              = "Migrate from legacy MFA and SSPR policies"
        UserImpact         = 'Medium'
        Risk               = 'High'
        ImplementationCost = 'Medium'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
