<#
.SYNOPSIS

#>

function Test-Assessment-21828 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21828,
    	Title = 'Authentication transfer is blocked',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Authentication transfer is blocked"
    Write-ZtProgress -Activity $activity -Status "Getting conditional access policies"

    # Query for all CA policies
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri 'policies/conditionalAccessPolicies' -ApiVersion beta

    # Local filtering for blocked authentication transfer policies - only consider enabled policies
    $matchedPolicies = $allCAPolicies | Where-Object {
        $_.conditions.authenticationFlows.transferMethods -match "authenticationTransfer" -and
        $_.grantControls.builtInControls -contains "block" -and
        $_.conditions.users.includeUsers -eq "all" -and
        $_.conditions.applications.includeApplications -eq "all" -and
        $_.state -eq "enabled"
    }

    $testResultMarkdown = ""

    if ($matchedPolicies.Count -gt 0) {
        $passed = $true
        $testResultMarkdown += "Authentication transfer is blocked by Conditional Access Policy(s).%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown += "Authentication transfer is not blocked."
    }

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Conditional Access Policies targeting Authentication Transfer"
    $tableRows = ""

    if ($matchedPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Policy Name | Policy ID | State | Created | Modified |
| :---------- | :-------- | :---- | :------ | :------- |
{1}

'@

        foreach ($policy in $matchedPolicies) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}" -f $policy.id
            $tableRows += @"
| [$(Get-SafeMarkdown($policy.displayName))]($portalLink) | $($policy.id) | $($policy.state) | $(Get-FormattedDate($policy.createdDateTime)) | $(Get-FormattedDate($policy.modifiedDateTime)) |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    else {
        $mdInfo = "No Conditional Access policies targeting authentication transfer.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21828'
        Title              = "Authentication transfer is blocked"
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
