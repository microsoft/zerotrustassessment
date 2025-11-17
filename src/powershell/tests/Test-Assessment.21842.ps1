<#
.SYNOPSIS

#>

function Test-Assessment-21842{
    [ZtTest(
    	Category = 'Credential management, Privileged access',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('P1'),
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

    $activity = 'Checking Block administrators from using SSPR'
    Write-ZtProgress -Activity $activity -Status 'Getting policy'

    # Query the authorization policy for allowedToUseSspr
    $authorizationPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/authorizationPolicy' -ApiVersion beta
    $allowedToUseSspr = $authorizationPolicy.allowedToUseSspr

    $passed = $false
    $userMessage = ""

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

    $params = @{
        TestId = '21842'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
