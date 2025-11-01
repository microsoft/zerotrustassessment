<#
.SYNOPSIS
    Check if Temporary Access Pass is configured for one-time use only
#>

function Test-Assessment-21846{
    [ZtTest(
    	Category = 'Credential management',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21846,
    	Title = 'Restrict Temporary Access Pass to Single Use',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Temporary access pass restricted to one-time use"
    Write-ZtProgress -Activity $activity -Status "Getting Temporary Access Pass policy"

    # Query Temporary Access Pass authentication method configuration
    $tapConfig = Invoke-ZtGraphRequest -RelativeUri 'policies/authenticationMethodsPolicy/authenticationMethodConfigurations/temporaryAccessPass' -ApiVersion 'v1.0'

    # Check if isUsableOnce property is true
    $passed = $tapConfig.isUsableOnce -eq $true

    if ($passed) {
        $testResultMarkdown = "Temporary Access Pass is configured for one-time use only.`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Temporary Access Pass allows multiple uses during validity period.`n`n%TestResult%"
    }

    # Build the detailed sections of the markdown
    $reportTitle = "Temporary Access Pass Configuration"

    # Create a here-string with format placeholders
    $formatTemplate = @"

## {0}

| Setting | Value | Status |
| :------ | :---- | :----- |
| [One-time use restriction](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AdminAuthMethods/fromNav/) | {1} | {2} |

"@

    $isUsableOnceValue = if ($tapConfig.isUsableOnce) { "Enabled" } else { "Disabled" }
    $statusEmoji = if ($passed) { "✅ Pass" } else { "❌ Fail" }
    $methodState = (Get-Culture).TextInfo.ToTitleCase($tapConfig.state.ToLower())

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle, $isUsableOnceValue, $statusEmoji, $methodState

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21846'
        Title              = "Temporary access pass restricted to one-time use"
        UserImpact         = 'Low'
        Risk               = 'Low'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
