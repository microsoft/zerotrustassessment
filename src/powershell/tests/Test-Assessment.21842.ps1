<#
.SYNOPSIS

#>

function Test-Assessment-21842{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21842,
    	Title = 'Block administrators from using SSPR',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Block administrators from using SSPR"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query the authorization policy for allowedToUseSspr
    $authorizationPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/authorizationPolicy' -ApiVersion 'v1.0'
    $allowedToUseSspr = $authorizationPolicy.allowedToUseSspr

    $passed = $false
    $userMessage = ""
    $details = ""

    if ($null -ne $allowedToUseSspr -and $allowedToUseSspr -eq $false) {
        $passed = $true
        $userMessage = '✅ Administrators are properly blocked from using Self-Service Password Reset, ensuring password changes go through controlled processes.'
    } else {
        $userMessage = '❌ Administrators have access to Self-Service Password Reset, which bypasses security controls and administrative oversight.'
    }

    # Build markdown output (no remediation section)
    $testResultMarkdown = @"
$userMessage
"@

    Add-ZtTestResultDetail -TestId '21842' -Title "Block administrators from using SSPR" `
        -UserImpact Low -Risk Low -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
