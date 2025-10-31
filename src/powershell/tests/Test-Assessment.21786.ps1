<#
.SYNOPSIS

#>

function Test-Assessment-21786 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21786,
    	Title = 'User sign-in activity uses token protection',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking User sign-in activity uses token protection"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Query for all CA policies
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -ApiVersion beta

    # Local filtering for token protection policies - only consider enabled policies
    $matchedPolicies = $allCAPolicies | Where-Object {
        ($_.conditions.clientAppTypes.Count -eq 1 -and $_.conditions.clientAppTypes[0] -eq "mobileAppsAndDesktopClients") -and
        ($_.conditions.applications.includeApplications -contains "00000002-0000-0ff1-ce00-000000000000" -and $_.conditions.applications.includeApplications -contains  "00000003-0000-0ff1-ce00-000000000000") -and
        ($_.conditions.platforms.includePlatforms.Count -eq 1 -and $_.conditions.platforms.includePlatforms -eq "windows") -and
        $_.sessionControls.secureSignInSession.isEnabled -eq $true -and
        $_.state -eq "enabled"
    }

    $testResultMarkdown = ""

    if ($matchedPolicies.Count -gt 0) {
        $passed = $true
        $testResultMarkdown += "The tenant has Token Protection policies properly configured.%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown += "The tenant is missing properly configured Token Protection policies."
    }

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Conditional Access Policies targeting token protection"
    $tableRows = ""

    if ($matchedPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Policy Name | Policy ID |
| :---------- | :-------- |
{1}

'@

        foreach ($policy in $matchedPolicies) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}" -f $policy.id
            $tableRows += @"
| [$(Get-SafeMarkdown($policy.displayName))]($portalLink) | $($policy.id) |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    else {
        $mdInfo = "No Conditional Access policies targeting token protection.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21786'
        Title              = "User sign-in activity uses token protection"
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
