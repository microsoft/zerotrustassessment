<#
.SYNOPSIS

#>

function Test-Assessment-21806 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21806,
    	Title = 'Secure the MFA registration (My Security Info) page',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Secure the MFA registration (My Security Info) page"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query for all CA policies
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion 'v1.0'

    # Local filtering for security information registration - only consider enabled policies
    $matchedPolicies = $allCAPolicies | Where-Object {
        ($_.conditions.applications.includeUserActions -contains 'urn:user:registersecurityinfo') -and
        ($_.conditions.users.includeUsers -contains 'All') -and
        $_.state -eq 'enabled'
    }

    $testResultMarkdown = ""

    if ($matchedPolicies.Count -gt 0) {
        $passed = $true
        $testResultMarkdown += "Security information registration is protected by Conditional Access policies.%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown += "Security information registration is not protected by Conditional Access policies."
    }

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Conditional Access Policies targeting security information registration"
    $tableRows = ""

    if ($matchedPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Policy Name | User Actions Targeted | Grant Controls Applied |
| :---------- | :-------------------- | :--------------------- |
{1}

'@

        foreach ($policy in $matchedPolicies) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}" -f $policy.id
            $tableRows += @"
| [$(Get-SafeMarkdown($policy.displayName))]($portalLink) | $($policy.conditions.applications.includeUserActions) | $($policy.grantControls.builtInControls -join ', ') |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    else {
        $mdInfo = "No Conditional Access policies targeting security information registration.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21806'
        Title              = 'Secure the MFA registration (My Security Info) page'
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'Medium'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
