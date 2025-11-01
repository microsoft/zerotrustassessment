<#
.SYNOPSIS
    Checks if there are any untriaged high-risk users in Identity Protection.
#>

function Test-Assessment-21861 {
    [ZtTest(
    	Category = 'Monitoring',
    	ImplementationCost = 'High',
    	MinimumLicense = ('P2'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Monitor and detect cyberthreats',
    	TenantType = ('Workforce','External'),
    	TestId = 21861,
    	Title = 'All high-risk users are triaged',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking All risky users are triaged"
    Write-ZtProgress -Activity $activity -Status "Getting risky users"

    $EntraIDPlan = Get-ZtLicenseInformation -Product EntraID
    if ($EntraIDPlan -eq "Free" -or $EntraIDPlan -eq "P1") {
        Write-PSFMessage '🟦 Skipping test: Requires P2 or Governance plan' -Tag Test -Level VeryVerbose
        return
    }

    # Query 1: Get untriaged risky users with high risk level
    $riskyUsersQuery = "identityProtection/riskyUsers"
    $riskyUsers = Invoke-ZtGraphRequest -RelativeUri $riskyUsersQuery -ApiVersion 'v1.0' -Filter "riskState eq 'atRisk' and riskLevel eq 'High'"

    # Determine pass/fail - pass if no untriaged risky users found
    $result = ($riskyUsers.Count -eq 0)
    $passed = $result

    # Prepare the markdown output
    if ($result) {
        $testResultMarkdown = "All high-risk users are properly triaged in Entra ID Protection.%TestResult%"
    }
    else {
        $testResultMarkdown = "Found **$($riskyUsers.Count)** untriaged high-risk users in Entra ID Protection.%TestResult%"
    }

    # Build the detailed sections of the markdown
    $mdInfo = ""

    if (!$result) {
        $mdInfo += "`n## Untriaged High-Risk Users`n`n"
        $mdInfo += "| User | Risk level | Last updated | Risk detail |`n"
        $mdInfo += "| :----------------- | :--------- | :-------------------- | :---------- |`n"

        foreach ($user in $riskyUsers) {
            $userPrincipalName = $user.userPrincipalName ?? $user.id
            $riskLevel = Get-FormattedRiskLevel -RiskLevel $user.riskLevel
            $riskDate = $user.riskLastUpdatedDateTime # ID protection returns us format by default
            $mdInfo += "| $userPrincipalName |  $riskLevel | $riskDate | $($user.riskDetail) |`n"
        }
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21861' -Title "All risky users are triaged" `
        -UserImpact Low -Risk High -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
