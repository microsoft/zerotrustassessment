<#
.SYNOPSIS

#>

function Test-Assessment-22099{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('External'),
    	TestId = 22099,
    	Title = 'Integrate Entra Sign-In logs with Azure Monitor',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking [CIAM] Integrate Entra Sign-In logs with Azure Monitor"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = $false
    $testResultMarkdown = "Planned for future release."
    $passed = $result


    Add-ZtTestResultDetail -TestId '22099' -Title "[CIAM] Integrate Entra Sign-In logs with Azure Monitor" `
        -UserImpact Low -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown -SkippedBecause UnderConstruction
}
