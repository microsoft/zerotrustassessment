<#
.SYNOPSIS
   Checks if workload identities are configured with risk-based policies
#>

function Test-Assessment-21883 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('Workload'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Accelerate response and remediation',
    	TenantType = ('Workforce','External'),
    	TestId = 21883,
    	Title = 'Workload Identities are configured with risk-based policies',
    	UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if ( -not (Get-ZtLicense EntraWorkloadID) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraWorkloadID
        return
    }

    $activity = "Checking Workload identities based on risk policies are configured"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query for all CA policies
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri 'policies/conditionalAccessPolicies' -ApiVersion beta

    # Local filtering for blocked authentication transfer policies - only consider enabled policies
    $matchedPolicies = $allCAPolicies | Where-Object {
        $_.grantControls.builtInControls -contains "block" -and
        $_.conditions.clientApplications.includeServicePrincipals -and
        $_.state -eq "enabled"
    }

    $testResultMarkdown = ""

    if (($matchedPolicies | Measure-Object).Count -ge 1) {
        $passed = $true
        $testResultMarkdown += "Workload identities based on risk policies are configured.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown += "Workload identities based on risk policy is not configured."
    }

    $params = @{
        TestId             = '21883'
        Title              = "Workload identities are configured with risk-based policies"
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        GraphObjectType    = 'ConditionalAccess'
        GraphObjects       = $matchedPolicies
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
