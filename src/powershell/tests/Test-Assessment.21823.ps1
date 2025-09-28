<#
.SYNOPSIS
    Guest self-service sign-up via user flow is disabled
#>

function Test-Assessment-21823{
    [ZtTest(
    	Category = 'External collaboration',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce'),
    	TestId = 21823,
    	Title = 'Guest self-service sign-up via user flow is disabled',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Guest self-service sign-up via user flow is disabled"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $authFlowPolicy = Invoke-ZtGraphRequest -RelativeUri "policies/authenticationFlowsPolicy" -ApiVersion v1.0
    #endregion Data Collection

    #region Assessment Logic
    $passed = $authFlowPolicy.selfServiceSignUp.isEnabled -eq $false

    if ($passed) {
        $testResultMarkdown = "Guest self-service sign up via user flow is disabled.`n"
    }
    else {
        $testResultMarkdown = "Guest self-service sign up via user flow is enabled.`n"
    }

    #endregion Assessment Logic

    #region Report Generation
    $activity = "Checking Guest self-service sign-up via user flow is disabled"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    #endregion Report Generation

    $params = @{
        TestId = '21823'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
